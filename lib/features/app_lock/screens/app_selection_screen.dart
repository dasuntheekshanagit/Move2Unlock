import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import '../../app_lock/services/app_lock_service.dart';
import 'limit_settings_screen.dart';

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
    await _appLockService.init();
    final apps = await _appLockService.getInstalledApps();

    // Sort apps alphabetically
    apps.sort(
      (a, b) =>
          (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()),
    );

    // Get currently locked packages
    final locked = _appLockService.lockedPackages;

    if (mounted) {
      setState(() {
        _installedApps = apps;
        _lockedPackages = List.from(locked);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredApps = _installedApps.where((app) {
      return (app.name ?? '').toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();

    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 100.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                    title: Text(
                      'Select Apps',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onBackground,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: theme.colorScheme.onBackground,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search apps...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        fillColor: theme.cardTheme.color,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final app = filteredApps[index];
                      final isSelected = _lockedPackages.contains(
                        app.packageName,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        theme.colorScheme.primary.withOpacity(
                                          0.12,
                                        ),
                                        theme.colorScheme.primary.withOpacity(
                                          0.03,
                                        ),
                                      ],
                                    )
                                  : null,
                              color: isSelected ? null : theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary.withOpacity(0.3)
                                    : theme.colorScheme.primary.withOpacity(
                                        0.1,
                                      ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? theme.colorScheme.primary.withOpacity(
                                          0.1,
                                        )
                                      : Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: app.icon != null
                                      ? Image.memory(
                                          app.icon!,
                                          width: 20,
                                          height: 20,
                                        )
                                      : Icon(
                                          Icons.android,
                                          color: isSelected
                                              ? Colors.white
                                              : theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          size: 20,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.name ?? 'Unknown',
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.onSurface,
                                              fontSize: 14,
                                            ),
                                      ),
                                      if (isSelected)
                                        Text(
                                          'Tap to configure limits',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.5),
                                                fontSize: 10,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  IconButton(
                                    icon: Icon(
                                      Icons.settings_outlined,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LimitSettingsScreen(
                                                appName: app.name,
                                              ),
                                        ),
                                      );
                                    },
                                  )
                                else
                                  Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 20,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.5),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: filteredApps.length),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        icon: const Icon(Icons.check_rounded, size: 20),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
