import 'package:debt_manager_frontend/providers/auth_provider.dart';
import 'package:debt_manager_frontend/screens/register_screen.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/widgets/gradient_button.dart';
import 'package:debt_manager_frontend/widgets/gradient_card.dart';
import 'package:debt_manager_frontend/widgets/modern_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final error = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 60),
                // Logo and Welcome Section
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [AppShadows.cardShadow],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/login.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.account_balance_wallet,
                                size: 48,
                                color: AppColors.primaryPink,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Debt Manager',
                        style: AppTextStyles.headline1.copyWith(
                          color: AppColors.white,
                          fontSize: 28,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Manage your finances with ease',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                
                // Login Form Card
                GradientCard(
                  padding: EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: AppTextStyles.headline2,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sign in to your account',
                          style: AppTextStyles.body2,
                        ),
                        SizedBox(height: 32),
                        
                        ModernTextField(
                          controller: _usernameController,
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        
                        ModernTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _isPasswordVisible 
                              ? Icons.visibility_off_outlined 
                              : Icons.visibility_outlined,
                          obscureText: !_isPasswordVisible,
                          onSuffixIconTap: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32),
                        
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return GradientButton(
                              text: 'Sign In',
                              width: double.infinity,
                              isLoading: authProvider.isLoading,
                              onPressed: authProvider.isLoading ? null : _login,
                              icon: Icons.login,
                            );
                          },
                        ),
                        SizedBox(height: 24),
                        
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: AppTextStyles.body2,
                                children: [
                                  TextSpan(
                                    text: 'Sign up',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.primaryPink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
