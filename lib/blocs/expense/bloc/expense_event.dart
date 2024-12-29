part of 'expense_bloc.dart';

sealed class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class AddExpenses extends ExpenseEvent {
  final Expense expense;

  const AddExpenses({required this.expense});

  @override
  List<Object> get props => [expense];
}

class SortExpenses extends ExpenseEvent {
  final bool isAscending; // Toggle for ascending or descending

  const SortExpenses({required this.isAscending});
}

class RemoveExpense extends ExpenseEvent {
  final Expense expense;
  const RemoveExpense({required this.expense});
}

class UpdateExpense extends ExpenseEvent {
  final Expense updatedExpense;

  const UpdateExpense({required this.updatedExpense});
}

class FetchExpensesHistory extends ExpenseEvent {}
