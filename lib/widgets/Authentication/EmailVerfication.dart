import 'dart:async';
import 'package:application/main.dart';
import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/HomePage.dart';
import 'package:application/widgets/commsRepo/commsRepo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class Emailverification extends StatefulWidget {
  final bool isLoggedin;
  const Emailverification({this.isLoggedin = false});

  @override
  State<Emailverification> createState() => _EmailverificationState();
}

class _EmailverificationState extends State<Emailverification>
    with SingleTickerProviderStateMixin {
  late Timer timer;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    // this code is for sending verification email if the user had logged in and not verified
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    if (widget.isLoggedin) {
      FirebaseAuth.instance.currentUser?.sendEmailVerification();
    }

    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      FirebaseAuth auth = firebaseAuth;

      auth.currentUser?.reload();
      if (auth.currentUser?.emailVerified == true) {
        // addAuthData();
        timer.cancel();
        Globals.switchScreens(context: context, screen: MotorbikePOSHomePage());
      }
    });

    // Schedule the visibility change
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  // Future addAuthData() async {
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   // create a user after email verification
  //   // await firestore
  //   //     .collection("users")
  //   //     .doc(auth.currentUser?.email)
  //   //     .set({"email": auth.currentUser?.email, "performance": "0.0"});
  //   // create  auth user for authenticating only admins to the admin side
  //   await firestore
  //       .collection("auth")
  //       .doc(auth.currentUser?.email)
  //       .set({"email": auth.currentUser?.email});
  // }

  @override
  void dispose() {
    timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade100],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(-1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve: Curves.elasticOut,
                )),
                child: Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_qmfs6c3i.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Verification',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'We\'ve sent a verification link to ${firebaseAuth.currentUser?.email}.',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Please check your inbox and click the link to verify your account.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Important:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Check your spam folder if you don\'t see the email\n'
                      '• The link expires in 24 hours\n'
                      '• Make sure to use a valid email address',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 30),
                    Visibility(
                      visible: _isVisible,
                      child: ElevatedButton(
                        onPressed: () {
                          FirebaseAuth.instance.currentUser
                              ?.sendEmailVerification();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Verification email sent again'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 42, vertical: 26),
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Resend Verification Email',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // TextButton(
                    //   onPressed: () {
                    //     // Add logic to go back or cancel
                    //   },
                    //   child: Text(
                    //     'Cancel',
                    //     style: GoogleFonts.poppins(fontSize: 16, color: Colors.blue.shade900),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
