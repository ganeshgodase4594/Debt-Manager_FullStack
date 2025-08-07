import 'dart:convert';

import 'package:debt_manager_frontend/models/user.dart';
import 'package:debt_manager_frontend/services/api_service.dart';
import 'package:debt_manager_frontend/services/storage_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await StorageService.getToken();
    final userData = await StorageService.getUserData();

    if (token != null && userData != null) {
      try {
        _user = User.fromJson(json.decode(userData));
        _isAuthenticated = true;
        ApiService.setToken(token);
        notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }

  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post<Map<String, dynamic>>(
        '/auth/login',
        {'username': username, 'password': password},
        (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'];
        final userData = {
          'id': response.data!['user_id'],
          'username': response.data!['username'],
          'email': response.data!['email'],
          'full_name': response.data!['full_name'],
        };

        await StorageService.saveToken(token);
        await StorageService.saveUserData(json.encode(userData));

        _user = User.fromJson(userData);
        _isAuthenticated = true;
        ApiService.setToken(token);

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
      return 'Login failed: $e';
    }
  }

  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await ApiService.post<Map<String, dynamic>>('/auth/register', {
            'username': username,
            'email': email,
            'password': password,
            'full_name': fullName,
            'phone_number': phoneNumber,
          }, (data) => data as Map<String, dynamic>);

      if (response.success && response.data != null) {
        final token = response.data!['token'];
        final userData = {
          'id': response.data!['user_id'],
          'username': response.data!['username'],
          'email': response.data!['email'],
          'full_name': response.data!['full_name'],
        };

        await StorageService.saveToken(token);
        await StorageService.saveUserData(json.encode(userData));

        _user = User.fromJson(userData);
        _isAuthenticated = true;
        ApiService.setToken(token);

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
      return 'Registration failed: $e';
    }
  }

  Future<void> logout() async {
    _user = null;
    _isAuthenticated = false;
    await StorageService.clearAll();
    ApiService.clearToken();
    notifyListeners();
  }
}
