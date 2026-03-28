import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BillingService {
  // PUT YOUR REAL BACKEND URL HERE
  // Example: https://strategos-backend.onrender.com
  final String baseUrl = 'https://YOUR-RENDER-BACKEND.onrender.com';

  Future<void> startZiinaPayment({
    required String planCode,
    bool test = true,
  }) async {
    final uri = Uri.parse('$baseUrl/billing/create-payment');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'plan_code': planCode,
        'test': test,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Payment failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final redirectUrl = data['redirect_url'] as String?;

    if (redirectUrl == null || redirectUrl.isEmpty) {
      throw Exception('No redirect URL returned from backend');
    }

    final launched = await launchUrl(
      Uri.parse(redirectUrl),
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Could not open Ziina checkout');
    }
  }
}