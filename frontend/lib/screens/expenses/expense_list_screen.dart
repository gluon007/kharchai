import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/expense.dart';
import '../../widgets/expense_card.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      // Load categories first
      Provider.of<CategoryProvider>(context).fetchCategories().then((_) {
        // Then load expenses
        Provider.of<ExpenseProvider>(context).fetchExpenses().then((_) {
          setState(() {
            _isLoading = false;
          });
        }).catchError((error) {
          setState(() {
            _isLoading = false;
            _error = error.toString();
          });
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _error = error.toString();
        });
      });

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading expenses',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });

                        // Retry loading data
                        Provider.of<CategoryProvider>(context, listen: false)
                            .fetchCategories()
                            .then((_) {
                          Provider.of<ExpenseProvider>(context, listen: false)
                              .fetchExpenses()
                              .then((_) {
                            setState(() {
                              _isLoading = false;
                            });
                          }).catchError((error) {
                            setState(() {
                              _isLoading = false;
                              _error = error.toString();
                            });
                          });
                        }).catchError((error) {
                          setState(() {
                            _isLoading = false;
                            _error = error.toString();
                          });
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add an expense',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      try {
                        await Provider.of<ExpenseProvider>(
                          context,
                          listen: false,
                        ).fetchExpenses();
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Failed to refresh expenses'),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: expenses.length,
                      itemBuilder: (ctx, i) {
                        final expense = expenses[i];
                        final category = categoryProvider.getCategoryById(
                          expense.categoryId,
                        );

                        return ExpenseCard(
                          expense: expense,
                          category: category,
                          onDelete: () async {
                            try {
                              await expenseProvider.deleteExpense(expense.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Expense deleted'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Failed to delete expense'),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
  }
}
