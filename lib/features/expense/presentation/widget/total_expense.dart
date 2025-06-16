// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:expense/features/expense/domain/model/expense.dart';
import 'package:expense/core/extensions.dart';

// Only display the total expense

class TotalExpense extends StatelessWidget {
  static const topCardHeight = 56.0;
  static const fabPadding = 2 * 16 + 56.0;

  final List<Expense> expenses;

  const TotalExpense({super.key, required this.expenses});

  double get totalAmount =>
      expenses.fold<double>(0.0, (acc, e) => acc + e.amount);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: topCardHeight,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(12), // Padding for spacing
          decoration: BoxDecoration(
            color: const Color.fromARGB(159, 53, 45, 45), // Black background
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: RichText(
            text: TextSpan(
              text: 'There are ${totalAmount.toCurrency()} total expenses',
              style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: 20, // Increased font size
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for contrast
              ),
            ),
          ),
        ),
      ),
    );
  }
}
