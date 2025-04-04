import 'package:flutter/foundation.dart' hide Category;
import '../api/api_service.dart';
import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories {
    return [..._categories];
  }

  bool get isLoading {
    return _isLoading;
  }

  String? get error {
    return _error;
  }

  // Get a category by id
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch all categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final categoriesData = await ApiService.getCategories();

      _categories = categoriesData.map<Category>((catData) {
        return Category.fromJson(catData);
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

  // Get a specific category
  Future<Category> fetchCategory(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final categoryData = await ApiService.getCategory(id);

      final category = Category.fromJson(categoryData);

      _isLoading = false;
      notifyListeners();

      return category;
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
