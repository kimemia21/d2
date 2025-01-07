// lib/services/payment_service.dart

import 'dart:convert';
import 'package:application/widgets/commsRepo/commsRepo.dart';
import 'package:application/widgets/sell/Mpesa.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   static const String _baseUrl = 'http://localhost:3000';
  
  // ... your existing MpesaService code ...

  Future<void> handlePayment({
    required String phoneNumber,
    required double amount,
    required String reference,
    required BuildContext context,
    required String userId,  
  }) async {
    final Appbloc bloc = context.read<Appbloc>();
    
    try {
      bloc.changeLoading(true);
      
   
      final stkResponse = await  MpesaService().initiatePayment(
        phoneNumber: phoneNumber,
        amount: amount,
        reference: reference,
        context: context,
      );
      
      // 2. Save initial transaction record to Firestore
      final String checkoutRequestId = stkResponse['CheckoutRequestID'];
      await _saveTransaction(
        userId: userId,
        checkoutRequestId: checkoutRequestId,
        amount: amount,
        phoneNumber: phoneNumber,
        reference: reference,
        status: 'PENDING',
      );
      
      // 3. Start checking transaction status
      await _checkTransactionStatus(
        checkoutRequestId: checkoutRequestId,
        userId: userId,
        context: context,
        phoneNumber: phoneNumber,
        reference: reference, 
        
        amount: amount,
      );
      
    } catch (e) {
      bloc.changeLoading(false);
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }

  Future<void> _saveTransaction({
    required String userId,
    required String checkoutRequestId,
    required double amount,
    required String phoneNumber,
    required String reference,
    required String status,
    Map<String, dynamic>? resultData,
  }) async {
    await _firestore.collection('transactions').doc(checkoutRequestId).set({
      'userId': userId,
      'checkoutRequestId': checkoutRequestId,
      'amount': amount,
      'phoneNumber': phoneNumber,
      'reference': reference,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'resultData': resultData,
    });
  }

  Future<void> _checkTransactionStatus({
    required String checkoutRequestId,
    required String userId,
    required BuildContext context,
    required double amount,
    required String phoneNumber,
    required String reference
  }) async {
    final bloc = context.read<Appbloc>();
    
    // Wait for 10 seconds before first check
    await Future.delayed(const Duration(seconds: 5));
    
    try {
      final timestamp =MpesaService().generateTimestamp();
      final password = MpesaService().generatePassword();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/checktransaction'),
        headers: {
          'Authorization': 'Bearer ${await MpesaService().getAccessToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'BusinessShortCode':shortCode,
          'Password': password,
          'Timestamp': timestamp,
          'CheckoutRequestID': checkoutRequestId,
        }),
      );

      if (response.statusCode == 200) {
        final resultData = jsonDecode(response.body);
        final resultCode = resultData['ResultCode']?.toString();
        
        // Update transaction in Firestore
        if (resultCode == '0') {
          // Payment successful
          await _saveTransaction(
            userId: userId,
            checkoutRequestId: checkoutRequestId,
            amount: amount,
            phoneNumber: phoneNumber,
            reference: reference,
            status: 'COMPLETED',
            resultData: resultData,
          );
          
          // Update UI
          bloc.changeLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!')),
          );
          
          // Handle successful payment (e.g., update order status, navigate to success screen)
          _handleSuccessfulPayment(context, checkoutRequestId);
          
        } else if (resultCode == '1') {
          // Payment failed
          await _saveTransaction(
            userId: userId,
            checkoutRequestId: checkoutRequestId,
            amount: amount,
            phoneNumber: phoneNumber,
            reference: reference,
            status: 'FAILED',
            resultData: resultData,
          );
          
          bloc.changeLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment failed: ${resultData['ResultDesc']}')),
          );
          
        } else {
          // Payment still pending, check again
          await Future.delayed(const Duration(seconds: 5));
          await _checkTransactionStatus(
            checkoutRequestId: checkoutRequestId,
            userId: userId,
            context: context,
            phoneNumber: phoneNumber,
            amount: amount,
            reference: reference
          );
        }
      }
    } catch (e) {
      bloc.changeLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking payment status: $e')),
      );
    }
  }

  Future<void> _handleSuccessfulPayment(BuildContext context, String checkoutRequestId) async {
    try {
      // 1. Get the transaction from Firestore
      final transactionDoc = await _firestore
          .collection('transactions')
          .doc(checkoutRequestId)
          .get();
      
      // 2. Update any related orders or records
      // Example: Update order status
      if (transactionDoc.exists) {
        final orderRef = transactionDoc.data()?['reference'];
        if (orderRef != null) {
          await _firestore.collection('orders').doc(orderRef).update({
            'paymentStatus': 'PAID',
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      }

      // 3. Navigate to success screen
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PaymentSuccessScreen(
      //       transactionId: checkoutRequestId,
      //     ),
      //   ),
      // );
    } catch (e) {
      print('Error handling successful payment: $e');
    }
  }
}