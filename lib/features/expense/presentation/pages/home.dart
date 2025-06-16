import 'package:expense/features/expense/data/data_repository.dart';
import 'package:expense/features/expense/presentation/widget/total_expense.dart';
import 'package:expense/features/expense/presentation/widget/grouped_expenses_list.dart';
import 'package:expense/features/expense/presentation/pages/profile.dart';
import 'package:expense/features/expense/presentation/widget/search_expense_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:expense/features/expense/domain/model/expense.dart';
import 'package:intl/intl.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: expenseStream,
      builder: (context, snapshot) {
        final expenses = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text('Expense Tracker'),
            actions: [
              IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () => _showRemoveAllConfirmation(context, expenses),
                tooltip: 'Delete All Expenses',
              ),
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                tooltip: 'Profile',
              ),
            ],
          ),

          // ✅ Correct way to add multiple floating buttons
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "search",
                onPressed: () {
                  Navigator.push(
                    context,
                    SearchExpensePage.route(expenses: expenses),
                  );
                },
                tooltip: 'Search Expenses',
                child: Icon(Icons.search),
              ),
              SizedBox(height: 10), // Add spacing between buttons
              FloatingActionButton(
                onPressed: () => _showAddExpenseDialog(context),
                tooltip: 'Add Expense',
                child: Icon(Icons.add),
              ),
            ],
          ),

          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ Show Total Expense at the top
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TotalExpense(expenses: expenses),
              ),

              // ✅ Fix GroupedExpenseList Layout Issue
              Expanded(
                // Ensures it takes up remaining space
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GroupedExpenseList(expenses: expenses),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<bool> _showAddExpenseDialog(BuildContext context) async {
  // ignore: no_leading_underscores_for_local_identifiers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  // ignore: no_leading_underscores_for_local_identifiers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  // ignore: no_leading_underscores_for_local_identifiers
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  String name = '', description = '', amount = '';

  return await showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text('Add Expense'),
          content: Form(
            key: _formKey, // Assign form key
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (s) => name = s,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Title is required'
                              : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 1,
                  onChanged: (s) => description = s,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Description is required'
                              : null,
                ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)'),
                  onChanged: (s) => amount = s,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount is required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          selectedDate, // Use selected date instead of DateTime.now()
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      selectedDate = pickedDate; // Update selected date
                      _dateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(selectedDate);
                    }
                  },

                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Date is required'
                              : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('CREATE'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                  final added = await createExpense(
                    name,
                    description,
                    double.tryParse(amount) ?? 0,
                    selectedDate, // Pass the date here
                  );
                  if (!added) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create the expense'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
  );
}

Future<void> _showRemoveAllConfirmation(
  BuildContext context,
  List<Expense> expenses,
) async {
  return await showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: Text('Remove All Expenses?'),
          content: Text('Are you sure you want to remove all expenses?'),
          actions: <Widget>[
            TextButton(
              child: Text('NO'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('YES'),
              onPressed: () {
                Navigator.pop(context);
                for (var expense in expenses) {
                  expense.delete();
                }
              },
            ),
          ],
        ),
  );
}
