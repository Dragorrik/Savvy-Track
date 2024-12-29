import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savvy_track/blocs/budget/bloc/budget_state.dart';
import 'package:savvy_track/blocs/expense/bloc/expense_bloc.dart';
import 'package:savvy_track/pages/budget_page.dart';
import 'package:savvy_track/widgets/pie_chart_widget.dart';

class ExpensePage extends StatelessWidget {
  ExpensePage({super.key});

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
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: "Expense Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _expenseController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Expense Amount",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          final title = _titleController.text.trim();
                          final expenseText = _expenseController.text.trim();
                          if (title.isNotEmpty && expenseText.isNotEmpty) {
                            try {
                              final amount = double.parse(expenseText);
                              Expense newExpense =
                                  Expense(title: title, amount: amount);
                              context
                                  .read<ExpenseBloc>()
                                  .add(AddExpenses(expense: newExpense));
                              _titleController.clear();
                              _expenseController.clear();
                              Navigator.pop(context);
                            } catch (e) {
                              _titleController.clear();
                              _expenseController.clear();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Enter a valid amount!")),
                              );
                            }
                          } else {
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
          bool isAscending = true;
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
                        context.read<ExpenseBloc>().add(FetchExpensesHistory());
                      },
                      child: const Text("Back to History"),
                    ),
                  ],
                ),
              ),
            );
          }
          List<Expense> expenses = [];
          if (state is ExpensesUpdated) {
            expenses = state.expenses;
            isAscending = state.isAscending;
          }
          return SingleChildScrollView(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                expenses.isEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: const Center(
                          child: Text("No Expenses Added Yet!",
                              style: TextStyle(fontSize: 18)),
                        ),
                      )
                    : Column(
                        children: [
                          Container(
                              margin: const EdgeInsets.all(25),
                              child: buildPieChart(expenses, context)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<ExpenseBloc>()
                                  .add(SortExpenses(isAscending: !isAscending));
                            },
                            icon: Icon(isAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward),
                            label: Text(
                                isAscending ? "Low to High" : "High to Low"),
                          ),
                          const SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                                        _showEditExpenseSheet(context, expense);
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
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
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
