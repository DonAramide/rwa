import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/asset.dart';
import '../providers/portfolio_provider.dart';

class PortfolioExportService {
  static const String _companyName = 'RWA Platform';
  static const String _companyAddress = 'Real World Asset Investment Platform';

  /// Export portfolio data to PDF format
  static Future<Uint8List> exportToPdf({
    required List<Holding> holdings,
    required PortfolioSummary? summary,
    required String investorName,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Load logo if available
    pw.ImageProvider? logo;
    try {
      final logoBytes = await rootBundle.load('assets/images/logo.png');
      logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Logo not found, continue without it
      logo = null;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return [
            // Header
            _buildPdfHeader(logo, now),
            pw.SizedBox(height: 30),

            // Portfolio Summary
            _buildPdfPortfolioSummary(summary, investorName),
            pw.SizedBox(height: 30),

            // Holdings Table
            _buildPdfHoldingsTable(holdings),
            pw.SizedBox(height: 20),

            // Performance Summary
            _buildPdfPerformanceSummary(holdings),

            // Footer
            pw.Spacer(),
            _buildPdfFooter(now),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  /// Export portfolio data to CSV format
  static Future<String> exportToCsv({
    required List<Holding> holdings,
    required PortfolioSummary? summary,
  }) async {
    final List<List<dynamic>> csvData = [];

    // Add header row
    csvData.add([
      'Asset Title',
      'Asset Type',
      'Balance',
      'Value (USD)',
      'Return %',
      'Monthly Income (USD)',
      'Locked Balance',
      'Last Updated'
    ]);

    // Add holdings data
    for (final holding in holdings) {
      csvData.add([
        holding.assetTitle,
        holding.assetType,
        holding.balance.toStringAsFixed(4),
        holding.value.toStringAsFixed(2),
        holding.returnPercent.toStringAsFixed(2),
        holding.monthlyIncome.toStringAsFixed(2),
        holding.lockedBalance.toStringAsFixed(4),
        holding.updatedAt.toIso8601String(),
      ]);
    }

    // Add summary row
    if (summary != null) {
      csvData.add([]);  // Empty row
      csvData.add(['PORTFOLIO SUMMARY']);
      csvData.add(['Total Value', summary.totalValue.toStringAsFixed(2)]);
      csvData.add(['Total Holdings', summary.totalHoldings.toString()]);
      csvData.add(['Total Return %', summary.totalReturn.toStringAsFixed(2)]);
      csvData.add(['Monthly Income', summary.monthlyIncome.toStringAsFixed(2)]);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  /// Save CSV data to file and return the file path
  static Future<String> saveCsvToFile(String csvData, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.csv');
      await file.writeAsString(csvData);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save CSV file: $e');
    }
  }

  /// Print PDF or save to file
  static Future<void> printPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(onLayout: (format) => pdfData);
  }

  static pw.Widget _buildPdfHeader(pw.ImageProvider? logo, DateTime date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logo != null)
              pw.Image(logo, width: 60, height: 60)
            else
              pw.Container(
                width: 60,
                height: 60,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'RWA',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
            pw.SizedBox(height: 8),
            pw.Text(
              _companyName,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              _companyAddress,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'PORTFOLIO STATEMENT',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated: ${_formatDate(date)}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPdfPortfolioSummary(
    PortfolioSummary? summary,
    String investorName,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Portfolio Summary - $investorName',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildSummaryItem(
                  'Total Value',
                  '\$${summary?.totalValue.toStringAsFixed(2) ?? '0.00'}',
                ),
              ),
              pw.Expanded(
                child: _buildSummaryItem(
                  'Total Holdings',
                  summary?.totalHoldings.toString() ?? '0',
                ),
              ),
              pw.Expanded(
                child: _buildSummaryItem(
                  'Total Return',
                  '${summary?.totalReturn.toStringAsFixed(1) ?? '0.0'}%',
                ),
              ),
              pw.Expanded(
                child: _buildSummaryItem(
                  'Monthly Income',
                  '\$${summary?.monthlyIncome.toStringAsFixed(2) ?? '0.00'}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfHoldingsTable(List<Holding> holdings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Holdings Details',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue100),
              children: [
                _buildTableCell('Asset Title', isHeader: true),
                _buildTableCell('Type', isHeader: true),
                _buildTableCell('Balance', isHeader: true),
                _buildTableCell('Value (\$)', isHeader: true),
                _buildTableCell('Return %', isHeader: true),
                _buildTableCell('Monthly Income (\$)', isHeader: true),
              ],
            ),
            // Data rows
            ...holdings.map((holding) => pw.TableRow(
              children: [
                _buildTableCell(holding.assetTitle),
                _buildTableCell(holding.assetType),
                _buildTableCell(holding.balance.toStringAsFixed(2)),
                _buildTableCell(holding.value.toStringAsFixed(2)),
                _buildTableCell(
                  '${holding.returnPercent >= 0 ? '+' : ''}${holding.returnPercent.toStringAsFixed(1)}%',
                ),
                _buildTableCell(holding.monthlyIncome.toStringAsFixed(2)),
              ],
            )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blue900 : PdfColors.grey800,
        ),
      ),
    );
  }

  static pw.Widget _buildPdfPerformanceSummary(List<Holding> holdings) {
    if (holdings.isEmpty) return pw.Container();

    final totalValue = holdings.fold<double>(0.0, (sum, h) => sum + h.value);
    final totalIncome = holdings.fold<double>(0.0, (sum, h) => sum + h.monthlyIncome);
    final avgReturn = holdings.fold<double>(0.0, (sum, h) => sum + h.returnPercent) / holdings.length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Performance Analysis',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('Total Portfolio Value: \$${totalValue.toStringAsFixed(2)}'),
              ),
              pw.Expanded(
                child: pw.Text('Total Monthly Income: \$${totalIncome.toStringAsFixed(2)}'),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('Average Return: ${avgReturn.toStringAsFixed(1)}%'),
              ),
              pw.Expanded(
                child: pw.Text('Total Assets: ${holdings.length}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(DateTime date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generated by $_companyName',
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          'Page ${date.millisecondsSinceEpoch}',
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

