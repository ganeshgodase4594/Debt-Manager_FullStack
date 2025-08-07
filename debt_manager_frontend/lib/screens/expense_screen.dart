import 'package:debt_manager_frontend/models/expense.dart';
import 'package:debt_manager_frontend/providers/expense_provider.dart';
import 'package:debt_manager_frontend/screens/create_expense_screen.dart';
import 'package:debt_manager_frontend/screens/edit_expense_screen.dart';
import 'package:debt_manager_frontend/utils/constants.dart';
import 'package:debt_manager_frontend/widgets/expense_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          title: Text('Expenses'),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            tabs: [Tab(text: 'Created by Me'), Tab(text: 'I Owe')],
          ),
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          if (expenseProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildExpensesList(expenseProvider.createdExpenses, 'created'),
              _buildExpensesList(expenseProvider.debtorExpenses, 'debtor'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateExpenseScreen()),
          );

          if (result == true) {
            // Refresh expenses when returning from create screen
            Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
          }
        },
        backgroundColor: AppColors.primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses, String type) {
    final currentUserId =
        Provider.of<ExpenseProvider>(context, listen: false).getCurrentUserId();
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'created' ? Icons.receipt_long : Icons.payment,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              type == 'created' ? 'No expenses created yet' : 'No debts owed',
              style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          () =>
              Provider.of<ExpenseProvider>(
                context,
                listen: false,
              ).loadExpenses(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ExpenseCard(
            expense: expense,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditExpenseScreen(expense: expense),
                ),
              );

              if (result == true) {
                // Refresh expenses when returning from edit screen
                Provider.of<ExpenseProvider>(
                  context,
                  listen: false,
                ).loadExpenses();
              }
            },
            onDelete: type == 'created' ? () => _deleteExpense(expense) : null,
            currentUserId: currentUserId,
            showCreditor: type == 'debtor',
          );
        },
      ),
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
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
