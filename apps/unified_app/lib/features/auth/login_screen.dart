import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  UserRole? selectedLoginRole;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Cloud Background
          _buildCloudBackground(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 40),

                  _buildLoginForm(),

                  const SizedBox(height: 24),

                  _buildRoleSelector(),

                  const SizedBox(height: 32),

                  _buildLoginButton(authState),

                  const SizedBox(height: 24),

                  _buildAlternativeActions(),

                  const SizedBox(height: 32),

                  _buildNewUserSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    final currentTheme = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          final themeNotifier = ref.read(themeProvider.notifier);
          switch (currentTheme) {
            case AppThemeMode.light:
              themeNotifier.setTheme(AppThemeMode.dark);
              break;
            case AppThemeMode.dark:
              themeNotifier.setTheme(AppThemeMode.system);
              break;
            case AppThemeMode.system:
              themeNotifier.setTheme(AppThemeMode.light);
              break;
          }
        },
        icon: Icon(
          currentTheme == AppThemeMode.light
              ? Icons.light_mode
              : currentTheme == AppThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.brightness_auto,
          color: AppColors.primary,
        ),
        tooltip: currentTheme == AppThemeMode.light
            ? 'Switch to Dark Mode'
            : currentTheme == AppThemeMode.dark
                ? 'Switch to System Mode'
                : 'Switch to Light Mode',
      ),
    );
  }

  Widget _buildCloudBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea), // Light blue
            Color(0xFF764ba2), // Purple
            Color(0xFF667eea), // Light blue
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated floating elements
          ..._buildFloatingElements(),

          // Glass morphism overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return List.generate(12, (index) {
      return Positioned(
        top: (index * 67 + 50) % 600.0,
        left: (index * 97 + 30) % 350.0,
        child: _buildFloatingElement(index),
      );
    });
  }

  Widget _buildFloatingElement(int index) {
    final isCircle = index % 3 == 0;
    final isSquare = index % 3 == 1;
    final size = 30.0 + (index % 4) * 15.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : (isSquare ? BorderRadius.circular(8) : BorderRadius.circular(size / 2)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48), // For balance
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/rwa_logo.png',
                height: 44,
                filterQuality: FilterQuality.high,
              ),
            ),
            _buildThemeToggle(),
          ],
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'Welcome Back',
          style: AppTextStyles.heading1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Sign in to continue to your RWA Platform',
          style: AppTextStyles.body1.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email address',
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Colors.white.withOpacity(0.8),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.lock_outlined,
                color: Colors.white.withOpacity(0.8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white.withOpacity(0.8),
                ),
                onPressed: () => setState(() {
                  _obscurePassword = !_obscurePassword;
                }),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Remember Me & Forgot Password
          Row(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  checkboxTheme: CheckboxThemeData(
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white.withOpacity(0.9);
                      }
                      return Colors.transparent;
                    }),
                    checkColor: WidgetStateProperty.all(const Color(0xFF667eea)),
                    side: BorderSide(color: Colors.white.withOpacity(0.6), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) => setState(() {
                    _rememberMe = value ?? false;
                  }),
                ),
              ),
              Text(
                'Remember me',
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: () => context.push('/forgot-password'),
                style: TextButton.styleFrom(
                  overlayColor: Colors.white.withOpacity(0.1),
                ),
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'Login as:',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Role Selection Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3.5,
          children: [
            _buildRoleOption(
              UserRole.investorAgent,
              '💰 Investor-Agent',
              'Invest & Monitor',
            ),
            _buildRoleOption(
              UserRole.professionalAgent,
              '🏆 Professional Agent',
              'Expert Verification',
            ),
            _buildRoleOption(
              UserRole.verifier,
              '📸 Verifier',
              'On-demand Tasks',
            ),
            _buildRoleOption(
              UserRole.admin,
              '⚖️ Admin',
              'Platform Management',
            ),
            _buildRoleOption(
              UserRole.superAdmin,
              '👑 Super Admin',
              'System Control',
            ),
            _buildRoleOption(
              UserRole.merchantWhiteLabel,
              '🏦 Bank Partner',
              'Banking Services',
            ),
          ],
        ),
        
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select your primary role. You can switch roles anytime from your profile.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Demo Credentials:',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildDemoCredentialButton('investor@example.com', 'password123', UserRole.investorAgent),
                  _buildDemoCredentialButton('admin@example.com', 'password123', UserRole.admin),
                  _buildDemoCredentialButton('agent@example.com', 'password123', UserRole.professionalAgent),
                  _buildDemoCredentialButton('verifier@example.com', 'password123', UserRole.verifier),
                  _buildDemoCredentialButton('superadmin@example.com', 'password123', UserRole.superAdmin),
                  _buildDemoCredentialButton('merchant@example.com', 'password123', UserRole.merchantWhiteLabel),
                  _buildDemoCredentialButton('merchantadmin@example.com', 'password123', UserRole.merchantAdmin),
                  _buildDemoCredentialButton('merchantops@example.com', 'password123', UserRole.merchantOperations),
                ],
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(UserRole role, String title, String subtitle) {
    final isSelected = selectedLoginRole == role;

    return GestureDetector(
      onTap: () => setState(() {
        selectedLoginRole = role;
      }),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCredentialButton(String email, String password, UserRole role) {
    String roleLabel;
    switch (role) {
      case UserRole.investorAgent:
        roleLabel = 'Investor';
        break;
      case UserRole.admin:
        roleLabel = 'Admin';
        break;
      case UserRole.professionalAgent:
        roleLabel = 'Agent';
        break;
      case UserRole.verifier:
        roleLabel = 'Verifier';
        break;
      case UserRole.superAdmin:
        roleLabel = 'Super Admin';
        break;
      case UserRole.merchantWhiteLabel:
        roleLabel = 'Bank Partner';
        break;
      case UserRole.merchantAdmin:
        roleLabel = 'Bank Admin';
        break;
      case UserRole.merchantOperations:
        roleLabel = 'Bank Operations';
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
          selectedLoginRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          roleLabel,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(AuthState authState) {
    final isLoading = authState.isLoading;
    final canLogin = selectedLoginRole != null && !isLoading;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: canLogin
            ? const LinearGradient(
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: !canLogin ? Colors.white.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: canLogin
            ? [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canLogin ? _handleLogin : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Sign In',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeActions() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Biometric Login (if available)
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleBiometricLogin,
              borderRadius: BorderRadius.circular(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint,
                    color: Colors.white.withOpacity(0.9),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Use Biometric Login',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewUserSection() {
    return Column(
      children: [
        // Divider
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),

        Text(
          'New to RWA Platform?',
          style: AppTextStyles.body1.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/role-selection'),
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: Text(
                  'Create New Account',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Join thousands of investors and agents in the future of RWA investment',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate() || selectedLoginRole == null) {
      return;
    }

    try {
      await ref.read(authProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: selectedLoginRole!,
        rememberMe: _rememberMe,
      );

      if (mounted) {
        // Navigate based on user role
        switch (selectedLoginRole!) {
          case UserRole.superAdmin:
            context.go('/super-admin');
            break;
          case UserRole.admin:
            context.go('/admin');
            break;
          default:
            context.go('/dashboard');
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    // Implement biometric authentication
    try {
      await ref.read(authProvider.notifier).loginWithBiometrics();
      
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric login failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}