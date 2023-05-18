import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailInputDialog extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return AlertDialog(
      title: Text('Enter Email for Reset'),
      content: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Submit'),
          onPressed: () async{
            String email = emailController.text.trim();
            // Handle the email here, e.g., call a function to send reset password email
            try {
              await _auth.sendPasswordResetEmail(email: email);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  elevation: 0,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  content: AwesomeSnackbarContent(
                    title: 'Successful!',
                    message: 'Reset link sent successfully!',
                    contentType: ContentType.success,
                  ),
                ));
              Navigator.of(context).pop();
              // Password reset email sent successfully
            } on FirebaseAuthException catch (e) {
              // Handle any errors that occur during the password reset process
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  elevation: 0,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  content: AwesomeSnackbarContent(
                    title: 'On Snap!',
                    message: '${e.message}',
                    contentType: ContentType.failure,
                  ),
                ));
            }

          },
        ),
      ],
    );
  }
}

void showEmailInputDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return EmailInputDialog();
    },
  );
}
