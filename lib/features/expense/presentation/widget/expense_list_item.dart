import 'package:expense/features/expense/domain/model/expense.dart';
import 'package:expense/features/expense/domain/model/expense_category.dart';
import 'package:expense/core/extensions.dart';
import 'package:expense/features/expense/presentation/pages/update_expense_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;

  const ExpenseListTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final category = expense.category;

    return Dismissible(
      key: ValueKey(expense.id),
      background: Container(
        color: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Align(
            alignment: Alignment.centerLeft, child: Icon(Icons.edit)),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Align(
            alignment: Alignment.centerRight, child: Icon(Icons.delete)),
      ),
      confirmDismiss: (direction) async {
        switch (direction) {
          case DismissDirection.endToStart:
            return await _openDeleteConfirmation(context);
          case DismissDirection.startToEnd:
            await _openUpdateDialog(context);
            break;
          default:
            break;
        }
        return false;
      },
      onDismissed: (_) => expense.delete(),
      child: ListTile(
        // ── Category icon badge on the left ──
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(category.icon, color: category.color, size: 22),
        ),
        title: Text(expense.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expense.description.isNotEmpty)
              Text(expense.description,
                  style: const TextStyle(fontSize: 12)),
            // Category label + date row
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: category.color.withOpacity(0.4), width: 0.8),
                  ),
                  child: Text(
                    category.label,
                    style: TextStyle(
                        fontSize: 10,
                        color: category.color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM').format(expense.date),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          expense.amount.toCurrency(),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onLongPress: () => _openInfoDialog(context),
      ),
    );
  }

  Future<bool> _openDeleteConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('Delete ${expense.name}?'),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('DELETE'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  Future<void> _openInfoDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${expense.name} Options'),
        content: expense.description.isEmpty
            ? null
            : Text('Description: ${expense.description}'),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('MODIFY'),
            onPressed: () {
              Navigator.pop(context);
              _openUpdateDialog(context);
            },
          ),
          TextButton(
            child: const Text('DELETE'),
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