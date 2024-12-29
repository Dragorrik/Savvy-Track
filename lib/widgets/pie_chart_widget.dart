// Pie Chart Widget
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:savvy_track/blocs/budget/bloc/budget_state.dart';

Widget buildPieChart(List<Expense> expenses, BuildContext context) {
  Map<String, double> expenseData = {};
  for (var expense in expenses) {
    expenseData[expense.title] =
        (expenseData[expense.title] ?? 0) + expense.amount;
  }

  return SizedBox(
    height: MediaQuery.of(context).size.height * .4,
    child: PieChart(
      PieChartData(
        sectionsSpace: 8,
        sections: expenseData.entries
            .map(
              (entry) => PieChartSectionData(
                gradient: LinearGradient(
                  colors: [
                    Colors.primaries[
                        expenseData.keys.toList().indexOf(entry.key) %
                            Colors.primaries.length],
                    Colors.primaries[
                        expenseData.keys.toList().indexOf(entry.key) %
                                Colors.primaries.length +
                            1],
                    // const Color.fromARGB(255, 250, 250, 250),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                value: entry.value,
                color: Colors.primaries[
                    expenseData.keys.toList().indexOf(entry.key) %
                        Colors.primaries.length],
                borderSide: const BorderSide(
                  color: Color.fromARGB(129, 209, 208, 208), // Border color
                  width: 2, // Border width
                ),
                radius: 80,
                title: '', // Leave title blank for custom badge positioning
                badgeWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key.length > 8
                          ? "${entry.key.substring(0, 8)}..."
                          : entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "\$${entry.value.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 10,
                        //fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                badgePositionPercentageOffset:
                    0.7, // Moves badge slightly outside the chart
              ),
            )
            .toList(),
      ),
    ),
  );
}
