import 'package:debt_manager_frontend/providers/auth_provider.dart';
import 'package:debt_manager_frontend/providers/expense_provider.dart';
import 'package:debt_manager_frontend/screens/create_expense_screen.dart';
import 'package:debt_manager_frontend/screens/customer_screen.dart';
import 'package:debt_manager_frontend/screens/expense_screen.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/widgets/dashboard_tab.dart';
import 'package:debt_manager_frontend/widgets/responsive_layout.dart';
import 'package:debt_manager_frontend/widgets/web_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return DashboardTab();
      case 1:
        return ExpensesScreen();
      case 2:
        return CustomersScreen();
      default:
        return DashboardTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(),
      webBody: _buildWebLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debt Manager'),
        actions: [
          SizedBox(width: 8),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: Text(
                          authProvider.user?.fullName
                                  .substring(0, 1)
                                  .toUpperCase() ??
                              'U',
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(authProvider.user?.fullName ?? 'User'),
                    ],
                  ),
                ),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Profile'),
                          dense: true,
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Logout'),
                          dense: true,
                        ),
                        onTap: () {
                          authProvider.logout();
                        },
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryColor,
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateExpenseScreen(),
                    ),
                  );
                },
                child: Icon(Icons.add),
                backgroundColor: AppColors.primaryColor,
              )
              : null,
    );
  }

  Widget _buildWebLayout() {
    return Scaffold(
      body: Row(
        children: [
          WebSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemTapped,
          ),
          Expanded(
            child: Column(
              children: [
                _buildWebAppBar(),
                Expanded(child: _getSelectedScreen()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateExpenseScreen(),
                    ),
                  );
                },
                child: Icon(Icons.add),
                backgroundColor: AppColors.primaryColor,
              )
              : null,
    );
  }

  Widget _buildWebAppBar() {
    return Container(
      height: 64,
      color: AppColors.primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Debt Manager',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          SizedBox(width: 16),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: Text(
                          authProvider.user?.fullName
                                  .substring(0, 1)
                                  .toUpperCase() ??
                              'U',
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        authProvider.user?.fullName ?? 'User',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Profile'),
                          dense: true,
                        ),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
    );
  }
}
