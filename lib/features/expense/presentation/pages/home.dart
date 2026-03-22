import 'package:expense/features/expense/data/data_repository.dart';
import 'package:expense/features/expense/domain/model/expense_category.dart';
import 'package:expense/features/expense/presentation/widget/total_expense.dart';
import 'package:expense/features/expense/presentation/widget/grouped_expenses_list.dart';
import 'package:expense/features/expense/presentation/pages/profile.dart';
import 'package:expense/features/expense/presentation/widget/search_expense_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:expense/features/expense/domain/model/expense.dart';
import 'package:expense/features/expense/presentation/pages/chart_screen.dart';
import 'package:expense/features/expense/presentation/pages/budget_settings_screen.dart';
import 'package:expense/features/expense/presentation/widget/budget_checker.dart';
import 'package:expense/features/expense/presentation/pages/export_screen.dart';
import 'package:expense/core/common/cubits/theme/theme_cubit.dart';
import 'package:intl/intl.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

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
            title: const Text('Expense Tracker'),
            actions: [
              // Theme toggle
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return IconButton(
                    icon: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    tooltip: 'Toggle Theme',
                    onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                  );
                },
              ),

              // Profile
              IconButton(
                icon: const Icon(Icons.account_circle),
                tooltip: 'Profile',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
              ),

              // 3-dot menu for everything else
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'charts':
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChartScreen(expenses: expenses)));
                      break;
                    case 'export':
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ExportScreen(expenses: expenses)));
                      break;
                    case 'budget':
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BudgetSettingsScreen()));
                      break;
                    case 'delete_all':
                      _showRemoveAllConfirmation(context, expenses);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'charts',
                    child: ListTile(
                      leading: Icon(Icons.pie_chart_outline),
                      title: Text('Charts'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text('Export PDF'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'budget',
                    child: ListTile(
                      leading: Icon(Icons.tune),
                      title: Text('Budget Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_all',
                    child: ListTile(
                      leading: Icon(Icons.delete_forever, color: Colors.red),
                      title: Text('Delete All',
                          style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                child: const Icon(Icons.search),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: () => _showAddExpenseDialog(context, expenses),
                tooltip: 'Add Expense',
                child: const Icon(Icons.add),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TotalExpense(expenses: expenses),
              ),
              Expanded(
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

Future<bool> _showAddExpenseDialog(
    BuildContext context, List<Expense> expenses) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  ExpenseCategory selectedCategory = ExpenseCategory.other;

  final formKey = GlobalKey<FormState>();
  String name = '', description = '', amount = '';

  return await showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Add Expense'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Leave empty to use category name as Title'),
                  onChanged: (s) => name = s,
                ),
                // Description
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (s) => description = s,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Description is required'
                      : null,
                ),
                // Amount
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)'),
                  onChanged: (s) => amount = s,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Amount is required';
                    if (double.tryParse(value) == null)
                      return 'Enter a valid number';
                    return null;
                  },
                ),
                // Date
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      selectedDate = pickedDate;
                      dateController.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                    }
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Date is required'
                      : null,
                ),

                const SizedBox(height: 16),

                // ── Category Picker ──
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ExpenseCategory.values.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withOpacity(0.2)
                              : Colors.transparent,
                          border: Border.all(
                            color:
                                isSelected ? cat.color : Colors.grey.shade400,
                            width: isSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon,
                                size: 16,
                                color: isSelected ? cat.color : Colors.grey),
                            const SizedBox(width: 5),
                            Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? cat.color : Colors.grey,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
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
              if (formKey.currentState!.validate()) {
                // 1. First create the expense
                final added = await createExpense(
                  name,
                  description,
                  double.tryParse(amount) ?? 0,
                  selectedDate,
                  selectedCategory,
                );

                if (added) {
                  if (context.mounted) {
                    await BudgetChecker.check(context);
                  }
                  if (context.mounted) Navigator.pop(context, true);
                } else {
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
    ),
  );
}

Future<void> _showRemoveAllConfirmation(
  BuildContext context,
  List<Expense> expenses,
) async {
  return await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Remove All Expenses?'),
      content: const Text('Are you sure you want to remove all expenses?'),
      actions: [
        TextButton(
          child: const Text('NO'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('YES'),
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
