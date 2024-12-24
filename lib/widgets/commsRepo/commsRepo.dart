import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser = firebaseAuth.currentUser;
// Map<String, dynamic> loginBody = {"email": "", "password": ""};
