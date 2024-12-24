import 'package:application/widgets/Authentication/EmailVerfication.dart';
import 'package:application/widgets/Authentication/login.dart';
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

  static SignUpEmailPassword(
      {required Map<String, dynamic> SignupBody,
      required BuildContext context}) async {
    Appbloc bloc = context.read<Appbloc>();
    try {
      print(SignupBody);
      bloc.changeLoading(true);
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: SignupBody["email"], password: SignupBody["password"])
          .then((value) {
        bloc.changeLoading(false);
        Globals.switchScreens(context: context, screen: EmailVerification());
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
          title: Text("SignUp Error"),
          description: Text(e.code.toString()),
          animationDuration: Duration(milliseconds: 100),
          autoDismiss: true,
        ).show(context);
        print(e.code);
      }
    }
  }

  static forgotPassword(
      {required BuildContext context, required String email}) async {
    Appbloc bloc = context.read<Appbloc>();
    try {
      bloc.changeLoading(true);
      firebaseAuth.sendPasswordResetEmail(email: email).then((value) {
        CherryToast.success(
          title: Text("Email Sent"),
          description: Text("Please check your email to reset your password"),
          animationDuration: Duration(milliseconds: 400),
          autoDismiss: true,
        ).show(context);
      });

      bloc.changeLoading(false);
      Future.delayed(Duration(seconds: 10)).then((onValue) =>
          Globals.switchScreens(context: context, screen: LoginScreen()));
    } on FirebaseAuthException catch (e) {
      bloc.changeLoading(true);
      CherryToast.error(
        title: Text("Email Reset"),
        description: Text("Error $e"),
        animationDuration: Duration(milliseconds: 100),
        autoDismiss: true,
      ).show(context);
    }
  }
}
