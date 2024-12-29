part of 'practice_part_two_bloc.dart';

sealed class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object> get props => [];
}

final class PracticePartTwoInitial extends ExpenseState {}

class ExpensesUpdated extends ExpenseState {
  final List<Expense> expenses;
  final bool isAscending;

  const ExpensesUpdated({required this.isAscending, required this.expenses});

  @override
  List<Object> get props => [expenses, isAscending];
}

class ExpensesError extends ExpenseState {
  final String message;
  final List<Expense> oldExpenses;

  const ExpensesError({required this.oldExpenses, required this.message});

  @override
  List<Object> get props => [message, oldExpenses];
}
