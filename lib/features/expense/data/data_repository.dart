import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense/features/expense/data/auth_repository.dart';
import 'package:expense/features/expense/domain/model/expense.dart';

final _firestore = FirebaseFirestore.instance;

CollectionReference get _expensesCollection =>
    _firestore.collection('expenses');

Stream<List<Expense>> get expenseStream => _expensesCollection
    .where('uid', isEqualTo: currentUid)
    .snapshots()
    .map((snapshot) => snapshot.docs)
    .map((docs) => docs.map((doc) => Expense.fromDocument(doc)).toList());

Future<bool> createExpense(
  String name,
  String description,
  double amount,
  DateTime date,
) async {
  try {
    await _expensesCollection.add({
      'uid': currentUid,
      'name': name,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
    });
    return true;
  } catch (e) {
    print("Error adding expense: $e");
    return false;
  }
}
