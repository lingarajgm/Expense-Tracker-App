// lib/features/expense/data/budget_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense/features/expense/domain/model/budget.dart';

class BudgetService {
  static const _key = 'user_budget';

  Future<Budget> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return Budget.empty();
    try {
      return Budget.fromJson(jsonDecode(raw));
    } catch (_) {
      return Budget.empty();
    }
  }

  Future<void> saveBudget(Budget budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(budget.toJson()));
  }
}