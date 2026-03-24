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

  // ANIMATION 5: AnimatedOpacity
  // Starts at 0 (invisible), then flips to 1 (visible) after screen loads.
  // This makes the icon fade in smoothly every time you open this screen.
  double _iconOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.expense?.title ?? '');
    _amountCtrl = TextEditingController(
        text: widget.expense != null ? widget.expense!.amount.toString() : '');

    // Trigger the fade-in after the first frame loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _iconOpacity = 1.0); // fade in!
    });

    // Listen to text changes so the save button can animate
    _titleCtrl.addListener(() => setState(() {}));
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  // True when both fields are filled — used to animate the save button
  bool get _isFormFilled =>
      _titleCtrl.text.trim().isNotEmpty &&
      (double.tryParse(_amountCtrl.text) ?? 0) > 0;

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

            // ANIMATION 5: AnimatedOpacity
            // The icon fades in from invisible (0.0) to visible (1.0)
            AnimatedOpacity(
              opacity: _iconOpacity,
              duration: const Duration(milliseconds: 2000),
              child: Container(
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

            // ANIMATION 6: AnimatedContainer on the Save button
            // When both fields are filled, the button smoothly grows
            // and changes color from grey → blue, giving clear visual feedback.
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: double.infinity,
              height: _isFormFilled ? 62 : 44, // grows when ready
              decoration: BoxDecoration(
                color: _isFormFilled
                    ? const Color(0xFF0D47A1)  // blue when ready
                    : Colors.grey.shade400,     // grey when not ready
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: _isFormFilled ? _save : null,
                child: Text(
                  isEditing ? 'Update Expense' : 'Add Expense',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
