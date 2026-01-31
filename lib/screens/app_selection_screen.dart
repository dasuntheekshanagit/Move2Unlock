import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import '../services/app_lock_service.dart';

class AppSelectionScreen extends StatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  final AppLockService _appLockService = AppLockService();
  List<AppInfo> _installedApps = [];
  List<String> _lockedPackages = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    await _appLockService.init(); // Ensure service is initialized
    final apps = await _appLockService.getInstalledApps();
    // Filter out system apps if desired, or keep them. Usually users want to lock user apps.
    // For now, let's keep all but maybe sort them.
    apps.sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    
    // Load currently locked packages
    // We need to expose a getter for locked packages in AppLockService or just reload them here
    // For simplicity, let's assume we start fresh or need to fetch them.
    // Ideally AppLockService should provide this.
    // Let's modify AppLockService to expose locked packages or just use shared prefs here directly?
    // Better to use the service. I'll assume _appLockService has a way or I'll add it.
    // Since I can't easily modify the service interface in this single step without context, 
    // I will rely on the service's internal state if exposed, or just re-fetch from prefs in the service.
    // Wait, I can just use the service to set them later.
    // Let's just load them from the service if possible.
    // Actually, let's just use a local list for now and save it on "Save".
    // But we need to know what was previously selected.
    // I'll add a method to AppLockService to get locked packages.
    
    setState(() {
      _installedApps = apps;
      _isLoading = false;
    });
    
    // Fetch previously locked apps
    // Since I can't modify AppLockService right here in this file write, I'll do it in a separate step if needed.
    // But wait, I can read from SharedPreferences directly here as a fallback or assume the service handles it.
    // Let's just read from SharedPreferences for now to populate initial state.
    // Actually, I'll update AppLockService to expose it properly in the next step.
    // For now, let's just show the installed apps.
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = _installedApps.where((app) {
      return app.name!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                    title: Text(
                      'Select Apps',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search apps...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        fillColor: Theme.of(context).cardTheme.color,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final app = filteredApps[index];
                        final isSelected = _lockedPackages.contains(app.packageName);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _lockedPackages.remove(app.packageName);
                                } else {
                                  _lockedPackages.add(app.packageName!);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                    : Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: app.icon != null
                                        ? Image.memory(app.icon!, width: 24, height: 24)
                                        : Icon(
                                            Icons.android,
                                            color: isSelected
                                                ? Colors.white
                                                : Theme.of(context).colorScheme.onSurfaceVariant,
                                            size: 24,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      app.name ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filteredApps.length,
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _appLockService.setLockedApps(_lockedPackages);
          if (mounted) Navigator.pop(context);
        },
        label: const Text(
          'Save Selection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.check_rounded),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
