import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

// Changed from StatelessWidget → StatefulWidget
// This is needed so we can use setState() to trigger animations
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ANIMATION 1: AnimatedContainer
  // Controls whether the total banner is "expanded".
  // When expenses exist, it grows bigger — Flutter animates the change smoothly.
  bool _bannerExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {

          // Update banner size based on whether there are expenses
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final shouldExpand = provider.expenses.isNotEmpty;
            if (_bannerExpanded != shouldExpand) {
              setState(() => _bannerExpanded = shouldExpand);
            }
          });

          return Column(
            children: [

              // ANIMATION 1: AnimatedContainer
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(
                  vertical: _bannerExpanded ? 28 : 16,  // grows when expenses added
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D47A1).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Expenses',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    // ANIMATION 2: AnimatedDefaultTextStyle
                    // The total text smoothly grows bigger when expenses are added
                    // Font size animates
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 2000),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _bannerExpanded ? 40 : 25, // grows smoothly
                        fontWeight: FontWeight.bold,
                      ),
                      child: Text('₱${provider.total.toStringAsFixed(2)}'),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Expenses',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ),
              ),

              // ANIMATION 3: AnimatedSwitcher
              // Smoothly fades between the empty state and the expense list.
              // Without this, switching is instant. With it, it fades in/out.
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  child: provider.expenses.isEmpty
                      ? const Center(
                          key: ValueKey('empty'), // key tells Flutter this is a different widget
                          child: Text(
                            'No expenses yet.\nTap + to add one!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          key: const ValueKey('list'),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.expenses.length,
                          itemBuilder: (_, i) {
                            final expense = provider.expenses[i];

                            // ANIMATION 4: Dismissible (swipe-to-delete gesture)
                            return Dismissible(
                              key: ValueKey(expense.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                provider.deleteExpense(expense.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('"${expense.title}" deleted')),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF0D47A1).withOpacity(0.1),
                                    child: const Icon(Icons.receipt_long, color: Color(0xFF0D47A1)),
                                  ),
                                  title: Text(expense.title,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                    '₱${expense.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Color(0xFF42A5F5)),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AddExpenseScreen(expense: expense),
                                            ),
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Expense updated!')),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete Expense'),
                                              content: Text('Are you sure you want to delete "${expense.title}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            provider.deleteExpense(expense.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('"${expense.title}" deleted')),
                                          );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added!')),
      );
    }
  },
  child: const Icon(Icons.add),
),
    );
  }
}
