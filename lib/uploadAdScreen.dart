import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class UploadAdScreen extends StatefulWidget {
  const UploadAdScreen({Key? key}) : super(key: key);

  @override
  State<UploadAdScreen> createState() => _UploadAdScreenState();
}

class _UploadAdScreenState extends State<UploadAdScreen> {
  bool uploading = false, next = false;
  double val = 0;
  late CollectionReference imgRef;
  late firebase_storage.Reference ref;
  String imgFile = "",
      imgFile1 = "",
      imgFile2 = "",
      imgFile3 = "",
      imgFile4 = "",
      imgFile5 = "";
  List<File> _image = [];
  List<File> _urlsList = [];
  final picker = ImagePicker();
  FirebaseAuth auth = FirebaseAuth.instance;
  String userName = "";
  String userNumber = "";
  String itemPrice = "";
  String itemModel = "";
  String itemColor = "";
  String description = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          next ? "Please write Item's Info" : "Choose Item Image",
          style: const TextStyle(
            fontSize: 18.0,
            fontFamily: "Lobster",
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          next
              ? Container()
              : ElevatedButton(
                  onPressed: () {
                    if (_image.length == 5) {
                      setState(() {
                        uploading = true;
                        next = true;
                      });
                    } else {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 2),
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: 'Please select 5 Images',
                              message:
                                  "5 images are required for high view rate!",
                              contentType: ContentType.failure,
                            ),
                          ),
                        );
                    }
                  },
                  child: Text(
                    "Next",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Enter Your Name'),
                onChanged: (value) {
                  this.userName = value;
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                decoration:
                    InputDecoration(hintText: 'Enter Your Phone Number'),
                onChanged: (value) {
                  this.userNumber = value;
                },
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                decoration:
                    const InputDecoration(hintText: 'Enter Item Name'),
                onChanged: (value) {
                  itemModel = value;
                },
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                decoration:
                    const InputDecoration(hintText: 'Enter Item Price'),
                onChanged: (value) {
                  itemPrice = value;
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                decoration: InputDecoration(hintText: 'Enter Item Color'),
                onChanged: (value) {
                  this.itemColor = value;
                },
              ),
              SizedBox(
                height: 5,
              ),
              TextField(
                decoration:
                    InputDecoration(hintText: "Write some Item's Description"),
                onChanged: (value) {
                  this.description = value;
                },
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
