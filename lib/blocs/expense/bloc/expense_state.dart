part of 'expense_bloc.dart';

sealed class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object> get props => [];
}

// Initial state
final class PracticePartTwoInitial extends ExpenseState {}

// State when expenses are updated
class ExpensesUpdated extends ExpenseState {
  final List<Expense> expenses;
  final bool isAscending;

  const ExpensesUpdated({required this.isAscending, required this.expenses});

  @override
  List<Object> get props => [expenses, isAscending];
}

// State for errors
class ExpensesError extends ExpenseState {
  final String message;
  final List<Expense> oldExpenses;

  const ExpensesError({required this.oldExpenses, required this.message});

  @override
  List<Object> get props => [message, oldExpenses];
}

// **NEW STATE** - Loading state for Firebase sync
class ExpensesLoading extends ExpenseState {}

// **NEW STATE** - Stream state for Firebase updates
class ExpensesStreamUpdated extends ExpenseState {
  final List<Expense> expenses;

  const ExpensesStreamUpdated({required this.expenses});

  @override
  List<Object> get props => [expenses];
}
