import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [
    Expense(id: '1', title: 'Groceries', amount: 58.75),
    Expense(id: '2', title: 'Uber Ride', amount: 12.50),
    Expense(id: '3', title: 'Netflix', amount: 15.99),
  ];

  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get total => _expenses.fold(0, (sum, e) => sum + e.amount);

  // CREATE
  void addExpense(String title, double amount) {
    _expenses.add(Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
    ));
    notifyListeners();
  }

  void deleteExpense(String id) {}

  void updateExpense(String id, String title, double amount) {}
}