import 'package:debt_manager_frontend/models/expense.dart';
import 'package:debt_manager_frontend/providers/expense_provider.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/widgets/dashboard_stat.dart';
import 'package:debt_manager_frontend/widgets/expense_list.dart';
import 'package:debt_manager_frontend/widgets/gradient_card.dart';
import 'package:debt_manager_frontend/widgets/date_range_picker.dart';
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
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      // Set default date range to last 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(Duration(days: 7));
      expenseProvider.setDateRange(DateTimeRange(start: sevenDaysAgo, end: now));
      expenseProvider.loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        if (expenseProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final createdExpenses = expenseProvider.dashboardCreatedExpenses;
        final debtorExpenses = expenseProvider.dashboardDebtorExpenses;

        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: RefreshIndicator(
            onRefresh: () => expenseProvider.loadExpenses(),
            color: AppColors.primaryPink,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  // Date Range Selector
                  Consumer<ExpenseProvider>(
                    builder: (context, provider, _) {
                      final dateRange = provider.dateRange ?? DateTimeRange(
                        start: DateTime.now().subtract(Duration(days: 7)),
                        end: DateTime.now(),
                      );
                      return DateRangeSelector(
                        selectedRange: dateRange,
                        onRangeChanged: (range) {
                          provider.setDateRange(range);
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  DashboardStats(),
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ExpenseList(
                      title: 'Recent Expenses (Created)',
                      expenses: createdExpenses,
                      showAll: false,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ExpenseList(
                      title: 'Recent Expenses (Owed)',
                      expenses: debtorExpenses,
                      showAll: false,
                      showCreditor: true,
                    ),
                  ),
                  SizedBox(height: 100), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
