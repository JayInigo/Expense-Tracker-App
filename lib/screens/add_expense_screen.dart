import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.expense?.title ?? '');
    _amountCtrl = TextEditingController(
        text: widget.expense != null ? widget.expense!.amount.toString() : '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    if (title.isEmpty || amount <= 0) return;

    final provider = context.read<ExpenseProvider>();

    if (widget.expense == null) {
      provider.addExpense(title, amount);
    } else {
      provider.updateExpense(widget.expense!.id, title, amount);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Color(0xFF0D47A1),
                size: 34,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title, color: Color(0xFF0D47A1)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount (₱)',
                prefixIcon: Icon(Icons.payments, color: Color(0xFF0D47A1)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  isEditing ? 'Update Expense' : 'Add Expense',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}