import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses {
    return [..._expenses];
  }

  bool get isLoading {
    return _isLoading;
  }

  String? get error {
    return _error;
  }

  // Get expenses by category
  List<Expense> getExpensesByCategory(int categoryId) {
    return _expenses.where((exp) => exp.categoryId == categoryId).toList();
  }

  // Get expense by id
  Expense? getExpenseById(int id) {
    try {
      return _expenses.firstWhere((exp) => exp.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get total expenses amount
  double get totalAmount {
    return _expenses.fold(0.0, (sum, exp) => sum + exp.amount);
  }

  // Get total expenses by category
  Map<int, double> get expensesByCategory {
    final Map<int, double> result = {};

    for (var expense in _expenses) {
      if (result.containsKey(expense.categoryId)) {
        result[expense.categoryId] =
            result[expense.categoryId]! + expense.amount;
      } else {
        result[expense.categoryId] = expense.amount;
      }
    }

    return result;
  }

  // Fetch all expenses
  Future<void> fetchExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final expensesData = await ApiService.getExpenses();

      _expenses =
          expensesData.map<Expense>((expData) {
            return Expense.fromJson(expData);
          }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Fetch a specific expense
  Future<Expense> fetchExpense(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final expenseData = await ApiService.getExpense(id);

      final expense = Expense.fromJson(expenseData);

      _isLoading = false;
      notifyListeners();

      return expense;
    } catch (error) {
      _isLoading = false;
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Add a new expense
  Future<void> addExpense(Expense newExpense) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createExpense(newExpense.toJson());

      final addedExpense = Expense.fromJson(response);
      _expenses.add(addedExpense);

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update an expense
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateExpense(
        id,
        updatedExpense.toJson(),
      );

      final expenseIndex = _expenses.indexWhere((exp) => exp.id == id);
      if (expenseIndex >= 0) {
        _expenses[expenseIndex] = Expense.fromJson(response);
      }

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete an expense
  Future<void> deleteExpense(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.deleteExpense(id);

      _expenses.removeWhere((exp) => exp.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Reset loading and error states
  void resetState() {
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
