import 'package:debt_manager_frontend/models/expense.dart';
import 'package:debt_manager_frontend/providers/expense_provider.dart';
import 'package:debt_manager_frontend/screens/edit_expense_screen.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/widgets/expense_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseList extends StatelessWidget {
  final String title;
  final List<Expense> expenses;
  final bool showAll;
  final bool showCreditor;

  const ExpenseList({
    Key? key,
    required this.title,
    required this.expenses,
    this.showAll = false,
    this.showCreditor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayExpenses = showAll ? expenses : expenses.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryPink.withOpacity(0.05),
                AppColors.primaryOrange.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryPink.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    title,
                    style: AppTextStyles.headline2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (!showAll && expenses.length > 3)
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/expenses');
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (displayExpenses.isEmpty)
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No expenses found',
                    style: AppTextStyles.headline3.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Create your first expense to get started',
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayExpenses.length,
            itemBuilder: (context, index) {
              final expense = displayExpenses[index];
              return ExpenseCard(
                expense: expense,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditExpenseScreen(expense: expense),
                    ),
                  );
                },
                onDelete: () => _deleteExpense(context, expense),
                showCreditor: showCreditor,
              );
            },
          ),
      ],
    );
  }

  Future<void> _deleteExpense(BuildContext context, Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Expense'),
            content: Text(
              'Are you sure you want to delete "${expense.description}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppColors.errorColor),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );
      final error = await expenseProvider.deleteExpense(expense.id);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.errorColor),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense deleted successfully'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
  }
}
