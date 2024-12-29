import 'package:equatable/equatable.dart';

// Expense Model
class Expense extends Equatable {
  final String title;
  final double amount;

  const Expense({required this.title, required this.amount});

  @override
  List<Object?> get props => [title, amount];
}

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

// Shared parent class for states with details
abstract class BudgetWithDetails extends BudgetState {
  final double budget;
  final double totalExpenses;
  final List<Expense> expenses;

  const BudgetWithDetails({
    required this.budget,
    required this.totalExpenses,
    this.expenses = const [],
  });

  @override
  List<Object?> get props => [budget, totalExpenses, expenses];
}

// Initial state
class BudgetInitial extends BudgetState {}

// Updated BudgetSet State
class BudgetSet extends BudgetWithDetails {
  final bool isCloseToLimit;
  final bool isExceeded;

  const BudgetSet({
    required super.budget,
    required super.totalExpenses,
    super.expenses,
    this.isCloseToLimit = false,
    this.isExceeded = false,
  });

  @override
  List<Object?> get props =>
      [budget, totalExpenses, expenses, isCloseToLimit, isExceeded];
}

// Error State
class BudgetError extends BudgetState {
  final String message;

  const BudgetError({required this.message});

  @override
  List<Object?> get props => [message];
}
