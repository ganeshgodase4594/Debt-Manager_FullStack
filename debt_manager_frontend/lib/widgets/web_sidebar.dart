import 'package:debt_manager_frontend/providers/auth_provider.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WebSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const WebSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(context),
          Divider(),
          _buildNavItem(
            context,
            index: 0,
            icon: Icons.dashboard,
            title: 'Dashboard',
          ),
          _buildNavItem(
            context,
            index: 1,
            icon: Icons.receipt_long,
            title: 'Expenses',
          ),
          _buildNavItem(
            context,
            index: 2,
            icon: Icons.people,
            title: 'Customers',
          ),

          Spacer(),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryColor,
                child: Text(
                  authProvider.user?.fullName.substring(0, 1).toUpperCase() ??
                      'U',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              Text(
                authProvider.user?.fullName ?? 'User',
                style: AppTextStyles.headline2,
              ),
              Text(
                '@${authProvider.user?.username ?? ''}',
                style: AppTextStyles.body2,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryColor : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryColor : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () => onItemSelected(index),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return ListTile(
          leading: Icon(Icons.logout, color: Colors.grey[600]),
          title: Text('Logout'),
          onTap: () => authProvider.logout(),
        );
      },
    );
  }
}
