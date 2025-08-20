import 'package:debt_manager_frontend/models/expense.dart';
import 'package:debt_manager_frontend/providers/expense_provider.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/widgets/gradient_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        final createdExpenses = expenseProvider.dashboardCreatedExpenses;
        final debtorExpenses = expenseProvider.dashboardDebtorExpenses;

        double totalCreated = createdExpenses
            .where((e) => e.status != ExpenseStatus.CANCELLED)
            .fold(0, (sum, e) => sum + e.amount);

        double totalOwed = debtorExpenses
            .where((e) => e.status != ExpenseStatus.CANCELLED)
            .fold(0, (sum, e) => sum + e.amount);

        double totalPendingCreated = createdExpenses
            .where((e) => e.status == ExpenseStatus.PENDING)
            .fold(0, (sum, e) => sum + e.amount);

        double totalPendingOwed = debtorExpenses
            .where((e) => e.status == ExpenseStatus.PENDING)
            .fold(0, (sum, e) => sum + e.amount);

        return Padding(
          padding: EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // For wider screens, use a row layout with all stats in one row
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total Created',
                        value: 'Rs. ${totalCreated.toStringAsFixed(2)}',
                        icon: Icons.add_circle_outline,
                        iconColor: AppColors.primaryPink,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Total Owed',
                        value: 'Rs. ${totalOwed.toStringAsFixed(2)}',
                        icon: Icons.remove_circle_outline,
                        iconColor: AppColors.warningColor,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Pending (Created)',
                        value: 'Rs. ${totalPendingCreated.toStringAsFixed(2)}',
                        icon: Icons.schedule,
                        iconColor: AppColors.successColor,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Pending (Owed)',
                        value: 'Rs. ${totalPendingOwed.toStringAsFixed(2)}',
                        icon: Icons.schedule,
                        iconColor: AppColors.errorColor,
                      ),
                    ),
                  ],
                );
              } else {
                // For mobile screens, use a column layout with two rows
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total Created',
                            value: 'Rs. ${totalCreated.toStringAsFixed(2)}',
                            icon: Icons.add_circle_outline,
                            iconColor: AppColors.primaryPink,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Total Owed',
                            value: 'Rs. ${totalOwed.toStringAsFixed(2)}',
                            icon: Icons.remove_circle_outline,
                            iconColor: AppColors.warningColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Pending (Created)',
                            value: 'Rs. ${totalPendingCreated.toStringAsFixed(2)}',
                            icon: Icons.schedule,
                            iconColor: AppColors.successColor,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Pending (Owed)',
                            value: 'Rs. ${totalPendingOwed.toStringAsFixed(2)}',
                            icon: Icons.schedule,
                            iconColor: AppColors.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(
                  value,
                  style: AppTextStyles.headline2.copyWith(color: color),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(title, style: AppTextStyles.body2),
          ],
        ),
      ),
    );
  }
}
