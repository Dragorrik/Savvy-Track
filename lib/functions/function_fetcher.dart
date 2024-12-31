import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:savvy_track/models/expense_model.dart';
import 'package:savvy_track/widgets/pop_up_widgets.dart';

class FunctionFetcher {
  /// Generate and Save PDF
  Future<void> downloadAsPdf(
      BuildContext context, List<Expense> expenses) async {
    final pdf = pw.Document();

    // Create PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Expense Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Title', 'Amount'],
                data: expenses
                    .map((e) => [e.title, "\$${e.amount.toStringAsFixed(2)}"])
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    try {
      // Request permission to access storage (Android)
      await Permission.storage.request();

      // Check if permission is granted
      if (await Permission.storage.isGranted) {
        // App-specific storage directory or external storage
        final directory = await getExternalStorageDirectory(); // For Android

        // Create PDF file path
        final file = File('${directory?.path}/expenses_report.pdf');
        await file.writeAsBytes(await pdf.save());

        PopUpWidgets.showBlurredSnackBar(
            context, "PDF Saved at: ${file.path}"); // Success

        // Optional: Open PDF Viewer
        // OpenFile.open(file.path);
      } else {
        PopUpWidgets.showBlurredSnackBar(context, "Storage permission denied",
            isSuccess: false); // Error handling
      }
    } catch (e) {
      PopUpWidgets.showBlurredSnackBar(context, "Error saving PDF: $e",
          isSuccess: false); // Error
    }
  }
}
