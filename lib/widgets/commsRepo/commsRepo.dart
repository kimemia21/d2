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
int called = 0;
String consumerKey = "bspX3R8pi25CdSApfLHJGZLLihGZOO9AXh0efhO7GM9iJAua";
String consumerSecret =
    "1401nIYpB92rryosrsqxbBNb8EWAA74LWwTtPEVVmRKRjEmURiY0EWFlmeHiO4ib";
String callBackUrl =
    "https://94f9-41-90-65-205.ngrok-free.app/api/secret-url/callback";
String shortCode = "174379";




// BuildContext context = context;
// Appbloc Readbloc = context.read<Appbloc>();
// Appbloc watchBloc = context.watch<Appbloc>();
  

// Map<String, dynamic> loginBody = {"email": "", "password": ""};
