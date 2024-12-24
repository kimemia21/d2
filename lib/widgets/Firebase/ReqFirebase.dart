import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/commsRepo/commsRepo.dart';
import 'package:application/widgets/homepage.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseReq {
  static loginEmailPassword(
      {required Map<String, dynamic> loginBody,
      required BuildContext context}) async {
    try {
      print(loginBody);
      await firebaseAuth
          .signInWithEmailAndPassword(
              email: loginBody["email"], password: loginBody["password"])
          .then((value) {
        Globals.switchScreens(context: context, screen: MotorbikePOSHomePage());
        print(value);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        CherryToast.error(
          title: Text("Login Error"),
          description: Text(e.code.toString()),
          animationDuration: Duration(milliseconds: 100),
          autoDismiss: true,
        ).show(context);
        print(e.code);
      }
    }
  }
}
