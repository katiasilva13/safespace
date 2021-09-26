import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespace/common/custom_drawer/custom_drawer_header.dart';
import 'package:safespace/common/custom_drawer/drawer_tile.dart';
import 'package:safespace/models/user_manager.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 203, 236, 241),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
          ),
          ListView(
            children: <Widget>[
              CustomDrawerHeader(),
              const Divider(),
              DrawerTile(
                iconData: Icons.home,
                title: 'Início',
                page: 0,
              ),
              DrawerTile(
                iconData: Icons.admin_panel_settings,
                title: 'Perfil',
                page: 1,
              ),
              DrawerTile(
                iconData: Icons.feed,
                title: 'Minhas Postagens',
                page: 2,
              ),
              // DrawerTile(
              //   iconData: Icons.add_moderator,
              //   title: 'Moderação',
              //   page: 3,
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
