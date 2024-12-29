part of 'budget_bloc.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

// Event to set budget
class SetBudget extends BudgetEvent {
  final double amount;

  const SetBudget(this.amount);

  @override
  List<Object?> get props => [amount];
}

// Event to reset budget with a message
class ResetBudgetWithMessage extends BudgetEvent {
  final String message;

  const ResetBudgetWithMessage(this.message);

  @override
  List<Object?> get props => [message];
}

// Event to add expense with title
class AddExpenseToBudget extends BudgetEvent {
  final String title; // Added title
  final double amount;

  const AddExpenseToBudget({required this.title, required this.amount});

  @override
  List<Object?> get props => [title, amount];
}

// Event to reset budget
class ResetBudget extends BudgetEvent {}
