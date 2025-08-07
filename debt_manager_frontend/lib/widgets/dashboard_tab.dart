import 'package:debt_manager_frontend/models/expense.dart';
import 'package:debt_manager_frontend/providers/expense_provider.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/widgets/dashboard_stat.dart';
import 'package:debt_manager_frontend/widgets/expense_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardTab extends StatefulWidget {
  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        if (expenseProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final createdExpenses = expenseProvider.createdExpenses;
        final debtorExpenses = expenseProvider.debtorExpenses;

        return RefreshIndicator(
          onRefresh: () => expenseProvider.loadExpenses(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardStats(),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ExpenseList(
                    title: 'Recent Expenses (Created)',
                    expenses: createdExpenses,
                    showAll: false,
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ExpenseList(
                    title: 'Recent Expenses (Owed)',
                    expenses: debtorExpenses,
                    showAll: false,
                    showCreditor: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
