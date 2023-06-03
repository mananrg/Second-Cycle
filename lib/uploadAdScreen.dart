import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resell_app/DialogBox/loadingDialog.dart';
import 'package:resell_app/globalVar.dart';
import 'package:path/path.dart' as Path;

import 'BannerAd.dart';
import 'DialogBox/loadingDialog.dart';
import 'HomeScreen.dart';
import 'globalVar.dart';

class UploadAdScreen extends StatefulWidget {
  const UploadAdScreen({Key? key}) : super(key: key);

  @override
  State<UploadAdScreen> createState() => _UploadAdScreenState();
}

class _UploadAdScreenState extends State<UploadAdScreen> {
  bool uploading = false, next = false;
  double val = 0;
  late CollectionReference imageRef;
  late firebase_storage.Reference ref;
  StreamController<int> _deleteImageController =
      StreamController<int>.broadcast();

  String imgFile = "",
      imgFile1 = "",
      imgFile2 = "",
      imgFile3 = "",
      imgFile4 = "",
      imgFile5 = "";
  final List<File> _image = [];
  List<String> urlsList = [];
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
        title: next
            ? const Text("Enter Appropriate Info")
            : const Row(
                children: [
                  Text(
                    "Choose the Image",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
        actions: [
          next
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF266AFE),
                      ),
                    ),
                    onPressed: () {
                      if (_image.length == 5) {
                        setState(() {
                          uploading = true;
                          next = true;
                        });
                      } else if(_image.length>5){
                        showToast(
                          "Please select 5 images only....",
                          seconds: 2,
                        );
                      }else if(_image.length<5){
                        showToast(
                          "Please select 5 images to proceed...",
                          seconds: 2,
                        );
                      }
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
      body: next ? userInfo(context) : imageContainer(context),
    );
  }

  SingleChildScrollView userInfo(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                label: Text("Name"),
              ),
              onChanged: (val) {
                userName = val;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                label: Text("Phone Number"),
              ),
              onChanged: (val) {
                userNumber = val;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                label: Text("Enter Item Price"),
              ),
              onChanged: (val) {
                itemPrice = val;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                label: Text("Enter Item Name"),
              ),
              onChanged: (val) {
                itemModel = val;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                label: Text("Item Color"),
              ),
              onChanged: (val) {
                itemColor = val;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                label: Text("Item's Description"),
              ),
              onChanged: (val) {
                description = val;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                label: Text("Address"),
              ),
              controller: TextEditingController(
                text: completeAddress,
              ),
              onChanged: (val) {
                completeAddress = val;
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (con) {
                        return const LoadingAlertDialog(message: "Loading....");
                      });
                  uploadFile().whenComplete(() {
                    Map<String, dynamic> adData = {
                      'userName': this.userName,
                      'uid': auth.currentUser?.uid,
                      'userNumber': this.userNumber,
                      'itemPrice': this.itemPrice,
                      'itemModel': this.itemModel,
                      'itemColor': this.itemColor,
                      'description': this.description,
                      'urlImage1': urlsList[0].toString(),
                      'urlImage2': urlsList[1].toString(),
                      'urlImage3': urlsList[2].toString(),
                      'urlImage4': urlsList[3].toString(),
                      'urlImage5': urlsList[4].toString(),
                      'imgPro': userImageUrl,
                      'lat': position?.latitude,
                      'lng': position?.longitude,
                      'address': completeAddress,
                      'time': DateTime.now(),
                      'status': "not approved",
                    };
                    FirebaseFirestore.instance
                        .collection('items')
                        .add(adData)
                        .then((value) {
                      print("Data Added Successfuly");
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: 'Successful!',
                              message: "Ad Uploaded Successfully!\nPlease wait upto 24hrs for your ad to get verified!",
                              contentType: ContentType.success,
                            ),
                          ),
                        );
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    }).catchError((onError) {
                      print(onError);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: 'Error',
                              message: onError +
                                  "\nPlease Contact the administrator",
                              contentType: ContentType.failure,
                            ),
                          ),
                        );
                    });
                  });
                },
                child: const Text(
                  'Upload',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Column imageContainer(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text("Upload 5 Images in different angles"),
        ),
        Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(4),
              child: GridView.builder(
                itemCount: _image.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return index == 0
                      ? Center(
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => !uploading ? chooseImage() : null,
                          ),
                        )
                      : Stack(children: [
                          Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(
                                  _image[index - 1],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                                icon: const Icon(
                                  Icons.close_sharp,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteImage(index - 1)),
                          ),
                        ]);
                },
              ),
            ),
            uploading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: const Text(
                            "Uploading....",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CircularProgressIndicator(
                          value: val,
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.green),
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ),
        Expanded(child: SizedBox(),),
        BannerAdWidget(), // Top banner ad

      ],
    );
  }

  Future uploadFile() async {
    int i = 1;
    int deletedIndex = -1;
    _deleteImageController.stream.listen((index) {
      deletedIndex = index;
    });

    for (var img in _image) {
      if (deletedIndex != -1 && deletedIndex < i) {
        urlsList.removeAt(deletedIndex);
        deletedIndex = -1;
      }
      setState(() {
        val = i / _image.length;
      });
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('image/${Path.basename(img.path)}');
      await ref.putFile(img).whenComplete(() async {
        await ref.getDownloadURL().then((value) {
          urlsList.add(value);
          i++;
        });
      });
    }

    if (deletedIndex != -1 && deletedIndex == i) {
      urlsList.removeAt(deletedIndex);
    }
  }

  void showToast(String msg, {required int seconds}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: Duration(seconds: seconds),
    ));
  }

  chooseImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
    });
    if (pickedFile?.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image.add(
          File(response.file!.path),
        );
      });
    }
  }

  void deleteImage(int index) {
    setState(() {
      _image.removeAt(index);
    });
    _deleteImageController.add(index);
  }

  @override
  void initState() {
    super.initState();
    imageRef = FirebaseFirestore.instance.collection('imageUrls');
  }
}
