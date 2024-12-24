import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/commsRepo/commsRepo.dart';
import 'package:application/widgets/homepage.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirebaseReq {
  static loginEmailPassword(
      {required Map<String, dynamic> loginBody,
      required BuildContext context}) async {
    Appbloc bloc = context.read<Appbloc>();
    try {
      print(loginBody);
      bloc.changeLoading(true);
      await firebaseAuth
          .signInWithEmailAndPassword(
              email: loginBody["email"], password: loginBody["password"])
          .then((value) {
            
      bloc.changeLoading(false);
        Globals.switchScreens(context: context, screen: MotorbikePOSHomePage());
        print(value);
      });
    } on FirebaseAuthException catch (e) {
      
      bloc.changeLoading(false);
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
