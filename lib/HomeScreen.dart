import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:resell_app/SignupScreen/signUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resell_app/Widgets/drawer.dart';
import 'package:resell_app/globalVar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resell_app/uploadAdScreen.dart';
import 'package:timeago/timeago.dart' as tAgo;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  QuerySnapshot? items;
  getMyData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((results) {
      setState(() {
        getUserName = results.data()?['userName'];
      });
    });
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> requestLocationPermission() async {
    if (await Permission.location.isGranted) {
      // Permission already granted
      getUserAddress();
    } else {
      // Request permission

      final status = await Permission.location.request();
      if (status.isGranted) {
        // Permission granted
        getUserAddress();
      } else {
        // Permission denied
        // Handle the scenario when the user denies the permission request
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Location Permission Denied!',
                message:
                    "For best experience allow the app with location permission and Restart It!",
                contentType: ContentType.failure,
              ),
            ),
          );
      }
    }
  }

  getUserAddress() async {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    position = newPosition;
    List<Placemark> placemarks = await placemarkFromCoordinates(
      newPosition.latitude,
      newPosition.longitude,
    );

    Placemark placemark = placemarks.first;
    String newCompleteAddress =
        '${placemark.street} ${placemark.locality} ${placemark.postalCode} ${placemark.country}';
    completeAddress = newCompleteAddress.trim();

    return completeAddress;
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    userId = FirebaseAuth.instance.currentUser!.uid;
    userEmail = FirebaseAuth.instance.currentUser!.email!;
    FirebaseFirestore.instance
        .collection('items')
        .where("status", isEqualTo: "approved")
        .orderBy("time", descending: true)
        .get()
        .then((results) {
      setState(() {
        items = results;
        print("*" * 100);
        print(items?.docs.length);
        print("*" * 100);
      });
    });
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    Widget? showItemList() {
      if (items != null) {
        return ListView.builder(
            itemCount: items!.docs.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, i) {
              return Container(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        title: GestureDetector(
                          onTap: () {},
                          child: Text(
                            items?.docs[i].get('userName'),
                          ),
                        ),
                        trailing: items?.docs[i].get('uid') == userId
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Icon(
                                      Icons.edit_outlined,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    onDoubleTap: () {},
                                    child:
                                        const Icon(Icons.delete_forever_sharp),
                                  )
                                ],
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [],
                              ),
                      ),
                      GestureDetector(
                        onDoubleTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            height: 150,
                            child: Image.network(
                                items?.docs[i].get("urlImage1"),
                                fit: BoxFit.fill),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "\$${items?.docs[i].get("itemPrice")}",
                          style: const TextStyle(
                            letterSpacing: 2.0,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.image_sharp,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      items?.docs[i].get("itemModel"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.watch_later_outlined,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(tAgo.format(
                                        (items?.docs[i].get('time')).toDate())),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      } else {
        return (Text("Loading"));
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyDrawer(),
      body: SafeArea(
        child: Center(
          child: Container(
            width: _screenWidth,
            child: showItemList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Post',
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const UploadAdScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
