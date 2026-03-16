// lib/features/expense/presentation/pages/budget_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense/features/expense/data/budget_service.dart';
import 'package:expense/features/expense/domain/model/budget.dart';
import 'package:expense/features/expense/domain/model/expense_category.dart';

class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  final _budgetService = BudgetService();
  final _monthlyController = TextEditingController();
  final Map<ExpenseCategory, TextEditingController> _categoryControllers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Create controllers for each category
    for (final cat in ExpenseCategory.values) {
      _categoryControllers[cat] = TextEditingController();
    }
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final budget = await _budgetService.loadBudget();
    setState(() {
      _monthlyController.text =
          budget.monthlyLimit > 0 ? budget.monthlyLimit.toStringAsFixed(0) : '';
      for (final cat in ExpenseCategory.values) {
        final limit = budget.categoryLimits[cat.name] ?? 0;
        _categoryControllers[cat]!.text =
            limit > 0 ? limit.toStringAsFixed(0) : '';
      }
      _loading = false;
    });
  }

  Future<void> _saveBudget() async {
    final monthly = double.tryParse(_monthlyController.text) ?? 0;
    final Map<String, double> categoryLimits = {};

    for (final cat in ExpenseCategory.values) {
      final val = double.tryParse(_categoryControllers[cat]!.text) ?? 0;
      if (val > 0) categoryLimits[cat.name] = val;
    }

    await _budgetService.saveBudget(
      Budget(monthlyLimit: monthly, categoryLimits: categoryLimits),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Budget saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _monthlyController.dispose();
    for (final c in _categoryControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Budget Limits'),
        actions: [
          TextButton.icon(
            onPressed: _saveBudget,
            icon: const Icon(Icons.save, color: Colors.white),
            label:
                const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Monthly Budget ──
                  _sectionHeader(
                    icon: Icons.calendar_month,
                    title: 'Monthly Budget',
                    subtitle: 'Overall spending limit for the month',
                  ),
                  const SizedBox(height: 12),
                  _budgetField(
                    controller: _monthlyController,
                    label: 'Monthly Limit (₹)',
                    hint: 'e.g. 10000',
                  ),
                  const SizedBox(height: 28),

                  // ── Category Budgets ──
                  _sectionHeader(
                    icon: Icons.category,
                    title: 'Category Budgets',
                    subtitle: 'Set limits per category (optional)',
                  ),
                  const SizedBox(height: 12),

                  ...ExpenseCategory.values.map((cat) {
                    final name = cat.name[0].toUpperCase() +
                        cat.name.substring(1);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _budgetField(
                        controller: _categoryControllers[cat]!,
                        label: '$name Limit (₹)',
                        hint: 'Leave empty for no limit',
                        prefixIcon: _categoryIcon(cat),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveBudget,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Budget',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.deepPurple, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _budgetField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon ?? Icons.currency_rupee),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }

  IconData _categoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:
        return Icons.fastfood;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.bills:
        return Icons.receipt_long;
      default:
        return Icons.category;
    }
  }
}