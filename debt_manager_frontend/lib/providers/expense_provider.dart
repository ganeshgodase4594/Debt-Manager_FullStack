import 'package:debt_manager_frontend/models/expense.dart';
import 'package:debt_manager_frontend/models/user.dart';
import 'package:debt_manager_frontend/providers/auth_provider.dart';
import 'package:debt_manager_frontend/services/api_service.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/material.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  final AuthProvider? _authProvider;
  DateTimeRange? _dateRange;
  
  // Search functionality
  List<User> _searchResults = [];
  bool _isSearching = false;

  ExpenseProvider({AuthProvider? authProvider}) : _authProvider = authProvider;

  // Unfiltered expenses for expense screen (shows all data)
  List<Expense> get expenses => _expenses;
  List<Expense> get createdExpenses => _expenses
      .where((e) => e.creator.id == getCurrentUserId()).toList();
  List<Expense> get debtorExpenses => _expenses
      .where((e) => e.debtor.id == getCurrentUserId()).toList();

  // Filtered expenses for dashboard (respects date range)
  List<Expense> get dashboardExpenses => _getFilteredExpenses();
  List<Expense> get dashboardCreatedExpenses => _getFilteredExpenses()
      .where((e) => e.creator.id == getCurrentUserId()).toList();
  List<Expense> get dashboardDebtorExpenses => _getFilteredExpenses()
      .where((e) => e.debtor.id == getCurrentUserId()).toList();

  bool get isLoading => _isLoading;
  DateTimeRange? get dateRange => _dateRange;
  
  String? get error => _error;
  List<User> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  List<Expense> _getFilteredExpenses() {
    if (_dateRange == null) return _expenses;
    
    return _expenses.where((expense) {
      final expenseDate = expense.createdAt;
      return expenseDate.isAfter(_dateRange!.start.subtract(Duration(days: 1))) &&
             expenseDate.isBefore(_dateRange!.end.add(Duration(days: 1)));
    }).toList();
  }

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
  
  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }
  
  void clearDateRange() {
    _dateRange = null;
    notifyListeners();
  }
  
  // Search functionality
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    
    _isSearching = true;
    notifyListeners();
    
    try {
      final response = await ApiService.get<List<dynamic>>(
        '/users/search?q=$query',
        (data) => data as List<dynamic>,
      );
      
      if (response.success && response.data != null) {
        _searchResults = response.data!
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        _searchResults = [];
      }
    } catch (e) {
      _searchResults = [];
    }
    
    _isSearching = false;
    notifyListeners();
  }
  
  void clearSearchResults() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }
}
