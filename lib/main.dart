import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savvy_track/blocs/budget/bloc/budget_bloc.dart';
import 'package:savvy_track/blocs/expense/bloc/expense_bloc.dart';
import 'package:savvy_track/pages/splash_page.dart';

void main() {
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (_) => BudgetBloc()),
    BlocProvider(create: (_) => ExpenseBloc()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Primary Color
        primaryColor: Colors.blue,

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Text Theme
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18.0, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
          labelLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),

        // Input Decoration Theme
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          labelStyle: TextStyle(color: Colors.blueAccent),
        ),

        // Icon Theme
        iconTheme: const IconThemeData(
          color: Colors.blueAccent,
          size: 24.0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
