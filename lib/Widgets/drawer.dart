import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resell_app/ProfileSection.dart';
import 'package:resell_app/SignupScreen/componets/body.dart';
import 'package:resell_app/globalVar.dart';

import '../SignupScreen/signUpScreen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Container(
              height: 400,
              child:        Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hey $getUserName"),
                ],
              ),

            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Ads'),
            onTap: () {
              // Handle Home button tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>  MyProfile(sellerId:userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.login_outlined),
            title: const Text('Logout'),
            onTap: () {
              // Handle Settings button tap
              auth.signOut().then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignUpScreen(),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
