import 'package:debt_manager_frontend/providers/auth_provider.dart';
import 'package:debt_manager_frontend/providers/expense_provider.dart';
import 'package:debt_manager_frontend/providers/user_provider.dart';

import 'package:debt_manager_frontend/screens/home_screen.dart';
import 'package:debt_manager_frontend/screens/login_screen.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update:
              (_, authProvider, previousExpenseProvider) =>
                  ExpenseProvider(authProvider: authProvider),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Debt Manager',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: AppColors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.darkText,
            elevation: 0,
            titleTextStyle: AppTextStyles.headline3,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primaryPink,
            unselectedItemColor: AppColors.lightText,
            elevation: 8,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isAuthenticated) {
              return HomeScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
