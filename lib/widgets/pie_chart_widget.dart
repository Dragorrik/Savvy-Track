import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:savvy_track/models/expense_model.dart';

Widget buildPieChart(List<Expense> expenses, BuildContext context) {
  Map<String, double> expenseData = {};
  for (var expense in expenses) {
    expenseData[expense.title] =
        (expenseData[expense.title] ?? 0) + expense.amount;
  }

  return SizedBox(
    height: MediaQuery.of(context).size.height * .35,
    child: Stack(
      alignment: Alignment.center, // Center alignment
      children: [
        // Pie Chart
        PieChart(
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
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    value: entry.value,
                    color: Colors.primaries[
                        expenseData.keys.toList().indexOf(entry.key) %
                            Colors.primaries.length],
                    // borderSide: const BorderSide(
                    //   color: Color.fromARGB(255, 0, 0, 0), // Border color
                    //   width: 2, // Border width
                    // ),
                    radius: MediaQuery.of(context).size.aspectRatio * 215,
                    title: '', // Leave title blank for custom badge positioning
                    badgeWidget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.key.length > 8
                              ? "${entry.key.substring(0, 8)}..."
                              : entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "\$${entry.value.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    badgePositionPercentageOffset:
                        1.1, // Moves badge slightly outside the chart
                  ),
                )
                .toList(),
          ),
        ),
        // Center Image
        Positioned(
          child: CircleAvatar(
            radius:
                MediaQuery.of(context).size.aspectRatio * 107, // Adjust size
            backgroundImage: const AssetImage(
                'assets/images/add_money.png'), // Replace with your image path
            backgroundColor: Colors.white
                .withOpacity(0.5), // Optional: Transparent background
          ),
        ),
      ],
    ),
  );
}
