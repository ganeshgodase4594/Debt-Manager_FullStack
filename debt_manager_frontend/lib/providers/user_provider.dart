// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  List<User> _searchResults = [];
  List<User> _customers = [];
  bool _isSearching = false;
  bool _isLoadingCustomers = false;

  List<User> get searchResults => _searchResults;
  List<User> get customers => _customers;
  bool get isSearching => _isSearching;
  bool get isLoadingCustomers => _isLoadingCustomers;

  Future<String?> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return null;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final response = await ApiService.get<List<dynamic>>(
        '/users/search?query=$query',
        (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        _searchResults =
            response.data!.map((json) => User.fromJson(json)).toList();
        _isSearching = false;
        notifyListeners();
        return null;
      } else {
        _isSearching = false;
        notifyListeners();
        return response.message;
      }
    } catch (e) {
      _isSearching = false;
      notifyListeners();
      return 'Search failed: $e';
    }
  }

  Future<String?> loadCustomers() async {
    _isLoadingCustomers = true;
    notifyListeners();

    try {
      final response = await ApiService.get<List<dynamic>>(
        '/customers',
        (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        _customers = response.data!.map((json) => User.fromJson(json)).toList();
        _isLoadingCustomers = false;
        notifyListeners();
        return null;
      } else {
        _isLoadingCustomers = false;
        notifyListeners();
        return response.message;
      }
    } catch (e) {
      _isLoadingCustomers = false;
      notifyListeners();
      return 'Failed to load customers: $e';
    }
  }

  Future<String?> addCustomer(int userId) async {
    try {
      final response = await ApiService.post<Map<String, dynamic>>(
        '/customers/$userId',
        {},
        (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final newCustomer = User.fromJson(response.data!);
        _customers.add(newCustomer);
        notifyListeners();
        return null;
      } else {
        return response.message;
      }
    } catch (e) {
      return 'Failed to add customer: $e';
    }
  }

  Future<String?> removeCustomer(int userId) async {
    try {
      final response = await ApiService.delete('/customers/$userId');

      if (response.success) {
        _customers.removeWhere((c) => c.id == userId);
        notifyListeners();
        return null;
      } else {
        return response.message;
      }
    } catch (e) {
      return 'Failed to remove customer: $e';
    }
  }

  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
  }
}
