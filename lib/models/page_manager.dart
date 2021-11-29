import 'package:flutter/material.dart';

class PageManager {
  PageManager(this._pageController);

  final PageController _pageController;
  int page = 0;

  void setPage(int value) {
    if (value == page) return;
    page = value;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(value);
    }
  }
}
