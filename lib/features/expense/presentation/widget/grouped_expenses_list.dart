import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense/features/expense/domain/model/expense.dart';
import 'package:expense/features/expense/presentation/widget/expense_list_item.dart'; // Import the ExpenseListTile widget

class GroupedExpenseList extends StatelessWidget {
  final List<Expense> expenses;

  const GroupedExpenseList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text("No expenses recorded."));
    }

    // Sort expenses by date (newest first)
    List<Expense> sortedExpenses = List.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group expenses by month
    Map<String, List<Expense>> groupedExpenses = {};
    for (var expense in sortedExpenses) {
      String monthKey = DateFormat('MMMM yyyy').format(expense.date);
      groupedExpenses.putIfAbsent(monthKey, () => []).add(expense);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: groupedExpenses.length,
      itemBuilder: (context, index) {
        String month = groupedExpenses.keys.elementAt(index);
        List<Expense> monthExpenses = groupedExpenses[month]!;
        bool isCurrentMonth =
            month == DateFormat('MMMM yyyy').format(DateTime.now());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header (This Month / Older Expenses)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(
                isCurrentMonth ? "This Month" : month,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Expense List Items
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: monthExpenses.length,
              itemBuilder:
                  (context, i) => ExpenseListTile(expense: monthExpenses[i]),
            ),
          ],
        );
      },
    );
  }
}
