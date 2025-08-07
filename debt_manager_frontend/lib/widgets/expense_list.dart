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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.headline2),
              if (!showAll && expenses.length > 3)
                TextButton(
                  onPressed: () {
                    // Navigate to expenses screen with specific tab
                    Navigator.pushNamed(context, '/expenses');
                  },
                  child: Text('View All'),
                ),
            ],
          ),
        ),
        if (displayExpenses.isEmpty)
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No expenses found',
                style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
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
