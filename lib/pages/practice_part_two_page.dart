import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savvy_track/blocs/budget/bloc/budget_state.dart';
import 'package:savvy_track/blocs/practice_part_two/bloc/practice_part_two_bloc.dart';
import 'package:savvy_track/pages/budget_page.dart';
import 'package:savvy_track/widgets/pie_chart_widget.dart';

class PracticePartTwoPage extends StatelessWidget {
  PracticePartTwoPage({super.key});

  // Controllers for text inputs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _expenseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetPage()),
              );
            },
            label: const Icon(Icons.manage_accounts_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (sheetContext) {
              // Provide Bloc to the bottom sheet
              return BlocProvider.value(
                value:
                    BlocProvider.of<ExpenseBloc>(context), // Pass current bloc
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 20,
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title Field
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: "Expense Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Amount Field
                      TextField(
                        controller: _expenseController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Expense Amount",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Add Button
                      ElevatedButton(
                        onPressed: () {
                          final title = _titleController.text.trim();
                          final expenseText = _expenseController.text.trim();

                          if (title.isNotEmpty && expenseText.isNotEmpty) {
                            try {
                              final amount = double.parse(expenseText);

                              // Add valid expense
                              Expense newExpense =
                                  Expense(title: title, amount: amount);
                              context
                                  .read<ExpenseBloc>()
                                  .add(AddExpenses(expense: newExpense));

                              // Clear input
                              _titleController.clear();
                              _expenseController.clear();

                              Navigator.pop(context); // Close the sheet
                            } catch (e) {
                              // Clear input
                              _titleController.clear();
                              _expenseController.clear();
                              Navigator.pop(context); // Close the sheet
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Enter a valid amount!")),
                              );
                            }
                          } else {
                            // Clear input
                            _titleController.clear();
                            _expenseController.clear();
                            Navigator.pop(context); // Close the sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Fields cannot be empty!")),
                            );
                          }
                        },
                        child: const Text("Add Expense"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          bool isAscending = true; // Default
          // Error Message UI
          if (state is ExpensesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Restore old expenses
                        context.read<ExpenseBloc>().add(FetchExpensesHistory());
                      },
                      child: const Text("Back to History"),
                    ),
                  ],
                ),
              ),
            );
          }

          // Fetch List of Expenses
          List<Expense> expenses = [];
          if (state is ExpensesUpdated) {
            expenses = state.expenses;
            isAscending = state.isAscending; // Updated model
          }

          return Column(
            children: [
              // Expenses List
              Expanded(
                child: expenses.isEmpty
                    ? const Center(child: Text("No Expenses Added Yet!"))
                    : Column(
                        children: [
                          Container(
                              margin: const EdgeInsets.all(25),
                              child:
                                  buildPieChart(expenses, context)), //pie chart
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              //Sorting
                              context
                                  .read<ExpenseBloc>()
                                  .add(SortExpenses(isAscending: !isAscending));
                            },
                            icon: Icon(isAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward), // Dynamic icon
                            label: Text(
                                isAscending ? "Low to High" : "High to Low"),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: expenses.length,
                              itemBuilder: (context, index) {
                                final expense = expenses[index];
                                return ListTile(
                                  title: Text(expense.title),
                                  subtitle: Text(
                                      "\$${expense.amount.toStringAsFixed(2)}"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          // Show bottom sheet for editing
                                          _showEditExpenseSheet(
                                              context, expense);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          context.read<ExpenseBloc>().add(
                                              RemoveExpense(expense: expense));
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditExpenseSheet(BuildContext context, Expense expense) {
    final TextEditingController editTitleController =
        TextEditingController(text: expense.title);
    final TextEditingController editAmountController =
        TextEditingController(text: expense.amount.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ExpenseBloc>(context),
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editTitleController,
                  decoration: const InputDecoration(
                    labelText: "Expense Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: editAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Expense Amount",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final updatedTitle = editTitleController.text.trim();
                    final updatedAmount =
                        double.tryParse(editAmountController.text.trim()) ?? 0;

                    if (updatedTitle.isNotEmpty && updatedAmount > 0) {
                      // Dispatch update event
                      context.read<ExpenseBloc>().add(
                            UpdateExpense(
                              updatedExpense: Expense(
                                title: updatedTitle,
                                amount: updatedAmount,
                              ),
                            ),
                          );

                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Update Expense"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
