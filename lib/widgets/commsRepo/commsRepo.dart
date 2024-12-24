import 'package:application/widgets/state/AppBloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser = firebaseAuth.currentUser;
// BuildContext context = context;
// Appbloc Readbloc = context.read<Appbloc>();
// Appbloc watchBloc = context.watch<Appbloc>();
  

// Map<String, dynamic> loginBody = {"email": "", "password": ""};
