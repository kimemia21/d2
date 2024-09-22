import 'package:flutter/material.dart';

class Appbloc extends ChangeNotifier {
  bool _isloading = false;
  Future? _categories;

  get isloading => _isloading;
  get categories => _categories;

  void changeLoading(bool loading) {
    _isloading = loading;
    notifyListeners();
  }

  

}
