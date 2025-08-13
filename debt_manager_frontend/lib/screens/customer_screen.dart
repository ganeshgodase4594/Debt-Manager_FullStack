import 'package:debt_manager_frontend/models/user.dart';
import 'package:debt_manager_frontend/models/expense.dart';
import 'package:debt_manager_frontend/providers/user_provider.dart';
import 'package:debt_manager_frontend/providers/expense_provider.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/utils/pdf_report.dart';
import 'package:debt_manager_frontend/services/api_service.dart';
import 'package:debt_manager_frontend/widgets/user_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:debt_manager_frontend/providers/auth_provider.dart';

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

  Future<void> _generateAndShareReport(
    BuildContext context,
    User customer,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final currentUserId =
          Provider.of<ExpenseProvider>(
            context,
            listen: false,
          ).getCurrentUserId();
      final currentUser =
          Provider.of<AuthProvider>(context, listen: false).user;

      if (currentUser == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not found'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }

      // Fetch expenses between users
      final expenses = await ApiService.fetchExpensesBetweenUsers(customer.id);

      // Separate expenses
      final created =
          expenses.where((e) => e.creator.id == currentUserId).toList();
      final owed = expenses.where((e) => e.debtor.id == currentUserId).toList();

      // Calculate totals (only pending expenses)
      final totalCreated = created
          .where((e) => e.status == ExpenseStatus.PENDING)
          .fold(0.0, (sum, e) => sum + e.amount);
      final totalOwed = owed
          .where((e) => e.status == ExpenseStatus.PENDING)
          .fold(0.0, (sum, e) => sum + e.amount);
      final net = totalCreated - totalOwed;

      // Generate summary
      String summary;
      if (net > 0) {
        summary = '${customer.fullName} owes you Rs. ${net.toStringAsFixed(2)}';
      } else if (net < 0) {
        summary =
            'You owe ${customer.fullName} Rs. ${(-net).toStringAsFixed(2)}';
      } else {
        summary = 'All settled! No outstanding balance.';
      }

      // Generate PDF
      final pdfBytes = await buildExpenseReportPdf(
        currentUser: currentUser,
        customer: customer,
        created: created,
        owed: owed,
        summary: summary,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Show PDF preview and sharing options
      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate report: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
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
                                  Icons.picture_as_pdf,
                                  color: AppColors.primaryColor,
                                ),
                                title: Text('Generate PDF Report'),
                                dense: true,
                              ),
                              onTap:
                                  () => _generateAndShareReport(
                                    context,
                                    customer,
                                  ),
                            ),
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
