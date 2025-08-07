import 'package:debt_manager_frontend/models/user.dart';
import 'package:debt_manager_frontend/providers/user_provider.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/widgets/user_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomersScreen extends StatefulWidget {
  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadCustomers();
    });
  }

  Future<void> _addCustomer() async {
    final result = await showSearch<User?>(
      context: context,
      delegate: UserSearchDelegate(
        userProvider: Provider.of<UserProvider>(context, listen: false),
      ),
    );

    if (result != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final error = await userProvider.addCustomer(result.id);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.errorColor),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer added successfully'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }

  Future<void> _removeCustomer(User customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Remove Customer'),
            content: Text(
              'Are you sure you want to remove ${customer.fullName} from your customers list?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Remove',
                  style: TextStyle(color: AppColors.errorColor),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final error = await userProvider.removeCustomer(customer.id);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.errorColor),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer removed successfully'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoadingCustomers) {
            return Center(child: CircularProgressIndicator());
          }

          if (userProvider.customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No customers added yet',
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addCustomer,
                    child: Text('Add Customer'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => userProvider.loadCustomers(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: userProvider.customers.length,
              itemBuilder: (context, index) {
                final customer = userProvider.customers[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        customer.fullName.substring(0, 1).toUpperCase(),
                      ),
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    title: Text(customer.fullName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@${customer.username}'),
                        if (customer.phoneNumber != null)
                          Text(customer.phoneNumber!),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(
                                  Icons.delete,
                                  color: AppColors.errorColor,
                                ),
                                title: Text('Remove'),
                                dense: true,
                              ),
                              onTap: () => _removeCustomer(customer),
                            ),
                          ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        child: Icon(Icons.person_add),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}
