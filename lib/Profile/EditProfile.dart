import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
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
  bool viewNumb = false;
  bool isEmailVerified = false;
  TextEditingController otpController = TextEditingController();

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
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const SignUpScreen()));
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

        isEmailVerified = results.data()?['isEmailVerified'];
        viewNumb = results.data()?['viewNumber'];
        userNumber = getUserNumber;
        userName = getUserName;
        userStatus = getUserStatus;
      });
    });
  }

  EmailOTP myauth = EmailOTP();

  @override
  Widget build(BuildContext context) {
    Widget myCard() {
      return Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: otpController,
                decoration: const InputDecoration(hintText: "Enter OTP"),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  if (await myauth.verifyOTP(otp: otpController.text) == true) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("OTP is verified"),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Invalid OTP"),
                    ));
                  }
                },
                child: const Text("Verify")),
          ],
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Update Profile"),
        centerTitle: true,
        elevation: 2,
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
                  const Text(
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
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            initialValue: getUserName,
                            style: const TextStyle(color: Colors.black),
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
                    style: const TextStyle(color: Colors.black),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text("Email"),
                                Text(getUserEmail)
                              ],
                            ),
                            isEmailVerified
                                ? const Icon(
                                    Icons.verified_rounded,
                                    color: Colors.blue,
                                  )
                                : TextButton(
                                    onPressed: () async {
                                      myauth.setConfig(
                                          appEmail: "gandhimanan1@gmail.com",
                                          appName: "Email OTP",
                                          userEmail:
                                              "fluttersolutionsdev@gmail.com",
                                          otpLength: 6,
                                          otpType: OTPType.digitsOnly);
                                      if (await myauth.sendOTP() == true) {
                                        _showOtpInputDialog();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content:
                                              Text("Oops, OTP send failed"),
                                        ));
                                      }
                                    },
                                    child: const Text("Verify")),
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Allow users to view your number?"),
                        Switch(
                          value: viewNumb,
                          onChanged: (value) {
                            setState(() {
                              viewNumb = value;
                            });
                            Map<String, dynamic> itemData = {
                              'viewNumber': viewNumb
                            };
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .update(itemData)
                                .then(
                                  (value) {},
                                );
                          },
                          inactiveThumbColor: Colors.red,
                          inactiveTrackColor: Colors.redAccent,
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.greenAccent,
                        )
                      ],
                    ),
                  )
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

  void _showOtpInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter OTP"),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: "Enter OTP",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await myauth.verifyOTP(otp: otpController.text) == true) {
                  Map<String, dynamic> itemData = {'isEmailVerified': true};
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update(itemData)
                      .then(
                        (value) {},
                      );

                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("OTP verified successfully"),
                    ),
                  );
                  setState(() {
                    isEmailVerified = true;
                    print(isEmailVerified);
                  });
                } else {
                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Invalid OTP"),
                  ));
                }
                // Add your OTP verification logic here
                // Check if the entered OTP is correct
                // If correct, set isEmailVerified to true
                // Otherwise, display an error message
                // You can use otpController.text to get the entered OTP
                // and compare it with the actual OTP sent
                // Remember to call Navigator.pop(context) to close the dialog
              },
              child: const Text("Verify"),
            ),
          ],
        );
      },
    );
  }
}
