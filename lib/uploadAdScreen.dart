import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resell_app/DialogBox/loadingDialog.dart';
import 'package:resell_app/globalVar.dart';
import 'package:path/path.dart' as Path;
import 'GoogleAds/BannerAd.dart';
import 'HomeScreen.dart';

class UploadAdScreen extends StatefulWidget {
  const UploadAdScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<UploadAdScreen> createState() => _UploadAdScreenState();
}

class _UploadAdScreenState extends State<UploadAdScreen> {
  bool uploading = false, next = false;
  double val = 0;
  bool returnEligible = false;
  bool priceNeg = false;

  late CollectionReference imageRef;
  late firebase_storage.Reference ref;
  final StreamController<int> _deleteImageController =
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
  String userEmail="";
  String itemPrice = "";
  String itemModel = "";
  String itemColor = "";
  String description = "";
  String? youtubeLink = "";
  getMyData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((results) {
      setState(() {
        getUserName = results.data()?['userName'];
        getUserNumber = results.data()?['userNumber'];
        getUserEmail = results.data()?['email'];

        userNumber = getUserNumber;
        userName = getUserName;
userEmail = getUserEmail;
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: next
            ? const Text("Advertisement")
            : const Row(
                children: [
                  Text(
                    "Select Image",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
        centerTitle: true,
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
                      } else if (_image.length > 5) {
                        showToast(
                          "Please select 5 images only....",
                          seconds: 2,
                        );
                      } else if (_image.length < 5) {
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
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*     TextField(
              decoration: const InputDecoration(
                label: Text("Enter User Name"),
              ),
              onChanged: (val) {
                userName = val;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                label: Text("Enter User Number"),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                userNumber = val;
              },
            ),*/
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
                label: Text("Enter Item Price"),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                itemPrice = val;
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("Price Negotiable"),
                    Checkbox(
                      value: priceNeg,
                      onChanged: (bool? value) {
                        setState(() {
                          priceNeg = value ?? false;
                          print(priceNeg);
                        });
                      },
                      checkColor: Colors.blue,
                      activeColor: Colors.white ,
                    ),



                  ],
                ),
                Row(
                  children: [
                    const Text("Return Eligible"),
                    Checkbox(
                      value: returnEligible,
                      onChanged: (bool? value) {
                        setState(() {
                          returnEligible = value ?? false;
                          print(returnEligible);
                        });
                      },
                      checkColor: Colors.blue,
                      activeColor: Colors.white ,
                    ),

                  ],
                ),
              ],
            ),
            Opacity(
              opacity: 0.6,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.yellow),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 8),
                  child: Text(
                      "If return eligible buyers get an option to return item within 24 hrs."),
                ),
              ),
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
            /*  TextField(
              decoration: const InputDecoration(
                label: Text("Youtube Link [Optional]"),
              ),
              onChanged: (val) {
                youtubeLink = val;
                bool isLinkValid = isYouTubeLink(youtubeLink);

              },
            ),*/
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

            SizedBox(height: 20,),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue)),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (con) {
                        return const LoadingAlertDialog(message: "Loading....");
                      });
                  uploadFile().whenComplete(() {
                    Map<String, dynamic> adData = {
                      'userName': userName,
                      'address': completeAddress,
                      'uid': auth.currentUser?.uid,
                      'userNumber': userNumber,
                      'userEmail': userEmail,
                      'time': DateTime.now(),
                      'status': "not approved",
                      'itemPrice': itemPrice,
                      'itemModel': itemModel,
                      'itemColor': itemColor,
                      'description': description,
                      'returnEligible':returnEligible,
                      'priceNegotiable':priceNeg,
                      // 'link':youtubeLink,
                      'urlImage1': urlsList[0].toString(),
                      'urlImage2': urlsList[1].toString(),
                      'urlImage3': urlsList[2].toString(),
                      'urlImage4': urlsList[3].toString(),
                      'urlImage5': urlsList[4].toString(),
                      // 'imgPro': userImageUrl,
                      'lat': position?.latitude,
                      'lng': position?.longitude,
                    };
                    FirebaseFirestore.instance
                        .collection('items')
                        .add(adData)
                        .then((value) {
                      if (kDebugMode) {
                        print("Data Added Successfully");
                      }
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: AwesomeSnackbarContent(
                              title: 'Successful!',
                              message:
                                  "Ad Uploaded Successfully!\nPlease wait upto 24hrs for your ad to get verified!",
                              contentType: ContentType.success,
                            ),
                          ),
                        );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }).catchError((onError) {
                      if (kDebugMode) {
                        print(onError);
                      }
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
                        const Text(
                          "Uploading....",
                          style: TextStyle(fontSize: 20),
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
        const Expanded(
          child: SizedBox(),
        ),
        //BannerAdWidget(), // Top banner ad
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

  Future<void> chooseImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.camera),
                      ),
                      Text('Camera'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    captureImage();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.image),
                      ),
                      Text('Gallery'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.length <= 5) {
      setState(() {
        _image.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
      });
    } else if (pickedFiles.length > 5) {
      const AlertDialog(
        title: Text('Please select 5 images only'),
      );
    }
  }

  Future<void> captureImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _image.add(File(pickedFile.path));
      });
    }
  }
/*
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
*/
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
    getMyData();
  }

  bool isYouTubeLink(String? youtubeLink) {
    RegExp youtubePattern = RegExp(
        r"^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})");
    return youtubePattern.hasMatch(youtubeLink!);
  }
}
