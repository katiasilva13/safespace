import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespace/helpers/validators.dart';
import 'package:safespace/models/user/user.dart';
import 'package:safespace/models/user/user_manager.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    developer.log('log me', name: context.toString());
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage("imagens/imagem_fundo.jpg")),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("imagens/imagem_logo.png"),
            Center(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: formKey,
                  child: Consumer<UserManager>(
                    builder: (_, userManager, child) {
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        children: <Widget>[
                          TextFormField(
                            controller: emailController,
                            enabled: !userManager.loading,
                            decoration:
                                const InputDecoration(hintText: 'E-mail'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            validator: (email) {
                              if (!emailValid(email)) return 'E-mail inv??lido';
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: passController,
                            enabled: !userManager.loading,
                            decoration:
                                const InputDecoration(hintText: 'Senha'),
                            autocorrect: false,
                            obscureText: true,
                            validator: (pass) {
                              if (pass.isEmpty || pass.length < 6)
                                return 'Senha inv??lida';
                              return null;
                            },
                          ),
                          child,
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            height: 44,
                            child: RaisedButton(
                              onPressed: userManager.loading
                                  ? null
                                  : () {
                                      if (formKey.currentState.validate()) {
                                        userManager.signIn(
                                            user: User(
                                                email: emailController.text,
                                                password: passController.text),
                                            onFail: (e) {
                                              scaffoldKey.currentState
                                                  .showSnackBar(SnackBar(
                                                content:
                                                    Text('Falha ao entrar: $e'),
                                                backgroundColor: Colors.red,
                                              ));
                                            },
                                            onSuccess: () {
                                              Navigator.of(context)
                                                  .pushReplacementNamed(
                                                      '/base');
                                            });
                                      }
                                    },
                              color: Theme.of(context).primaryColor,
                              disabledColor:
                                  Theme.of(context).primaryColor.withAlpha(100),
                              textColor: Colors.white,
                              child: userManager.loading
                                  ? CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          )
                        ],
                      );
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed('/recovery');
                        },
                        padding: EdgeInsets.zero,
                        child: const Text('Esqueci minha senha'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                child: Text(
                  "N??o tem conta? Cadastre-se",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/signup');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
