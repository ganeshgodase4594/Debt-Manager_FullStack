import 'package:debt_manager_frontend/providers/auth_provider.dart';
import 'package:debt_manager_frontend/screens/login_screen.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/widgets/gradient_button.dart';
import 'package:debt_manager_frontend/widgets/gradient_card.dart';
import 'package:debt_manager_frontend/widgets/modern_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final error = await authProvider.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phoneNumber:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
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
      } else {
        // Navigate to login screen instead of just popping back
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
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
                SizedBox(height: 40),
                // Header Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [AppShadows.cardShadow],
                        ),
                        child: Icon(
                          Icons.person_add,
                          size: 32,
                          color: AppColors.primaryPink,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Create Account',
                        style: AppTextStyles.headline2.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Join us to manage your finances',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                
                // Registration Form Card
                GradientCard(
                  padding: EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: AppTextStyles.headline3,
                        ),
                        SizedBox(height: 24),
                        
                        ModernTextField(
                          controller: _fullNameController,
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        
                        ModernTextField(
                          controller: _usernameController,
                          labelText: 'Username',
                          hintText: 'Choose a username',
                          prefixIcon: Icons.account_circle_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        
                        ModernTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        
                        ModernTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number (optional)',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 24),
                        
                        Text(
                          'Security',
                          style: AppTextStyles.headline3,
                        ),
                        SizedBox(height: 20),
                        
                        ModernTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Create a secure password',
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
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        
                        ModernTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _isConfirmPasswordVisible 
                              ? Icons.visibility_off_outlined 
                              : Icons.visibility_outlined,
                          obscureText: !_isConfirmPasswordVisible,
                          onSuffixIconTap: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32),
                        
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return GradientButton(
                              text: 'Create Account',
                              width: double.infinity,
                              isLoading: authProvider.isLoading,
                              onPressed: authProvider.isLoading ? null : _register,
                              icon: Icons.person_add,
                            );
                          },
                        ),
                        SizedBox(height: 24),
                        
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: AppTextStyles.body2,
                                children: [
                                  TextSpan(
                                    text: 'Sign in',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
