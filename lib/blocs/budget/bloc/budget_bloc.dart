import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'budget_state.dart';

part 'budget_event.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc() : super(BudgetInitial()) {
    // Set Budget
    on<SetBudget>((event, emit) {
      if (event.amount <= 0) {
        emit(const BudgetError(message: "Budget amount must be positive!"));
      } else {
        emit(BudgetSet(
            budget: event.amount,
            totalExpenses: 0,
            expenses: const [],
            isCloseToLimit: false,
            isExceeded: false));
      }
    });

    // Add Expense
    on<AddExpenseToBudget>((event, emit) {
      if (state is BudgetSet) {
        final currentState = state as BudgetSet;

        // Calculate new total expenses
        final updatedExpenses = currentState.totalExpenses + event.amount;

        // Add new expense to the list
        final updatedExpenseList = List<Expense>.from(currentState.expenses)
          ..add(Expense(title: event.title, amount: event.amount));

        // Check budget limits and reset conditions
        if (updatedExpenses == currentState.budget) {
          emit(BudgetInitial()); // Reset state
          emit(const BudgetError(
              message: "You have done your expenses within the budget!"));
        } else if (updatedExpenses > currentState.budget) {
          emit(BudgetInitial()); // Reset state
          emit(const BudgetError(
              message: "You have exceeded the budget range!"));
        } else {
          // Check if expenses are close to limit (90% of budget)
          final isCloseToLimit = updatedExpenses >= currentState.budget * 0.9;

          emit(BudgetSet(
            budget: currentState.budget,
            totalExpenses: updatedExpenses,
            expenses: updatedExpenseList,
            isCloseToLimit: isCloseToLimit,
            isExceeded: false,
          ));
        }
      } else {
        emit(const BudgetError(message: "No budget set!"));
      }
    });

    // Reset Budget
    on<ResetBudget>((event, emit) {
      emit(BudgetInitial());
    });

    // Reset Budget with Message
    on<ResetBudgetWithMessage>((event, emit) {
      emit(BudgetInitial());
      emit(BudgetError(message: event.message));
    });
  }
}
