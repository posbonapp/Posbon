import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../l10n/app_localizations.dart';
import 'admin_tasks_screen.dart' show kAccent, kAccentSoft;

class TenantCardScreen extends StatelessWidget {
  final String apartmentNumber;
  final String buildingName;
  final String login;
  final String password;

  const TenantCardScreen({
    super.key,
    required this.apartmentNumber,
    required this.buildingName,
    required this.login,
    required this.password,
  });

  // Данные для QR: логин и пароль в простом формате
  String get qrData => 'posbon://login?u=$login&p=$password';

  Future<Uint8List> _buildPdf(AppLocalizations t) async {
    final doc = pw.Document();
    final qr = await QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    ).toImageData(400);
    final qrBytes = qr!.buffer.asUint8List();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        build: (ctx) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColor.fromInt(0xFF2F7D6B), width: 2),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Posbon',
                  style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF2F7D6B))),
              pw.SizedBox(height: 4),
              pw.Text(buildingName, style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 2),
              pw.Text('${t.apartment} $apartmentNumber',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Image(pw.MemoryImage(qrBytes), width: 130, height: 130),
              pw.SizedBox(height: 8),
              pw.Text(t.scanToLogin,
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE6F0EC),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${t.login}:',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    pw.Text(login,
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text('${t.password}:',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    pw.Text(password,
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.card),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Превью карточки
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kAccent, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Posbon',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: kAccent)),
                  const SizedBox(height: 4),
                  Text(buildingName,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text('${t.apartment} $apartmentNumber',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  QrImageView(
                    data: qrData,
                    size: 150,
                  ),
                  const SizedBox(height: 8),
                  Text(t.scanToLogin,
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kAccentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${t.login}:',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                        SelectableText(login,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace')),
                        const SizedBox(height: 8),
                        Text('${t.password}:',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                        SelectableText(password,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                final bytes = await _buildPdf(t);
                await Printing.layoutPdf(onLayout: (_) async => bytes);
              },
              style: FilledButton.styleFrom(
                backgroundColor: kAccent,
                minimumSize: const Size(double.infinity, 52),
              ),
              icon: const Icon(Icons.print, color: Colors.white),
              label: Text(t.printCard),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final bytes = await _buildPdf(t);
                await Printing.sharePdf(
                    bytes: bytes, filename: 'posbon_kv$apartmentNumber.pdf');
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              icon: const Icon(Icons.share, color: kAccent),
              label: Text(t.shareCard),
            ),
          ],
        ),
      ),
    );
  }
}