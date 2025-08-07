import 'package:debt_manager_frontend/models/expense.dart';
import 'package:debt_manager_frontend/models/user.dart';
import 'package:debt_manager_frontend/providers/auth_provider.dart';
import 'package:debt_manager_frontend/services/api_service.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  final AuthProvider? _authProvider;

  ExpenseProvider({AuthProvider? authProvider}) : _authProvider = authProvider;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  List<Expense> get createdExpenses =>
      _expenses.where((e) => e.creator.id == getCurrentUserId()).toList();

  List<Expense> get debtorExpenses =>
      _expenses.where((e) => e.debtor.id == getCurrentUserId()).toList();

  int getCurrentUserId() {
    // Get the current user ID from AuthProvider
    return _authProvider?.user?.id ?? -1;
  }

  Future<String?> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get<List<dynamic>>(
        '/expenses',
        (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        _expenses =
            response.data!.map((json) => Expense.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return null;
      } else {
        _isLoading = false;
        notifyListeners();
        return response.message;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Failed to load expenses: $e';
    }
  }

  Future<String?> createExpense({
    required String description,
    required double amount,
    required int debtorId,
    DateTime? dueDate,
    String? notes,
  }) async {
    try {
      final response =
          await ApiService.post<Map<String, dynamic>>('/expenses', {
            'description': description,
            'amount': amount,
            'debtor_id': debtorId,
            'due_date': dueDate?.toIso8601String(),
            'notes': notes,
          }, (data) => data as Map<String, dynamic>);

      if (response.success && response.data != null) {
        // Reload all expenses to ensure UI is updated with latest data
        await loadExpenses();
        return null;
      } else {
        return response.message;
      }
    } catch (e) {
      return 'Failed to create expense: $e';
    }
  }

  Future<String?> updateExpense({
    required int expenseId,
    required String description,
    required double amount,
    required int debtorId,
    DateTime? dueDate,
    String? notes,
    ExpenseStatus? status,
  }) async {
    try {
      final response =
          await ApiService.put<Map<String, dynamic>>('/expenses/$expenseId', {
            'description': description,
            'amount': amount,
            'debtor_id': debtorId,
            'due_date': dueDate?.toIso8601String(),
            'notes': notes,
            'status': status?.toString().split('.').last,
          }, (data) => data as Map<String, dynamic>);

      if (response.success && response.data != null) {
        // Reload all expenses to ensure UI is updated with latest data
        await loadExpenses();
        return null;
      } else {
        return response.message;
      }
    } catch (e) {
      return 'Failed to update expense: $e';
    }
  }

  Future<String?> deleteExpense(int expenseId) async {
    try {
      final response = await ApiService.delete('/expenses/$expenseId');

      if (response.success) {
        // Reload all expenses to ensure UI is updated with latest data
        await loadExpenses();
        return null;
      } else {
        return response.message;
      }
    } catch (e) {
      return 'Failed to delete expense: $e';
    }
  }
}
