import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import 'package:savvy_track/blocs/expense/bloc/expense_bloc.dart';
import 'package:savvy_track/functions/function_fetcher.dart';
import 'package:savvy_track/models/expense_model.dart';
import 'package:savvy_track/pages/budget_page.dart';
import 'package:savvy_track/widgets/custom_card.dart';
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

    return SafeArea(
      child: Scaffold(
        //backgroundColor: const Color(0XFFCFFFDD),
        //floating action button
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddExpenseSheet(context);
          },
          backgroundColor: Colors.blueAccent, // background
          elevation: 4, // Shadow effect
          shape: const CircleBorder(), // Circular shape
          child: Container(
            //margin: const EdgeInsets.all(2),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              // border: Border.all(
              //   width: 2,
              //   color: Colors.black,
              // ),
              shape: BoxShape.circle, // Circular background

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow effect
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5), // Shadow position
                ),
              ],
            ),
            child: const Icon(
              Icons.add_box_sharp,
              size: 30,
              color: Colors.white, // Icon color
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        //body
        body: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0XFFCFFFDD),
                    Color.fromARGB(255, 54, 204, 99),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3), // Border effect
                  width: 1.5,
                ),
              ),
            ),
            // Glossy Overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Blur effect
              child: Container(
                color: Colors.white.withOpacity(0.1), // Transparent overlay
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context)
                        .size
                        .height, // Ensure it takes full screen height
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Flexible(
                            child: InkWell(
                              child: CustomCard(
                                title: "Daily Expense",
                                subtitle: "Track your expenses",
                                imagePath: "assets/images/expense_money.png",
                              ),
                            ),
                          ),
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const BudgetPage()),
                                );
                              },
                              child: const CustomCard(
                                title: "Challenge",
                                subtitle: "Expend what you have",
                                imagePath: "assets/images/cashier.png",
                              ),
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: BlocBuilder<ExpenseBloc, ExpenseState>(
                          builder: (context, state) {
                            if (state is ExpensesError) {
                              return _buildErrorUI(context, state);
                            }
                            if (state is ExpensesUpdated) {
                              return _buildExpenseListUI(context, state);
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (expenses.isEmpty)
            const Center(child: Text("No Expenses Added Yet!"))
          else
            Column(
              children: [
                const SizedBox(height: 20),

                //Pie chart
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: const Color(0XFF68BA7F),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    // border: Border.all(
                    //   color: const Color.fromARGB(255, 0, 0, 0), // Border color
                    //   width: 2, // Border width
                    // ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        spreadRadius: 3,
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(15),
                  child: buildPieChart(expenses, context),
                ),
                const SizedBox(height: 20),

                //Pages container
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Sorting button
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF68BA7F),
                            Color(0xFF4CAF50)
                          ], // Green gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent,
                          elevation: 26,
                          shadowColor: const Color.fromARGB(255, 0, 0, 0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            // side: const BorderSide(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                          ),
                        ),
                        onPressed: () {
                          context.read<ExpenseBloc>().add(
                                SortExpenses(isAscending: !isAscending),
                              );
                        },
                        icon: Icon(
                          isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.white,
                        ),
                        label: Text(
                          isAscending ? "Low to High" : "High to Low",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    //Save PDF button
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blue,
                            Color.fromARGB(255, 91, 165, 226),
                          ], // Green gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent,
                          elevation: 26,
                          shadowColor: const Color.fromARGB(255, 0, 0, 0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            // side: const BorderSide(
                            //   color: Colors.black,
                            //   width: 2,
                            // ),
                          ),
                        ),
                        onPressed: () {
                          FunctionFetcher().downloadAsPdf(context, expenses);
                        },
                        icon: const Icon(
                          Icons.save_alt_sharp,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Save ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        // side: const BorderSide(
                        //   color: Colors.black,
                        //   strokeAlign: BorderSide.strokeAlignOutside,
                        //   width: 2,
                        // ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.green[100],
                          child: Text(
                            expense.title[0]
                                .toUpperCase(), // Initial letter as avatar
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        title: Text(
                          expense.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "\$${expense.amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditExpenseSheet(context, expense);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                context
                                    .read<ExpenseBloc>()
                                    .add(RemoveExpense(expense: expense));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
  }

  /// Shows Edit Expense Bottom Sheet (Update)
  void _showEditExpenseSheet(BuildContext context, Expense expense) {
    _titleController.text = expense.title;
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Card(
        elevation: 6, // Adds a shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Input
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Expense Title",
                  hintText: "Enter title...",
                  prefixIcon: const Icon(Icons.title), // Icon added
                  filled: true,
                  fillColor: Colors.grey[100], // Light background color
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Rounded input field
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Amount Input
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Expense Amount",
                  hintText: "Enter amount...",
                  prefixIcon: const Icon(Icons.attach_money), // Icon added
                  filled: true,
                  fillColor: Colors.grey[100], // Light background color
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Rounded input field
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.save), // Save icon
                label: const Text(
                  "Save Expense",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded button
                  ),
                  backgroundColor: Colors.blueAccent, // Gradient effect
                  foregroundColor: Colors.white, // Text color
                  elevation: 4, // Button shadow
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
