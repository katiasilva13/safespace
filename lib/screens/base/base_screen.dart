import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespace/common/custom_drawer/custom_drawer.dart';
import 'package:safespace/models/page_manager.dart';
// import 'package:safespace/screens/home/home_screen.dart';
import 'package:safespace/screens/postages/all_postages.dart';
import 'package:safespace/screens/postages/my_postages.dart';
import 'package:safespace/screens/profile/profile_screen.dart';

class BaseScreen extends StatelessWidget {
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    developer.log('log me', name: context.toString());
    return Provider(
      create: (_) => PageManager(pageController),
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          Scaffold(
            drawer: CustomDrawer(),
            appBar: AppBar(
              title: const Text('Home'),
            ),
            body: AllPostages(),
          ),
          Scaffold(
            drawer: CustomDrawer(),
            appBar: AppBar(
              title: const Text('Postagens'),
            ),
            body: MyPostages(),
          ),
          Scaffold(
            drawer: CustomDrawer(),
            appBar: AppBar(
              title: const Text('Meu Perfil'),
            ),
            body: ProfileScreen(),
          ),
          // Scaffold(
          //   drawer: CustomDrawer(),
          //   appBar: AppBar(
          //     title: const Text('Moderação'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
