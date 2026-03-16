import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense/features/expense/data/auth_repository.dart';
import 'package:expense/features/expense/domain/model/expense.dart';
import 'package:expense/features/expense/domain/model/expense_category.dart';

final _firestore = FirebaseFirestore.instance;

CollectionReference get _expensesCollection =>
    _firestore.collection('expenses');
    
Stream<List<Expense>> get expenseStream => _expensesCollection
    .where('uid', isEqualTo: currentUid)
    .snapshots()
    .map((snapshot) => snapshot.docs)
    .map((docs) {
      final List<Expense> result = [];
      for (final doc in docs) {
        try {
          result.add(Expense.fromDocument(doc));
        } catch (e) {
          print('Error parsing expense ${doc.id}: $e');
        }
      }
      return result;
    });

Future<bool> createExpense(
  String name,
  String description,
  double amount,
  DateTime date,
  ExpenseCategory category,
) async {
  try {
    await _expensesCollection.add({
      'uid': currentUid,
      'name': name,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'category': category.value,
    });
    return true;
  } catch (e) {
    return false;
  }
}