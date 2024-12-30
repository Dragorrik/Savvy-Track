import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:equatable/equatable.dart';
import 'package:savvy_track/models/expense_model.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  bool isAscending = true; // Sorting order
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ExpenseBloc() : super(PracticePartTwoInitial()) {
    // Stream Expenses (Real-Time Updates)
    on<StreamExpenses>((event, emit) async {
      await emit.forEach(
        _firestore.collection('expenses').snapshots(), // Firestore Stream
        onData: (snapshot) {
          // Convert documents to Expense objects
          final expenses = snapshot.docs
              .map((doc) =>
                  Expense.fromMap(doc.data(), id: doc.id)) // Assign ID here
              .toList();

          // Sort based on order preference
          expenses.sort((a, b) => isAscending
              ? a.amount.compareTo(b.amount)
              : b.amount.compareTo(a.amount));

          return ExpensesUpdated(expenses: expenses, isAscending: isAscending);
        },
        onError: (error, stackTrace) {
          return _emitErrorState("Failed to stream expenses. Error: $error");
        },
      );
    });

    // Add Expense
    on<AddExpenses>((event, emit) async {
      try {
        // Add new expense to Firestore with auto-generated ID
        await _firestore.collection('expenses').add(event.expense.toMap());
      } catch (e) {
        emit(_emitErrorState("Failed to add expense. Error: $e"));
      }
    });

    // Update Expense Event
    on<UpdateExpense>((event, emit) async {
      try {
        // Ensure ID exists before updating
        if (event.updatedExpense.id != null) {
          // Check for ID existence
          await _firestore
              .collection('expenses')
              .doc(event.updatedExpense.id) // Use the stored ID
              .update(event.updatedExpense.toMap());

          // Fetch the updated list
          add(StreamExpenses());
        } else {
          emit(_emitErrorState("Expense ID is missing!"));
        }
      } catch (e) {
        emit(_emitErrorState("Failed to update expense. Error: $e"));
      }
    });

    // Delete Expense
    on<RemoveExpense>((event, emit) async {
      try {
        if (event.expense.id != null) {
          // Check for ID existence
          await _firestore
              .collection('expenses')
              .doc(event.expense.id)
              .delete();
        } else {
          emit(_emitErrorState("Expense ID is missing!"));
        }
      } catch (e) {
        emit(_emitErrorState("Failed to delete expense. Error: $e"));
      }
    });

    // Sort Expenses (in-memory sorting)
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

    // Fetch Expenses History (One-time fetch)
    on<FetchExpensesHistory>((event, emit) async {
      try {
        final querySnapshot = await _firestore.collection('expenses').get();

        final expenses = querySnapshot.docs
            .map((doc) => Expense.fromMap(doc.data(), id: doc.id))
            .toList();

        expenses.sort((a, b) => isAscending
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));

        emit(ExpensesUpdated(expenses: expenses, isAscending: isAscending));
      } catch (e) {
        emit(_emitErrorState("Failed to fetch expenses. Error: $e"));
      }
    });
  }

  // Helper method for error states
  ExpensesError _emitErrorState(String message) {
    if (state is ExpensesUpdated) {
      final currentState = state as ExpensesUpdated;
      return ExpensesError(
          oldExpenses: currentState.expenses, message: message);
    } else {
      return const ExpensesError(
          oldExpenses: [], message: "An error occurred.");
    }
  }
}
