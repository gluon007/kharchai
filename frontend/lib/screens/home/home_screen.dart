import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../expenses/expense_list_screen.dart';
import '../expenses/add_expense_screen.dart';
import '../reports/analytics_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Map<String, dynamic>> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        'page': ExpenseListScreen(),
        'title': 'Expenses',
        'icon': Icons.list_alt,
      },
      {
        'page': AddExpenseScreen(),
        'title': 'Add Expense',
        'icon': Icons.add_circle,
      },
      {
        'page': AnalyticsScreen(),
        'title': 'Analytics',
        'icon': Icons.bar_chart,
      },
      {'page': SettingsScreen(), 'title': 'Settings', 'icon': Icons.settings},
    ];
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedIndex]['title']),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).logout();
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _selectPage,
        items:
            _pages.map((page) {
              return BottomNavigationBarItem(
                icon: Icon(page['icon']),
                label: page['title'],
              );
            }).toList(),
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.add),
              )
              : null,
    );
  }
}
