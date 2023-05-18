import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            },
          ),

        ],
      ),
    );
  }
}
