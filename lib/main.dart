import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespace/models/user_manager.dart';
import 'package:safespace/screens/base/base_screen.dart';
import 'package:safespace/screens/login/login_screen.dart';
import 'package:safespace/screens/recovery/recovery_pass.dart';
import 'package:safespace/screens/signup/signup_screen.dart';

void main() {
  runApp(MyApp());
  stderr.writeln('print me');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserManager(),
      lazy: false,
      child: MaterialApp(
        title: 'SafeSpace',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xffda5afd),
          scaffoldBackgroundColor: const Color(0xff76E2EC),
          appBarTheme: const AppBarTheme(elevation: 0),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        onGenerateRoute: (settings) {
          stderr.writeln('print me = settings');
          developer.log('log me', name: settings.name);
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => LoginScreen());
            case '/signup':
              return MaterialPageRoute(builder: (_) => SignUpScreen());
            case '/recovery':
              return MaterialPageRoute(builder: (_) => RecoverPass());
            case '/base':
              return MaterialPageRoute(builder: (_) => BaseScreen());
            default:
              return MaterialPageRoute(builder: (_) => LoginScreen());
          }
        },
      ),
    );
  }
}
