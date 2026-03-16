// lib/features/expense/domain/model/budget.dart

class Budget {
  final double monthlyLimit;
  final Map<String, double> categoryLimits;

  Budget({
    required this.monthlyLimit,
    required this.categoryLimits,
  });

  factory Budget.empty() => Budget(monthlyLimit: 0, categoryLimits: {});

  Map<String, dynamic> toJson() => {
        'monthlyLimit': monthlyLimit,
        'categoryLimits': categoryLimits,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        monthlyLimit: (json['monthlyLimit'] ?? 0).toDouble(),
        categoryLimits: Map<String, double>.from(
          (json['categoryLimits'] as Map? ?? {}).map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          ),
        ),
      );
}