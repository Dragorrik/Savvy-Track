import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savvy_track/blocs/budget/bloc/budget_bloc.dart';
import 'package:savvy_track/blocs/budget/bloc/budget_state.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers for inputs
    final TextEditingController budgetController = TextEditingController();
    final TextEditingController expenseTitleController =
        TextEditingController();
    final TextEditingController expenseAmountController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Management"),
        centerTitle: true,
      ),
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: (context, state) {
          // Handle error messages
          if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            // Enables scrolling
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Budget Display
                if (state is BudgetSet) ...[
                  Text(
                    "Budget: \$${state.budget.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Total Expenses: \$${state.totalExpenses.toStringAsFixed(2)}",
                    style:
                        const TextStyle(fontSize: 18, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 10),

                  // Warning Messages
                  if (state.isCloseToLimit && !state.isExceeded)
                    const Text(
                      "⚠️ Warning: You're close to the budget limit!",
                      style: TextStyle(color: Colors.orange, fontSize: 16),
                    ),
                  if (state.isExceeded)
                    const Text(
                      "❌ Alert: Budget has been exceeded!",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  const SizedBox(height: 20),

                  // Reset Budget Button
                  ElevatedButton(
                    onPressed: () {
                      context.read<BudgetBloc>().add(ResetBudget());
                    },
                    child: const Text("Reset Budget"),
                  ),
                  const SizedBox(height: 20),
                ],

                // Set Budget Section
                if (state is! BudgetSet) ...[
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Set Monthly Budget",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final double? budget =
                          double.tryParse(budgetController.text);
                      if (budget != null && budget > 0) {
                        context.read<BudgetBloc>().add(SetBudget(budget));
                        budgetController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Please enter a valid budget amount."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text("Set Budget"),
                  ),
                ],

                // Add Expense Section
                if (state is BudgetSet) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "Add Expense",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: expenseTitleController,
                    decoration: const InputDecoration(
                      labelText: "Expense Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: expenseAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Expense Amount",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final String title = expenseTitleController.text;
                      final double? amount =
                          double.tryParse(expenseAmountController.text);

                      if (title.isNotEmpty && amount != null && amount > 0) {
                        context.read<BudgetBloc>().add(
                            AddExpenseToBudget(title: title, amount: amount));
                        expenseTitleController.clear();
                        expenseAmountController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter valid inputs."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text("Add Expense"),
                  ),
                ],

                // Expense List Section
                if (state is BudgetSet && state.expenses.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "Expenses",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300, // Fixed height for list view
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = state.expenses[index];
                        return ListTile(
                          title: Text(expense.title),
                          subtitle:
                              Text("\$${expense.amount.toStringAsFixed(2)}"),
                          trailing: const Icon(Icons.money_off),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
