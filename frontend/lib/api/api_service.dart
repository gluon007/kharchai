import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String baseUrl =
      dotenv.env['API_URL'] ?? 'http://localhost:5000/api/v1';

  // Headers with authentication token
  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Error handling
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      Map<String, dynamic> error = {};
      try {
        error = json.decode(response.body);
      } catch (_) {
        error = {'message': 'Something went wrong'};
      }
      throw error['message'] ?? 'Error: ${response.statusCode}';
    }
  }

  // Authentication Endpoints
  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _getHeaders(),
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _getHeaders(),
      body: json.encode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  // Category Endpoints
  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getCategory(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$id'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  // Expense Endpoints
  static Future<List<dynamic>> getExpenses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getExpense(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses/$id'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> createExpense(
    Map<String, dynamic> expenseData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: await _getHeaders(),
      body: json.encode(expenseData),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateExpense(
    int id,
    Map<String, dynamic> expenseData,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/expenses/$id'),
      headers: await _getHeaders(),
      body: json.encode(expenseData),
    );
    return _handleResponse(response);
  }

  static Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/expenses/$id'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }
}
