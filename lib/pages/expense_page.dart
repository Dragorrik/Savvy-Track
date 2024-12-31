import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:savvy_track/blocs/expense/bloc/expense_bloc.dart';
import 'package:savvy_track/models/expense_model.dart';
import 'package:savvy_track/pages/budget_page.dart';
import 'package:savvy_track/widgets/pie_chart_widget.dart';
import 'package:savvy_track/widgets/pop_up_widgets.dart';

class ExpensePage extends StatelessWidget {
  ExpensePage({super.key});

  // Controllers for text inputs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _expenseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Trigger real-time updates on load
    context.read<ExpenseBloc>().add(StreamExpenses());

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
          _showAddExpenseSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          // Error Handling
          if (state is ExpensesError) {
            return _buildErrorUI(context, state);
          }

          // Expense List Display
          if (state is ExpensesUpdated) {
            return _buildExpenseListUI(context, state);
          }

          // Initial Loading State
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// Shows Add Expense Bottom Sheet
  void _showAddExpenseSheet(BuildContext context) {
    _titleController.clear();
    _expenseController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _expenseInputForm(
          titleController: _titleController,
          amountController: _expenseController,
          onSubmit: () {
            final title = _titleController.text.trim();
            final rawAmount = _expenseController.text.trim();

            print("Title: $title, Amount: $rawAmount");

            final amount = double.tryParse(rawAmount.replaceAll(',', '.'));

            if (title.isNotEmpty && amount != null && amount > 0) {
              final newExpense = Expense(title: title, amount: amount);
              context.read<ExpenseBloc>().add(AddExpenses(expense: newExpense));
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Invalid input! Please check again.")),
              );
            }
          },
        );
      },
    );
  }

  /// Builds Error UI
  Widget _buildErrorUI(BuildContext context, ExpensesError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(state.message, style: const TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: () {
              context.read<ExpenseBloc>().add(FetchExpensesHistory());
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  /// Builds the Expense List UI
  Widget _buildExpenseListUI(BuildContext context, ExpensesUpdated state) {
    final expenses = state.expenses;
    final isAscending = state.isAscending;

    return SingleChildScrollView(
      child: Column(
        children: [
          if (expenses.isEmpty)
            const Center(child: Text("No Expenses Added Yet!"))
          else
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                    margin: const EdgeInsets.all(25),
                    child: buildPieChart(expenses, context)),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<ExpenseBloc>().add(
                          SortExpenses(isAscending: !isAscending),
                        );
                  },
                  icon: Icon(
                      isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  label: Text(isAscending ? "Low to High" : "High to Low"),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      title: Text(expense.title),
                      subtitle: Text("\$${expense.amount.toStringAsFixed(2)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditExpenseSheet(context, expense);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              context
                                  .read<ExpenseBloc>()
                                  .add(RemoveExpense(expense: expense));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Shows Edit Expense Bottom Sheet (Update)
  void _showEditExpenseSheet(BuildContext context, Expense expense) {
    _titleController.text = expense.title;
    // _expenseController.text = '';
    final previousAmount = expense.amount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _expenseInputForm(
          titleController: _titleController,
          amountController: _expenseController,
          onSubmit: () {
            final updatedTitle = _titleController.text.trim();
            final updatedAmount = previousAmount +
                (double.tryParse(_expenseController.text.trim()) ?? 0);
            print('updated title=$updatedTitle,updated amount=$updatedAmount');

            if (updatedTitle.isNotEmpty && updatedAmount > 0) {
              context.read<ExpenseBloc>().add(UpdateExpense(
                    updatedExpense: Expense(
                      id: expense.id,
                      title: updatedTitle,
                      amount: updatedAmount,
                    ),
                  ));
              PopUpWidgets.showBlurredSnackBar(
                  context, 'Your data is updated !!');
              _expenseController.clear();
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  /// Reusable Input Form Widget
  Widget _expenseInputForm({
    required TextEditingController titleController,
    required TextEditingController amountController,
    required VoidCallback onSubmit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: "Expense Title",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Expense Amount",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onSubmit, child: const Text("Save")),
        ],
      ),
    );
  }
}
