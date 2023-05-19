import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resell_app/SignupScreen/componets/body.dart';

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
            child:   Container(
              child: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                backgroundImage: Image.asset('assets/images/person.jpg',scale: 5,).image

              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh'),
            onTap: () {
              // Handle Home button tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Home'),
            onTap: () {
              // Handle Home button tap
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
