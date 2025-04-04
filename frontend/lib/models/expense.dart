import 'package:intl/intl.dart';
import 'category.dart';

class Expense {
  final int? id;
  final double amount;
  final String description;
  final DateTime date;
  final int categoryId;
  final Category? category;
  final DateTime? createdAt;

  Expense({
    this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    this.category,
    this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'],
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      categoryId: json['category_id'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': formatter.format(date),
      'category_id': categoryId,
    };
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
