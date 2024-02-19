import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resell_app/Profile/AllProfileAds.dart';
import 'package:resell_app/Profile/EditProfile.dart';
import 'package:resell_app/globalVar.dart';

import '../SignupScreen/signUpScreen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    return Drawer(
      backgroundColor: Colors.blue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height *0.04
      ,
          ),
          ListTile(
            title: Text("Hey $getUserName",style: TextStyle(color: Colors.white),),

          ),



          ListTile(
            leading: const Icon(Icons.person, color: Colors.white,),
            title: const Text('Edit Profile',style: TextStyle(color: Colors.white),),
            onTap: () {
              // Handle Home button tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => EditProfile(sellerId:userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white,),
            title: const Text('My Ads', style: TextStyle(color: Colors.white),),
            onTap: () {
              // Handle Home button tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>  MyAds(sellerId:userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.login_outlined, color: Colors.white,),
            title: const Text('Logout', style: TextStyle(color: Colors.white),),
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
