import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:savvy_track/blocs/budget/bloc/budget_state.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  bool isAscending = true; // Sorting order state

  ExpenseBloc() : super(PracticePartTwoInitial()) {
    // Add Expense
    on<AddExpenses>((event, emit) {
      if (event.expense.title.isEmpty || event.expense.amount <= 0) {
        if (state is ExpensesUpdated) {
          final currentState = state as ExpensesUpdated;
          emit(ExpensesError(
              oldExpenses: currentState.expenses,
              message:
                  "Invalid expense! Title can't be empty, and amount must be positive."));
        } else {
          emit(const ExpensesError(
              oldExpenses: [],
              message:
                  "Invalid expense! Title can't be empty, and amount must be positive."));
        }
        return;
      }

      if (state is ExpensesUpdated) {
        final currentState = state as ExpensesUpdated;
        final updatedList = List<Expense>.from(currentState.expenses)
          ..add(event.expense);

        updatedList.sort((a, b) => currentState.isAscending
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));

        emit(ExpensesUpdated(
            expenses: updatedList, isAscending: currentState.isAscending));
      } else if (state is ExpensesError) {
        final errorState = state as ExpensesError;
        final updatedList = List<Expense>.from(errorState.oldExpenses)
          ..add(event.expense);
        emit(ExpensesUpdated(expenses: updatedList, isAscending: isAscending));
      } else {
        emit(ExpensesUpdated(
            expenses: [event.expense], isAscending: isAscending));
      }
    });

    // Update Expense
    on<UpdateExpense>((event, emit) {
      if (state is ExpensesUpdated) {
        final currentState = state as ExpensesUpdated;
        final updatedExpenses = List<Expense>.from(currentState.expenses);

        final index = updatedExpenses.indexWhere(
          (e) => e.title == event.updatedExpense.title,
        );

        if (index != -1) {
          updatedExpenses[index] = Expense(
            title: updatedExpenses[index].title,
            amount: updatedExpenses[index].amount + event.updatedExpense.amount,
          );
        } else {
          updatedExpenses.add(event.updatedExpense);
        }

        updatedExpenses.sort((a, b) => currentState.isAscending
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));

        emit(ExpensesUpdated(
            expenses: updatedExpenses, isAscending: currentState.isAscending));
      }
    });

    // Sorting Expenses
    on<SortExpenses>((event, emit) {
      if (state is ExpensesUpdated) {
        final currentState = state as ExpensesUpdated;
        final sortedExpenses = List<Expense>.from(currentState.expenses);

        sortedExpenses.sort((a, b) => event.isAscending
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));

        isAscending = event.isAscending;
        emit(ExpensesUpdated(
            expenses: sortedExpenses, isAscending: event.isAscending));
      }
    });

    // Delete Expense
    on<RemoveExpense>((event, emit) {
      if (state is ExpensesUpdated) {
        final currentState = state as ExpensesUpdated;
        final updatedExpenses = List<Expense>.from(currentState.expenses);
        updatedExpenses.remove(event.expense);

        updatedExpenses.sort((a, b) => currentState.isAscending
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));

        emit(ExpensesUpdated(
            expenses: updatedExpenses, isAscending: currentState.isAscending));
      }
    });

    // Fetch Expenses History
    on<FetchExpensesHistory>((event, emit) {
      if (state is ExpensesUpdated) {
        emit(state);
      } else if (state is ExpensesError) {
        final errorState = state as ExpensesError;
        emit(ExpensesUpdated(
            expenses: errorState.oldExpenses, isAscending: isAscending));
      } else {
        emit(ExpensesUpdated(expenses: const [], isAscending: isAscending));
      }
    });
  }
}
