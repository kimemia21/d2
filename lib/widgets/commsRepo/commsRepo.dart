import 'package:application/widgets/state/AppBloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser = firebaseAuth.currentUser;
const String kCategoriesCollection = 'categories';
const String kBrandsCollection = 'brands';
const String kProductsCollection = 'products';
const String kStockCollection = 'stock';
const String kCustomersCollection = 'customers';
const String kSalesCollection = 'sales';
const String kReportsCollection = 'reports';
const String kTransactions = "transactions";
int called = 0;
String consumerKey = "bspX3R8pi25CdSApfLHJGZLLihGZOO9AXh0efhO7GM9iJAua";
String consumerSecret =
    "1401nIYpB92rryosrsqxbBNb8EWAA74LWwTtPEVVmRKRjEmURiY0EWFlmeHiO4ib";
String callBackUrl ="https://9b1d-102-216-154-132.ngrok-free.app/mpesa/checktransaction";
String shortCode = "174379";
String passKey =
    "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";




// BuildContext context = context;
// Appbloc Readbloc = context.read<Appbloc>();
// Appbloc watchBloc = context.watch<Appbloc>();
  

// Map<String, dynamic> loginBody = {"email": "", "password": ""};
