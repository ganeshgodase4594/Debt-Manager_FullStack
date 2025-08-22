import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:debt_manager_frontend/models/user.dart';

// Conditional imports for platform-specific functionality
import 'web_helper.dart' if (dart.library.io) 'mobile_helper.dart' as platform_helper;

class WhatsAppService {
  /// Send a report to customer via WhatsApp
  static Future<bool> sendReportToCustomer({
    required User customer,
    required Uint8List pdfBytes,
    required String reportSummary,
    required String dateRangeText,
  }) async {
    try {
      // Prepare WhatsApp message
      final message = _buildWhatsAppMessage(
        customerName: customer.fullName,
        reportSummary: reportSummary,
        dateRangeText: dateRangeText,
      );

      // Check if running on web
      if (kIsWeb) {
        // For web, we can only send the message via WhatsApp Web
        // PDF sharing is not supported on web in the same way
        return await _sendViaWhatsAppWeb(
          phoneNumber: customer.phoneNumber,
          message: message,
          pdfBytes: pdfBytes,
          customerName: customer.fullName,
        );
      } else {
        // For mobile platforms, use file-based sharing
        final tempDir = await getTemporaryDirectory();
        final fileName = 'expense_report_${customer.username}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);

        // Try to send via WhatsApp directly if phone number is available
        if (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty) {
          final success = await _sendViaWhatsAppDirect(
            phoneNumber: customer.phoneNumber!,
            message: message,
            filePath: file.path,
          );
          
          if (success) {
            return true;
          }
        }

        // Fallback: Use share functionality
        await _shareViaGeneral(
          message: message,
          filePath: file.path,
          customerName: customer.fullName,
        );
        
        return true;
      }
    } catch (e) {
      print('Error sending WhatsApp report: $e');
      return false;
    }
  }

  /// Build WhatsApp message content
  static String _buildWhatsAppMessage({
    required String customerName,
    required String reportSummary,
    required String dateRangeText,
  }) {
    return '''
🧾 *Expense Report*

Hi $customerName,

Here's your expense report for the period: $dateRangeText

📊 *Summary:*
$reportSummary

Please find the detailed PDF report attached.

Thank you!
''';
  }

  /// Send via WhatsApp Web (for web platform)
  static Future<bool> _sendViaWhatsAppWeb({
    required String? phoneNumber,
    required String message,
    required Uint8List pdfBytes,
    required String customerName,
  }) async {
    try {
      // First, trigger PDF download for web
      if (kIsWeb) {
        _downloadPdfForWeb(pdfBytes, customerName);
      }
      
      // Then open WhatsApp Web
      String whatsappUrl;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        final cleanPhone = formatPhoneForWhatsApp(phoneNumber);
        whatsappUrl = 'https://web.whatsapp.com/send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}';
      } else {
        // If no phone number, open WhatsApp Web with just the message
        whatsappUrl = 'https://web.whatsapp.com/send?text=${Uri.encodeComponent(message)}';
      }
      
      final uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error launching WhatsApp Web: $e');
      return false;
    }
  }

  /// Download PDF file for web platform
  static void _downloadPdfForWeb(Uint8List pdfBytes, String customerName) {
    if (kIsWeb) {
      platform_helper.downloadPdfForWeb(pdfBytes, customerName);
    }
  }

  /// Send via WhatsApp directly using URL scheme
  static Future<bool> _sendViaWhatsAppDirect({
    required String phoneNumber,
    required String message,
    required String filePath,
  }) async {
    try {
      // Clean phone number (remove spaces, dashes, etc.)
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // For WhatsApp, we can only send text via URL scheme
      // File sharing requires the share intent
      final whatsappUrl = 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}';
      final uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        // After opening WhatsApp, share the file separately
        await Future.delayed(Duration(seconds: 2));
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Expense Report PDF',
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Share via general sharing (fallback)
  static Future<void> _shareViaGeneral({
    required String message,
    required String filePath,
    required String customerName,
  }) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: message,
      subject: 'Expense Report for $customerName',
    );
  }

  /// Check if WhatsApp is installed
  static Future<bool> isWhatsAppInstalled() async {
    try {
      final uri = Uri.parse('https://wa.me/');
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Format phone number for WhatsApp
  static String formatPhoneForWhatsApp(String phoneNumber) {
    // Remove all non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If it doesn't start with +, assume it's an Indian number and add +91
    if (!cleaned.startsWith('+')) {
      // Remove leading 0 if present
      if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1);
      }
      // Add +91 for Indian numbers (adjust as needed for your region)
      cleaned = '+91$cleaned';
    }
    
    return cleaned;
  }
}
