import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/api_response.dart';

class ApiService {
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> _getHeaders() {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  static Future<ApiResponse<T>> get<T>(
    String endpoint,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonResponse, fromJson);
      } else {
        return ApiResponse<T>(
          success: false,
          message: jsonResponse['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      return ApiResponse<T>(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> data,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: json.encode(data),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonResponse, fromJson);
      } else {
        return ApiResponse<T>(
          success: false,
          message: jsonResponse['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      return ApiResponse<T>(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> data,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: json.encode(data),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonResponse, fromJson);
      } else {
        return ApiResponse<T>(
          success: false,
          message: jsonResponse['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      return ApiResponse<T>(success: false, message: 'Network error: $e');
    }
  }

  static Future<ApiResponse<String>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: _getHeaders(),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<String>(
          success: true,
          message: jsonResponse['message'] ?? 'Success',
          data: jsonResponse['data'],
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: jsonResponse['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      return ApiResponse<String>(success: false, message: 'Network error: $e');
    }
  }
}
