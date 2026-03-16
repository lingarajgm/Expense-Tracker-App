import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transport,
  entertainment,
  bills,
  shopping,
  health,
  education,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:          return 'Food';
      case ExpenseCategory.transport:     return 'Transport';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.bills:         return 'Bills';
      case ExpenseCategory.shopping:      return 'Shopping';
      case ExpenseCategory.health:        return 'Health';
      case ExpenseCategory.education:     return 'Education';
      case ExpenseCategory.other:         return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:          return Icons.restaurant;
      case ExpenseCategory.transport:     return Icons.directions_car;
      case ExpenseCategory.entertainment: return Icons.movie;
      case ExpenseCategory.bills:         return Icons.receipt_long;
      case ExpenseCategory.shopping:      return Icons.shopping_bag;
      case ExpenseCategory.health:        return Icons.favorite;
      case ExpenseCategory.education:     return Icons.school;
      case ExpenseCategory.other:         return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:          return const Color(0xFFEF5350);
      case ExpenseCategory.transport:     return const Color(0xFF42A5F5);
      case ExpenseCategory.entertainment: return const Color(0xFFAB47BC);
      case ExpenseCategory.bills:         return const Color(0xFFFF7043);
      case ExpenseCategory.shopping:      return const Color(0xFFEC407A);
      case ExpenseCategory.health:        return const Color(0xFF26A69A);
      case ExpenseCategory.education:     return const Color(0xFF5C6BC0);
      case ExpenseCategory.other:         return const Color(0xFF78909C);
    }
  }

  // Convert to string for Firestore storage
  String get value => name;

  // Parse from Firestore string
  static ExpenseCategory fromString(String? value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}