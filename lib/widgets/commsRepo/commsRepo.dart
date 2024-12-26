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

// BuildContext context = context;
// Appbloc Readbloc = context.read<Appbloc>();
// Appbloc watchBloc = context.watch<Appbloc>();
  

// Map<String, dynamic> loginBody = {"email": "", "password": ""};
