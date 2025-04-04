import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/expense.dart';
import '../../models/category.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInit = true;
  bool _isLoading = false;
  final List<Color> _chartColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

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
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to load expenses: ${error.toString()}',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final expenses = expenseProvider.expenses;
    final categories = categoryProvider.categories;
    final totalAmount = expenseProvider.totalAmount;
    final expensesByCategory = expenseProvider.expensesByCategory;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Theme.of(context).primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.pie_chart),
                        text: 'Category Analysis',
                      ),
                      Tab(
                        icon: Icon(Icons.insights),
                        text: 'Recent Expenses',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Category Analysis
                      _buildCategoryAnalysis(
                        expensesByCategory,
                        categories,
                        totalAmount,
                      ),

                      // Recent Expenses
                      _buildRecentExpenses(expenses, categories),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryAnalysis(
    Map<int, double> expensesByCategory,
    List<dynamic> categories,
    double totalAmount,
  ) {
    if (expensesByCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No expense data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some expenses to see the analytics',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Prepare pie chart data
    List<PieChartSectionData> pieChartSections = [];
    List<Widget> legendItems = [];

    int colorIndex = 0;

    expensesByCategory.forEach((categoryId, amount) {
      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => Category(id: -1, name: 'Unknown'),
      );

      final percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0;
      final color = _chartColors[colorIndex % _chartColors.length];

      pieChartSections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      legendItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(width: 16, height: 16, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(category.name)),
              Text(
                '\$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      colorIndex++;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Total Expenses',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Expenses by Category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: pieChartSections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...legendItems,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses(
    List<Expense> expenses,
    List<dynamic> categories,
  ) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your recent expenses will appear here',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Sort expenses by date (most recent first)
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedExpenses.length,
      itemBuilder: (ctx, i) {
        final expense = sortedExpenses[i];
        final category = categories.firstWhere(
          (cat) => cat.id == expense.categoryId,
          orElse: () => Category(id: -1, name: 'Unknown'),
        );

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              expense.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(category.name),
                const SizedBox(height: 2),
                Text(expense.formattedDate),
              ],
            ),
            trailing: Text(
              expense.formattedAmount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
