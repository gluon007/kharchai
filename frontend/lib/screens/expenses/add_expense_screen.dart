import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/expense.dart';
import '../../models/category.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Load categories if not already loaded
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      if (categoryProvider.categories.isEmpty) {
        categoryProvider.fetchCategories().catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to load categories'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        });
      } else if (categoryProvider.categories.isNotEmpty &&
          _selectedCategoryId == null) {
        _selectedCategoryId = categoryProvider.categories.first.id;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      double amount = double.parse(_amountController.text);

      final newExpense = Expense(
        amount: amount,
        description: _descriptionController.text,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
      );

      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).addExpense(newExpense);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add expense: ${error.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;
    final isLoading = categoryProvider.isLoading;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Expense',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                    hintText: '0.00',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    hintText: 'What did you spend on?',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Category
                if (isLoading)
                  const CircularProgressIndicator()
                else if (categories.isEmpty)
                  const Text('No categories available. Please add categories first.')
                else
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    value: _selectedCategoryId ?? categories.first.id,
                    items: categories
                        .map<DropdownMenuItem<int>>((Category category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 24),
                // Date
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitForm,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'ADD EXPENSE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
