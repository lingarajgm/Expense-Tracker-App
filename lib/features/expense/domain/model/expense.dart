
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense/features/expense/domain/model/expense_category.dart';

class Expense {
  final double amount;
  final String name, description;
  final DateTime date;
  final ExpenseCategory category;
  final DocumentReference _document;

  Expense._fromMap(Map<String, dynamic> data, this._document)
  : amount = (data['amount'] ?? 0).toDouble(),
    name = data['name'] ?? '',
    description = data['description'] ?? '',
    date = (data['date'] != null)
        ? (data['date'] as Timestamp).toDate()
        : DateTime.now(),
    category = ExpenseCategory.values.firstWhere(
      (e) => e.name == (data['category'] ?? ''),
      orElse: () => ExpenseCategory.other, 
    );

  Expense.fromDocument(DocumentSnapshot document)
      : this._fromMap(
          document.data() as Map<String, dynamic>? ?? {},
          document.reference,
        );

  String get id => _document.id;

  Future<void> delete() => _document.delete();

  Future<void> updateWith({
    double? amount,
    String? name,
    String? description,
    DateTime? date,
    ExpenseCategory? category,
  }) {
    return _document.update({
      
      if (amount != null) 'amount': amount,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (date != null) 'date': Timestamp.fromDate(date),
      if (category != null) 'category': category.value,
    });
  }
}