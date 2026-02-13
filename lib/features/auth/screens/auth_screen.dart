import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../paywall/screens/paywall_screen.dart';
import '../../../core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignIn = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Simulate login/signup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.isNotEmpty ? _nameController.text : 'User');
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PaywallScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Top Illustration Area
                    CustomPaint(
                      size: const Size(200, 150),
                      painter: BlobPainter(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                      child: const SizedBox(
                        width: 200,
                        height: 150,
                        child: Center(
                          child: Icon(
                            Icons.lock_clock_rounded,
                            size: 64,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Move2Unlock',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Turn your steps into screen time.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Tab Switcher
                    Container(
                      height: 56,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceDark : AppTheme.inputFillLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            alignment: _isSignIn ? Alignment.centerLeft : Alignment.centerRight,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 56) / 2,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isSignIn = true),
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Text(
                                      'Sign In',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: _isSignIn 
                                            ? AppTheme.textPrimaryLight 
                                            : AppTheme.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isSignIn = false),
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: !_isSignIn 
                                            ? AppTheme.textPrimaryLight 
                                            : AppTheme.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Form
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isSignIn
                          ? _buildSignInForm(theme)
                          : _buildSignUpForm(theme),
                    ),

                    const SizedBox(height: 32),
                    _buildSocialLogin(theme, isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignInForm(ThemeData theme) {
    return Column(
      key: const ValueKey('signin'),
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'Email address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, 
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FilledButton(
            onPressed: _submit,
            child: const Text('Sign In'),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(ThemeData theme) {
    return Column(
      key: const ValueKey('signup'),
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'Email address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FilledButton(
            onPressed: _submit,
            child: const Text('Create Account'),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: theme.dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR CONTINUE WITH',
                style: GoogleFonts.inter(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            Expanded(child: Divider(color: theme.dividerColor)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.apple, theme, isDark, isDark ? Colors.white : Colors.black),
            const SizedBox(width: 20),
            _buildSocialButton(Icons.g_mobiledata, theme, isDark, Colors.red),
            const SizedBox(width: 20),
            _buildSocialButton(Icons.facebook, theme, isDark, Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, ThemeData theme, bool isDark, Color iconColor) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          shape: BoxShape.circle,
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 28, color: iconColor),
      ),
    );
  }
}

class BlobPainter extends CustomPainter {
  final Color color;

  BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    
    path.moveTo(size.width * 0.2, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width * 0.8, size.height * 0.2);
    path.quadraticBezierTo(size.width, size.height * 0.5, size.width * 0.8, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width * 0.2, size.height * 0.8);
    path.quadraticBezierTo(0, size.height * 0.5, size.width * 0.2, size.height * 0.2);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
