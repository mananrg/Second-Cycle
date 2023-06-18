import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:resell_app/SignupScreen/signUpScreen.dart';
import 'package:resell_app/Widgets/ResetPassword.dart';

import '../globalVar.dart';

class EditProfile extends StatefulWidget {
  EditProfile({Key? key, required this.sellerId}) : super(key: key);
  String sellerId;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String userName = "";
  String userNumber = "";
  String userStatus = "";
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> deleteUserAndItems() async {
    if (currentUser != null) {
      final String userId = currentUser!.uid;

      // Delete items related to the user
      final QuerySnapshot itemsSnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('uid', isEqualTo: userId)
          .get();
      final List<QueryDocumentSnapshot> itemDocuments = itemsSnapshot.docs;
      for (final itemDocument in itemDocuments) {
        await itemDocument.reference.delete();
      }

      // Delete the user
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      await currentUser!.delete();

      // Log out the user
      await FirebaseAuth.instance.signOut();
      setState(() {});
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => SignUpScreen()));
      // Navigate to the login screen or any other desired screen
      // You can use Navigator.pushReplacement() to replace the current route
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyData();
  }

  QuerySnapshot? items;
  getMyData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((results) {
      setState(() {
        getUserName = results.data()?['userName'];
        getUserNumber = results.data()?['userNumber'];
        getUserStatus = results.data()?['status'];
        getUserEmail = results.data()?['email'];
        userNumber = getUserNumber;
        userName = getUserName;
        userStatus = getUserStatus;
        if (kDebugMode) {
          print("&" * 100);
          print(userName);
          print(userNumber);
          print("&" * 100);
        }
        if (kDebugMode) {
          print("Hello");
          print("*" * 10);
          print(getUserNumber);
          print(getUserName);
          print("*" * 10);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: Text("Update Profile"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Map<String, dynamic> itemData = {
                'userName': userName,
                'userNumber': userNumber,
              };
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update(itemData)
                  .then((value) {
                print("^" * 100);
                print("Updated");
                print("^" * 100);
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Profile Updated Successfully',
                        message: "Updated Info will be seen from next AD.",
                        contentType: ContentType.success,
                      ),
                    ),
                  );
              }).catchError((onError) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: "Issue Updating Data",
                        message: "Please try again later!",
                        contentType: ContentType.success,
                      ),
                    ),
                  );
              });
            },
            child: const Text("Update"),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                EditProfile(sellerId: widget.sellerId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 10),
                        child: Image.asset(
                          'assets/images/person.jpg',
                          height: 84,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            initialValue: getUserName,
                            style: TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              label: Text(
                                "Enter your Name",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                userName = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    initialValue: getUserNumber,
                    style: TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      label: Text(
                        'Mobile Number',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        userNumber = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black12),
                      width: MediaQuery.of(context).size.width,
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [const Text("Email"), Text(getUserEmail)],
                        ),
                      )),
                  const SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        showEmailInputDialog(context);
                      },
                      child: Container(
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Reset Password",
                              style: TextStyle(fontSize: 16),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                            "You are about to permanently delete your account. Are you sure about this?"),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteUserAndItems();
                                              },
                                              child: const Text("Delete"),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: const Text(
                            "Delete Account",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
