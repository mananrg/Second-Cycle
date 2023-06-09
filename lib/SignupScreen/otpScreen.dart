import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:resell_app/SignupScreen/componets/body.dart';
import 'package:resell_app/SignupScreen/signUpScreen.dart';

import '../DialogBox/errorDialog.dart';
import '../HomeScreen.dart';
import '../globalVar.dart';

class OtpScreen extends StatefulWidget {
  var phoneNumber;

  var email;

  var name;
var password;
   OtpScreen({Key? key,this.phoneNumber, this.email,this.name,this.password}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _focusNode = FocusNode();
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.unfocus();
    super.dispose();
  }

  void _register() async {
    print("*"*100);
    print("name: ${widget.name}");
    print("phoneNumber: ${widget.phoneNumber}");
    print("Email: ${widget.email}");
    print("Password: ${widget.password}");

    User? currentUser; // Change the type to User? (nullable)
    final FirebaseAuth _auth = FirebaseAuth.instance;

    if (widget.name.isNotEmpty &&
        widget.phoneNumber.text.length == 10 &&
      widget.password.isNotEmpty &&
        isStrongPassword(widget.password) &&
        isValidEmail(widget.email)) {
      try {
        final authResult = await _auth.createUserWithEmailAndPassword(
          email: widget.email,
          password: widget.password,
        );

        currentUser = authResult.user!;
        userId = currentUser.uid!;
        userEmail = currentUser.email!;
        phoneNumber = widget.phoneNumber;
        getUserName = widget.name;

        saveUserData();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } catch (error) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (con) {
            return ErrorAlertDialog(
              message: error.toString(),
            );
          },
        );
      }
    } else {
      // Show a pop-up indicating the issues with the input
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Input Error'),
            content:
            const Text('Please check your input fields and try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
  void saveUserData() {
    Map<String, dynamic> userData = {
      'userName': widget.name,
      'uid': userId,
      'userNumber':widget.phoneNumber,
      'email': widget.email,
      'time': DateTime.now(),
      'status': "approved",
      //'imgPro': _image ?? Image.asset("assets/images/person.jpg")
    };

    FirebaseFirestore.instance.collection("users").doc(userId).set(userData);
  }
  bool isStrongPassword(String password) {
    // Perform your strong password validation logic here
    // Return true if the password is strong, false otherwise
    // You can define your own criteria for a strong password
    return password.length >= 8;
  }

  bool isValidEmail(String email) {
    // Return true if the email is valid, false otherwise
    final emailRegex =
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$';
    return RegExp(emailRegex).hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );


    var code = "";
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 30, left: 15, right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back_ios),
                      ),
                      const Text(
                        "Back",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
                const Text(
                  "Enter the 6-digit code sent to your phone",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF39D4AA),
                  ),
                ),
                const SizedBox(
                  height: 55,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Pinput(
                    focusNode: _focusNode,
                    length: 6,
                    // defaultPinTheme: defaultPinTheme,
                    // focusedPinTheme: focusedPinTheme,
                    // submittedPinTheme: submittedPinTheme,

                    showCursor: true,
                    onCompleted: (pin) {
                      code = pin;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      try {

                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: SignupBody.verify,
                                smsCode: code);
                        // Sign the user in (or link) with the credential
                        UserCredential authResult =
                            await auth.signInWithCredential(credential);
                        User? user = authResult.user;
print("&"*1000);
print(user);
print("&"*1000);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.white,
                              content: AwesomeSnackbarContent(
                                title: 'Verified',
                                message:'You are successfully verified',
                                contentType: ContentType.success,
                              ),
                            ),
                          );
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        } else {
                          _register();
                        }
                      } catch (e) {
print(e);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.white,
                              content: AwesomeSnackbarContent(
                                title: 'Error',
                                message:  '${e}',
                                contentType: ContentType.failure,
                              ),
                            ),
                          );
                      }
                    },
                    child: const Text("Next"),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          'phone',
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Edit Phone Number ?",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
