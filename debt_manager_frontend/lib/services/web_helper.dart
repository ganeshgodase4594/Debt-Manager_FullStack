// Web-specific helper for HTML operations
// This file should only be imported on web platforms

import 'dart:html' as html;
import 'dart:typed_data';

/// Download PDF file for web platform
void downloadPdfForWeb(Uint8List pdfBytes, String customerName) {
  final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url);
  anchor.download = 'expense_report_${customerName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  anchor.click();
  html.Url.revokeObjectUrl(url);
}
