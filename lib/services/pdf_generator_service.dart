import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/models/company_model.dart';
import '../data/models/function_model.dart';
import '../data/models/event_material_model.dart';

class PdfGeneratorService {
  /// Generates the exact 3-column traditional grocery list matching the user reference
  static Future<Uint8List> generateMaterialPdf({
    required CompanyModel company,
    required FunctionModel function,
    required List<EventMaterialModel> materials,
    required String langCode, // 'en', 'hi', 'mr', 'gu'
  }) async {
    final pdf = pw.Document();

    // Load appropriate Unicode fonts for Hindi, Marathi, Gujarati, English
    pw.Font fontRegular;
    pw.Font fontBold;

    try {
      if (langCode == 'hi' || langCode == 'mr') {
        fontRegular = await PdfGoogleFonts.notoSansDevanagariRegular();
        fontBold = await PdfGoogleFonts.notoSansDevanagariBold();
      } else if (langCode == 'gu') {
        fontRegular = await PdfGoogleFonts.notoSansGujaratiRegular();
        fontBold = await PdfGoogleFonts.notoSansGujaratiBold();
      } else {
        fontRegular = await PdfGoogleFonts.robotoRegular();
        fontBold = await PdfGoogleFonts.robotoBold();
      }
    } catch (e) {
      debugPrint('Font loading fallback: $e');
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    // Localized Headers & Titles
    final String sheetTitle;
    final String subTitle;
    final String noLabel;
    final String customerLabel;
    final String dateLabel;
    final String noteText;
    final String itemColLabel;
    final String qtyColLabel;
    final String footerNote;
    final String paxLabel;

    if (langCode == 'hi') {
      sheetTitle = company.name;
      subTitle = 'हाथ से लिखी किराना व सामग्री सूची';
      noLabel = 'क्रमांक';
      customerLabel = 'ग्राहक / पार्टी';
      dateLabel = 'तारीख';
      noteText = 'नोट: दाल, चावल, मटर, तुअर, गेहूं, मसाले आदि सभी आवश्यक सामान।';
      itemColLabel = 'वस्तु / सामान';
      qtyColLabel = 'मात्रा';
      footerNote = 'नोट: यह सूची खान-पान की आवश्यकतानुसार तैयार की गई है। कृपया रवानगी से पूर्व मिलान कर लें।';
      paxLabel = 'मेहमान';
    } else if (langCode == 'mr') {
      sheetTitle = company.name;
      subTitle = 'कॅटरिंग किराणा व साहित्य हथ-यादी';
      noLabel = 'अनुक्रमांक';
      customerLabel = 'ग्राहक / यजमान';
      dateLabel = 'तारीख';
      noteText = 'टीप: डाळी, तांदूळ, वाटाणा, मसाले इत्यादी सर्व आवश्यक साहित्य.';
      itemColLabel = 'वस्तू / साहित्य';
      qtyColLabel = 'प्रमाण';
      footerNote = 'टीप: ही यादी स्वयंपाकाच्या गरजेनुसार तयार केली आहे. रवाना करण्यापूर्वी खात्री करावी.';
      paxLabel = 'पंगत / माणसे';
    } else if (langCode == 'gu') {
      sheetTitle = company.name;
      subTitle = 'હાથથી લખેલી કરિયાણા અને સામગ્રીની યાદી';
      noLabel = 'નંબર';
      customerLabel = 'ગ્રાહક / પાર્ટી';
      dateLabel = 'તારીખ';
      noteText = 'નોંધ: દાળ, ચોખા, વટાણા, મસાલા વગેરે તમામ જરૂરી કરિયાણા સામાન.';
      itemColLabel = 'વસ્તુ';
      qtyColLabel = 'જથ્થો';
      footerNote = 'નોંધ: આ યાદી રસોઈ જરૂરિયાત મુજબ તૈયાર કરવામાં આવી છે. માલ રવાના કરતાં પહેલાં ચકાસવું.';
      paxLabel = 'માણસો';
    } else {
      sheetTitle = company.name;
      subTitle = 'Catering Grocery & Ingredient Sheet';
      noLabel = 'No.';
      customerLabel = 'Client / Party';
      dateLabel = 'Date';
      noteText = 'Note: Dal, Rice, Peas, Spices etc. all catering ingredients as per order.';
      itemColLabel = 'Item';
      qtyColLabel = 'Quantity';
      footerNote = 'Note: Prepared as per catering standard format. Verify quantities before dispatch.';
      paxLabel = 'Pax';
    }

    // Build the 3-column rows
    // Split materials into 3 equal chunks for side-by-side presentation
    final itemsCount = materials.length;
    final int rowsPerColumn = (itemsCount / 3).ceil().clamp(15, 40);

    final List<List<EventMaterialModel?>> matrix = [];
    for (int r = 0; r < rowsPerColumn; r++) {
      final EventMaterialModel? col1 = r < itemsCount ? materials[r] : null;
      final EventMaterialModel? col2 = (r + rowsPerColumn) < itemsCount ? materials[r + rowsPerColumn] : null;
      final EventMaterialModel? col3 = (r + 2 * rowsPerColumn) < itemsCount ? materials[r + 2 * rowsPerColumn] : null;
      matrix.add([col1, col2, col3]);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header Banner (Burgundy / Navy)
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: const PdfColor(0.55, 0.12, 0.12), // Deep red/burgundy as in reference
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: pw.Column(
                  children: [
                    pw.Text(
                      sheetTitle.toUpperCase(),
                      style: pw.TextStyle(
                        font: fontBold,
                        color: PdfColors.white,
                        fontSize: 16,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      subTitle,
                      style: pw.TextStyle(
                        font: fontRegular,
                        color: PdfColors.white,
                        fontSize: 11,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 4),

              // 2. Info Bar (Event ID, Customer, Date, Phone, Location)
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: const PdfColor(0.98, 0.94, 0.94),
                  border: pw.Border.all(color: const PdfColor(0.75, 0.3, 0.3), width: 0.8),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '$noLabel: ${function.id}',
                          style: pw.TextStyle(font: fontBold, fontSize: 8.5),
                        ),
                        pw.Text(
                          '$customerLabel: ${function.customerName}',
                          style: pw.TextStyle(font: fontBold, fontSize: 8.5),
                        ),
                        pw.Text(
                          '$dateLabel: ${function.eventDate}',
                          style: pw.TextStyle(font: fontBold, fontSize: 8.5),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          company.address.isNotEmpty ? company.address : 'Location',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8),
                        ),
                        pw.Text(
                          'Phone: ${company.phone}',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8),
                        ),
                        pw.Text(
                          '$paxLabel: ${function.guestCount}',
                          style: pw.TextStyle(font: fontBold, color: const PdfColor(0.55, 0.12, 0.12), fontSize: 8.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 3),

              // 3. Note Banner
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: const PdfColor(0.97, 0.97, 0.97),
                  border: pw.Border.all(color: const PdfColor(0.8, 0.4, 0.4), width: 0.6),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 6),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      noteText,
                      style: pw.TextStyle(font: fontRegular, fontSize: 7.5),
                    ),
                    pw.Text(
                      function.eventDate,
                      style: pw.TextStyle(font: fontBold, fontSize: 7.5),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 4),

              // 4. 3-Column Table Grid
              pw.Expanded(
                child: pw.Table(
                  border: pw.TableBorder.all(color: const PdfColor(0.75, 0.3, 0.3), width: 0.5),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2.2), // Col 1 Item
                    1: pw.FlexColumnWidth(1.1), // Col 1 Qty
                    2: pw.FlexColumnWidth(2.2), // Col 2 Item
                    3: pw.FlexColumnWidth(1.1), // Col 2 Qty
                    4: pw.FlexColumnWidth(2.2), // Col 3 Item
                    5: pw.FlexColumnWidth(1.1), // Col 3 Qty
                  },
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColor(0.97, 0.88, 0.88),
                      ),
                      children: [
                        _buildTableHeaderCell(itemColLabel, fontBold),
                        _buildTableHeaderCell(qtyColLabel, fontBold),
                        _buildTableHeaderCell(itemColLabel, fontBold),
                        _buildTableHeaderCell(qtyColLabel, fontBold),
                        _buildTableHeaderCell(itemColLabel, fontBold),
                        _buildTableHeaderCell(qtyColLabel, fontBold),
                      ],
                    ),
                    // Data Rows
                    ...matrix.map((row) {
                      final m1 = row[0];
                      final m2 = row[1];
                      final m3 = row[2];

                      return pw.TableRow(
                        children: [
                          _buildTableCell(m1?.getLocalizedName(langCode) ?? '-', fontRegular, alignLeft: true),
                          _buildTableCell(_formatQty(m1), fontBold),
                          _buildTableCell(m2?.getLocalizedName(langCode) ?? '-', fontRegular, alignLeft: true),
                          _buildTableCell(_formatQty(m2), fontBold),
                          _buildTableCell(m3?.getLocalizedName(langCode) ?? '-', fontRegular, alignLeft: true),
                          _buildTableCell(_formatQty(m3), fontBold),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              pw.SizedBox(height: 4),

              // 5. Footer Note
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                decoration: pw.BoxDecoration(
                  color: const PdfColor(0.98, 0.94, 0.94),
                  border: pw.Border.all(color: const PdfColor(0.8, 0.4, 0.4), width: 0.6),
                ),
                child: pw.Text(
                  footerNote,
                  style: pw.TextStyle(font: fontRegular, fontSize: 7, color: const PdfColor(0.55, 0.12, 0.12)),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTableHeaderCell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 7.5,
          color: const PdfColor(0.55, 0.12, 0.12),
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {bool alignLeft = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 3),
      alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 7,
          color: PdfColors.black,
        ),
        maxLines: 1,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  static String _formatQty(EventMaterialModel? item) {
    if (item == null) return '-';
    if (item.quantity <= 0) return '-';

    final q = item.quantity;
    final isInt = q == q.roundToDouble();
    final qStr = isInt ? q.toInt().toString() : q.toStringAsFixed(1);
    return '$qStr ${item.unit}';
  }

  /// Share PDF directly to WhatsApp or Android/iOS share sheet
  static Future<void> shareMaterialPdf({
    required CompanyModel company,
    required FunctionModel function,
    required List<EventMaterialModel> materials,
    required String langCode,
  }) async {
    final pdfBytes = await generateMaterialPdf(
      company: company,
      function: function,
      materials: materials,
      langCode: langCode,
    );

    final tempDir = await getTemporaryDirectory();
    final safeName = function.eventName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final file = File('${tempDir.path}/Material_List_${function.id}_$safeName.pdf');
    await file.writeAsBytes(pdfBytes);

    final caption = '📋 *${company.name}*\n'
        'Event: *${function.eventName}*\n'
        'Date: *${function.eventDate}*\n'
        'Pax: *${function.guestCount} People*\n'
        'Material & Spices grocery list attached.';

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Material_List_${function.id}_$safeName.pdf',
      subject: '${company.name} - Material List for ${function.eventName}',
      body: caption,
    );
  }

  /// Print or Open native PDF preview
  static Future<void> printOrPreviewMaterialPdf({
    required CompanyModel company,
    required FunctionModel function,
    required List<EventMaterialModel> materials,
    required String langCode,
  }) async {
    final pdfBytes = await generateMaterialPdf(
      company: company,
      function: function,
      materials: materials,
      langCode: langCode,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Material_List_${function.id}',
    );
  }

  /// Direct Phone Dialer launcher
  static Future<void> launchPhoneCall({required String phone}) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    final telUri = Uri.parse('tel:$cleaned');
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        await launchUrl(telUri);
      }
    } catch (e) {
      debugPrint('Could not launch phone call for $cleaned: $e');
    }
  }

  /// Direct WhatsApp chat launcher with prefilled message
  static Future<void> launchWhatsAppChat({
    required String phone,
    String message = '',
  }) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    String formattedPhone = cleaned;
    if (!formattedPhone.startsWith('+') && formattedPhone.length == 10) {
      formattedPhone = '+91$formattedPhone';
    }
    // Remove plus for wa.me URL
    final urlPhone = formattedPhone.replaceAll('+', '');

    final encodedMsg = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('whatsapp://send?phone=$urlPhone&text=$encodedMsg');
    final webUrl = Uri.parse('https://wa.me/$urlPhone?text=$encodedMsg');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch WhatsApp for $formattedPhone: $e');
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }
}
