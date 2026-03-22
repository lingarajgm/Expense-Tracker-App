// lib/features/expense/presentation/widget/budget_checker.dart

import 'package:flutter/material.dart';
import 'package:expense/features/expense/data/budget_service.dart';
import 'package:expense/features/expense/domain/model/expense.dart';
import 'package:expense/core/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetChecker {
  static final _service = BudgetService();

  /// Call this after adding an expense.
  /// Shows a warning dialog if any limit is crossed.
  static Future<void> check(BuildContext context) async {
  final budget = await _service.loadBudget();
  if (!context.mounted) return;

  // Fetch fresh expenses directly from Firestore
  final snapshot = await FirebaseFirestore.instance
      .collection('expenses')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
      .get();

  final allExpenses = snapshot.docs
      .map((doc) => Expense.fromDocument(doc))
      .toList();

  final now = DateTime.now();
  final thisMonthExpenses = allExpenses.where((e) =>
      e.date.year == now.year && e.date.month == now.month).toList();

    final List<String> warnings = [];

    // ── Monthly check ──
    if (budget.monthlyLimit > 0) {
      final monthlyTotal =
          thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
      if (monthlyTotal >= budget.monthlyLimit) {
        warnings.add(
          '📅 Monthly budget exceeded!\n'
          'Spent: ${monthlyTotal.toCurrency()} / Limit: ${budget.monthlyLimit.toCurrency()}',
        );
      } else if (monthlyTotal >= budget.monthlyLimit * 0.8) {
        warnings.add(
          '⚠️ 80% of monthly budget used!\n'
          'Spent: ${monthlyTotal.toCurrency()} / Limit: ${budget.monthlyLimit.toCurrency()}',
        );
      }
    }

    // ── Category check ──
    for (final entry in budget.categoryLimits.entries) {
      final catName = entry.key;
      final limit = entry.value;
      if (limit <= 0) continue;

      final catTotal = thisMonthExpenses
          .where((e) => e.category.name == catName)
          .fold(0.0, (sum, e) => sum + e.amount);

      final displayName =
          catName[0].toUpperCase() + catName.substring(1);

      if (catTotal >= limit) {
        warnings.add(
          '🏷️ $displayName budget exceeded!\n'
          'Spent: ${catTotal.toCurrency()} / Limit: ${limit.toCurrency()}',
        );
      } else if (catTotal >= limit * 0.8) {
        warnings.add(
          '⚠️ $displayName at 80% of budget!\n'
          'Spent: ${catTotal.toCurrency()} / Limit: ${limit.toCurrency()}',
        );
      }
    }

    if (warnings.isEmpty) return;

    // Show warning dialog
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Budget Alert'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: warnings
                .map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.4)),
                        ),
                        child: Text(w,
                            style: const TextStyle(fontSize: 13.5)),
                      ),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(_),
              child: const Text('Got it',
                  style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }
}