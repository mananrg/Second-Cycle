import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resell_app/DialogBox/errorDialog.dart';
import 'package:resell_app/Widgets/rounded_button.dart';
import 'package:resell_app/Widgets/rounded_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../HomeScreen.dart';
import '../../Widgets/ResetPassword.dart';
import '../../globalVar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebaseStorage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class SignupBody extends StatefulWidget {
  const SignupBody({Key? key}) : super(key: key);
  static String verify = "";

  @override
  _SignupBodyState createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  String userPhotoUrl = "";

  File? _image;
  final picker = ImagePicker();
  var buttonState = true;
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _lemailController = TextEditingController();
  final TextEditingController _lphoneController = TextEditingController();
  final TextEditingController _lconfirmpasswordController =
      TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String countrycode = '+1';

  var visibilityState = false;

  void _register() async {
    User? currentUser; // Change the type to User? (nullable)
    if (_lnameController.text.isNotEmpty &&
        _lphoneController.text.length == 10 &&
        _lconfirmpasswordController.text.isNotEmpty &&
        isStrongPassword(_lconfirmpasswordController.text) &&
        isValidEmail(_lemailController.text)) {
      try {
        final authResult = await _auth.createUserWithEmailAndPassword(
          email: _lemailController.text.trim(),
          password: _lconfirmpasswordController.text.trim(),
        );

        currentUser = authResult.user!;
        userId = currentUser.uid!;
        userEmail = currentUser.email!;
        phoneNumber = _lphoneController.text.trim();
        getUserName = _lnameController.text.trim();

        saveUserData();
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: countrycode + phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {},
          codeSent: (String verificationId, int? resendToken) {
            SignupBody.verify = verificationId;
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
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

  void _login() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'On Snap!',
              message: '${e.message}',
              contentType: ContentType.failure,
            ),
          ),
        );
    }
  }

  void saveUserData() {
    Map<String, dynamic> userData = {
      'userName': _lnameController.text.trim(),
      'uid': userId,
      'userNumber': _lphoneController.text.trim(),
      'email': _lemailController.text.trim(),
      'time': DateTime.now(),
      'status': "approved",
     // 'imgPro': _image ?? Image.asset("assets/images/person.jpg")
    };
print("&"*20);
print(_image);
print("&"*20);

    FirebaseFirestore.instance.collection("users").doc(userId).set(userData);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width,
        screenHeight = MediaQuery.of(context).size.height;
    Color blue = const Color(0xFF266AFE);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 10, top: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 buttonState? Container():Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final imagePicker = ImagePicker();
                          final pickedImage = await imagePicker.getImage(
                              source: ImageSource.camera);

                          if (pickedImage != null) {
                            setState(() {
                              _image = File(pickedImage.path);
                              print("*"*20);
                              print(_image);
                              print("*"*20);

                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: screenWidth * 0.08,
                          backgroundColor: Colors.blueAccent,
                          backgroundImage: _image == null
                              ? Image.asset('assets/images/person.jpg').image
                              : FileImage(_image!),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _image == null
                            ? Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: screenWidth * 0.05,
                                  color: Colors.white,
                                ),
                              )
                            : Container(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            buttonState = true;
                            if (kDebugMode) {
                              print(buttonState);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 1),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: buttonState
                                    ? const Color(0xFF266AFE)
                                    : Colors.black45,
                              ),
                            ),
                          ),
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                              color: buttonState
                                  ? const Color(0xFF266AFE)
                                  : Colors.black45,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            buttonState = false;
                          });
                          if (kDebugMode) {
                            print(buttonState);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 1),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: buttonState
                                    ? Colors.black45
                                    : const Color(0xFF266AFE),
                              ),
                            ),
                          ),
                          child: Text(
                            "SIGN UP",
                            style: TextStyle(
                              color: buttonState
                                  ? Colors.black45
                                  : const Color(0xFF266AFE),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: buttonState
                    ? RichText(
                        text: const TextSpan(
                          text: 'Welcome!\n',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.grey),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Live a ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Colors.grey)),
                            TextSpan(
                              text: 'Thrifty Lifestyle!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Color(0xFF181823),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Text(
                        "Connect to people\nSell and Score Amazing Deals!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      )),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            buttonState == true
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        SizedBox(height: screenHeight * 0.02),
                        RoundedInputField(
                          hintText: "Email",
                          icon: Icons.person,
                          onChanged: (value) {
                            _emailController.text = value;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            onChanged: (value) {
                              _passwordController.text = value;
                            },
                            cursorColor: blue,
                            obscureText: visibilityState,
                            decoration: InputDecoration(
                              hintText: "Password",
                              suffixIcon: IconButton(
                                color: blue,
                                onPressed: () {
                                  setState(() {
                                    visibilityState = !visibilityState;
                                  });
                                  if (kDebugMode) {
                                    print(visibilityState);
                                  }
                                },
                                icon: visibilityState == true
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2, //<-- SEE HERE
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                showEmailInputDialog(context);
                              },
                              child: const Text(
                                "Reset Password?",
                                style: TextStyle(
                                  color: Color(0xFF266AFE),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        RoundedInputField(
                          hintText: "Name",
                          icon: Icons.person,
                          onChanged: (value) {
                            _lnameController.text = value;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        RoundedInputField(
                          hintText: "Email",
                          icon: Icons.person,
                          onChanged: (value) {
                            _lemailController.text = value;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            onChanged: (value) {
                              _lphoneController.text = value;
                            },
                            cursorColor: blue,
                            decoration: const InputDecoration(
                              hintText: "Phone",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2, //<-- SEE HERE
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            onChanged: (value) {
                              _lconfirmpasswordController.text = value;
                            },
                            cursorColor: blue,
                            obscureText: visibilityState,
                            decoration: InputDecoration(
                              hintText: "Confirm Password",
                              suffixIcon: IconButton(
                                color: blue,
                                onPressed: () {
                                  setState(() {
                                    visibilityState = !visibilityState;
                                  });
                                  if (kDebugMode) {
                                    print(visibilityState);
                                  }
                                },
                                icon: visibilityState == true
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2, //<-- SEE HERE
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        SizedBox(
                          height: screenHeight * 0.03,
                        ),
                      ],
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedButton(
                    text: buttonState ? "LOGIN" : "SIGNUP",
                    press: () {
                      buttonState ? _login() : _register();
                    }),
              ],
            ),
            const Expanded(
              flex: 2,
              child: SizedBox(),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    buttonState
                        ? "Don’t have an Account ? "
                        : "Already have an Account ? ",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        buttonState = !buttonState;
                        print(buttonState);
                      });
                    },
                    child: Text(
                      buttonState ? "Sign Up" : "Login",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
