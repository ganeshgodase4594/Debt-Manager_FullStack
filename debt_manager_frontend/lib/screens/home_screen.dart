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
        title: Text(
          'Debt Manager',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        elevation: 0,
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
                        backgroundColor: Colors.white,
                        child: Text(
                          authProvider.user?.fullName
                                  .substring(0, 1)
                                  .toUpperCase() ??
                              'U',
                          style: TextStyle(
                            color: AppColors.primaryPink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        authProvider.user?.fullName ?? 'User',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Customers',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primaryPink,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateExpenseScreen(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.add_rounded,
                    size: 28,
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
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
              ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateExpenseScreen(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.add_rounded,
                    size: 28,
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              )
              : null,
    );
  }

  Widget _buildWebAppBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Debt Manager',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
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
