import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/material.dart';

class Globals {

static final helmetData = <Map<String,dynamic>>{
  {"name":"Full Face Helmet", "totalStock": 50, "sold": 20},
 {"name": "Modular Helmet", "totalStock": 40, "sold": 15},
 {"name": "Open Face Helmet", "totalStock": 60, "sold": 25},
  {"name":"Half Helmet", "totalStock": 30, "sold": 10},
 {"name": "Off-Road Helmet", "totalStock": 25, "sold": 5},
 {"name": "Dual-Sport Helmet", "totalStock": 35, "sold": 18},
  {"name":"Adventure Helmet", "totalStock": 20, "sold": 8},
 {"name": "Racing Helmet", "totalStock": 15, "sold": 7},
  {"name":"Snowmobile Helmet", "totalStock": 10, "sold": 3},
  {"name":"Retro Helmet", "totalStock": 45, "sold": 22},
};


  static Future<void> switchScreens(
      {required BuildContext context, required Widget screen}) {
    try {
      return Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(
                milliseconds:
                    600), // Increase duration for a smoother transition
            pageBuilder: (context, animation, secondaryAnimation) => screen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final opacityTween = Tween(begin: 0.0, end: 1.0);
              final scaleTween = Tween(
                  begin: 0.95,
                  end: 1.0); // Slight scale transition for ambient effect
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve:
                    Curves.easeInOut, // Use easeInOut for a smoother transition
              );

              return FadeTransition(
                opacity: opacityTween.animate(curvedAnimation),
                child: ScaleTransition(
                  scale: scaleTween.animate(curvedAnimation),
                  child: child,
                ),
              );
            },
          ));
    } catch (e) {
      throw Exception(e);
    }
  }
}