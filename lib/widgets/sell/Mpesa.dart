// lib/services/mpesa_service.dart

import 'dart:convert';
import 'package:application/main.dart';
import 'package:application/widgets/commsRepo/commsRepo.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MpesaService {
  // Replace these with your actual credentials
  // static  String _consumerKey = consumerKey;
  // static  String _consumerSecret = 'YOUR_CONSUMER_SECRET';
  // static  String _passKey = 'YOUR_PASS_KEY';
  // static  String _shortCode = 'YOUR_BUSINESS_SHORTCODE';
  // static  String _callbackUrl = 'YOUR_CALLBACK_URL';

  // Base URLs
  static const String _baseUrl = 'http://localhost:3000';

  // Get OAuth token
  Future<String> _getAccessToken() async {
    try {
      final credentials =
          base64Encode(utf8.encode('$consumerKey:$consumerSecret'));

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/get-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $credentials',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['access_token'] != null) {
          return jsonResponse['access_token'];
        } else {
          throw Exception('Invalid token response: ${response.body}');
        }
      } else {
        throw Exception(
            'Failed to get access token. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while getting access token: $e');
    }
  }

  // Generate password
  String _generatePassword() {
    final timestamp =
        DateTime.now().toString().substring(0, 8).replaceAll('-', '');
    final String password = base64Encode(utf8.encode('$shortCode$timestamp'));
    return password;
  }

  // Initiate STK Push
  Future<Map<String, dynamic>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String reference,
    required BuildContext context,
  }) async {
    Appbloc bloc = context.read<Appbloc>();
    try {
      bloc.changeLoading(true);
      final token = await _getAccessToken();
      final timestamp =
          DateTime.now().toString().substring(0, 8).replaceAll('-', '');

      // Format phone number
      phoneNumber = phoneNumber.replaceAll(RegExp(r'^0|^\+254'), '254');

      final payload = {
        'BusinessShortCode': shortCode,
        'Password': _generatePassword(),
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.round(),
        'PartyA': phoneNumber,
        'PartyB': shortCode,
        'PhoneNumber': phoneNumber,
        'CallBackURL': callBackUrl,
        'AccountReference': reference,
        'TransactionDesc': 'Payment for $reference'
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/mpesa/stkpush'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        
      bloc.changeLoading(false);
        return jsonDecode(response.body);
      } else {
        
      bloc.changeLoading(false);
        throw Exception(
            'STK push failed. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      
      bloc.changeLoading(false);
      throw Exception('Error processing payment: $e');
    }
  }

  // Check transaction status
  Future<Map<String, dynamic>> checkTransactionStatus(
      String checkoutRequestId) async {
    try {
      final token = await _getAccessToken();
      final timestamp =
          DateTime.now().toString().substring(0, 8).replaceAll('-', '');

      final body = {
        'BusinessShortCode': shortCode,
        'Password': _generatePassword(),
        'Timestamp': timestamp,
        'CheckoutRequestID': checkoutRequestId
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpushquery/v1/query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error checking status: $e');
    }
  }
}
