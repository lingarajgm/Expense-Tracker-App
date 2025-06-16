import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense/features/expense/domain/model/expense.dart';
import 'package:expense/features/expense/presentation/widget/expense_list_item.dart';

class SearchExpensePage extends StatefulWidget {
  final List<Expense> expenses;

  const SearchExpensePage({super.key, required this.expenses});

  static route({required List<Expense> expenses}) {
    return MaterialPageRoute(
      builder: (context) => SearchExpensePage(expenses: expenses),
    );
  }

  @override
  State<SearchExpensePage> createState() => _SearchExpensePageState();
}

class _SearchExpensePageState extends State<SearchExpensePage> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Expense> filteredExpenses =
        widget.expenses.where((expense) {
          String query = _searchQuery.toLowerCase();
          return expense.name.toLowerCase().contains(query) ||
              expense.description.toLowerCase().contains(query) ||
              DateFormat('yyyy-MM-dd').format(expense.date).contains(query);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search expenses...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                _searchQuery = "";
                _searchController.clear();
              });
            },
          ),
        ],
      ),
      body:
          filteredExpenses.isEmpty
              ? Center(child: Text("No expenses found."))
              : ListView.builder(
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  return ExpenseListTile(expense: filteredExpenses[index]);
                },
              ),
    );
  }
}
