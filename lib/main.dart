import 'package:application/firebase_options.dart';
import 'package:application/widgets/Authentication/login.dart';
import 'package:application/widgets/commsRepo/commsRepo.dart';
import 'package:application/widgets/homepage.dart';
import 'package:application/widgets/sell/Mpesa.dart';
import 'package:application/widgets/sell/SellPage.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Appbloc()),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'pos',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  return POSHomePage();
                  //  MpesaDemo(title: "mpesa");
                  // POSHomePage();
                }

                return  LoginScreen();
                // MpesaDemo(title: "Mpesa");
                LoginScreen();
                //  const
                //  LoginScreen()
              },
            )

            //  SalePage()
            //  const LoginScreen()
            ));
  }
}
