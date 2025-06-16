import 'package:expense/features/expense/domain/model/expense.dart';
import 'package:expense/core/extensions.dart';
import 'package:expense/features/expense/presentation/pages/update_expense_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;

  const ExpenseListTile({super.key, required this.expense});

  // Edit,Delete,Modify page

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(expense.id),
      background: Container(
        color: Colors.teal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Align(alignment: Alignment.centerLeft, child: Icon(Icons.edit)),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete),
        ),
      ),
      confirmDismiss: (direction) async {
        switch (direction) {
          case DismissDirection.endToStart:
            return await _openDeleteConfirmation(context);
          case DismissDirection.startToEnd:
            await _openUpdateDialog(context);
            break;
          default:
            print('Unhandled dismiss of an ExpenseListTile: $direction');
            break;
        }
        return false;
      },
      onDismissed: (_) => expense.delete(),

      // Displays an expense entry
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd').format(expense.date), // Day of the expense
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat(
                'MMM',
              ).format(expense.date), // Short month (e.g., Jan, Feb)
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        title: Text(expense.name),
        subtitle:
            expense.description.isEmpty ? null : Text(expense.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              expense.amount.toCurrency(), // Amount formatted
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onLongPress: () => _openInfoDialog(context),
      ),
    );
  }

  Future<bool> _openDeleteConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Text('Delete ${expense.name}?'),
            actions: [
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('DELETE'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
  }

  Future<void> _openInfoDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('${expense.name} Options'),
            content:
                expense.description.isEmpty
                    ? null
                    : Text('Description: ${expense.description}'),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('MODIFY'),
                onPressed: () {
                  Navigator.pop(context);
                  _openUpdateDialog(context);
                },
              ),
              TextButton(
                child: Text('DELETE'),
                onPressed: () async {
                  Navigator.pop(context);
                  if (await _openDeleteConfirmation(context)) {
                    expense.delete();
                  }
                },
              ),
            ],
          ),
    );
  }

  Future<void> _openUpdateDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (_) => UpdateExpenseDialog(expense: expense),
    );
  }
}
