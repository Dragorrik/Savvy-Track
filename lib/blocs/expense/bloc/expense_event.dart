part of 'expense_bloc.dart';

sealed class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

// Event for adding an expense
class AddExpenses extends ExpenseEvent {
  final Expense expense;

  const AddExpenses({required this.expense});

  @override
  List<Object> get props => [expense];
}

// Event for sorting expenses
class SortExpenses extends ExpenseEvent {
  final bool isAscending;

  const SortExpenses({required this.isAscending});
}

// Event for removing an expense
class RemoveExpense extends ExpenseEvent {
  final Expense expense;
  const RemoveExpense({required this.expense});
}

// Event for updating an expense
class UpdateExpense extends ExpenseEvent {
  final Expense updatedExpense;

  const UpdateExpense({required this.updatedExpense});
}

// Event for fetching expense history from Firebase
class FetchExpensesHistory extends ExpenseEvent {}

// **NEW EVENT** - Listen to Firebase stream updates
class StreamExpenses extends ExpenseEvent {}
