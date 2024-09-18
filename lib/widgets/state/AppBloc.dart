import 'package:flutter/material.dart';

class Appbloc extends ChangeNotifier {
  bool _isloading = false;
  get isloading => _isloading;

  void changeLoading(bool loading) {
    _isloading = loading;
    notifyListeners();
  }
}
