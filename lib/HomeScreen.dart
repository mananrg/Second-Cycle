import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseAuth auth = FirebaseAuth.instance;
  String completeAddress = "";

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
    List<Placemark> placemarks = await placemarkFromCoordinates(
      newPosition.latitude,
      newPosition.longitude,
    );

    Placemark placemark = placemarks.first;
    String newCompleteAddress =
        '${placemark.street} ${placemark.locality} ${placemark.postalCode} ${placemark.country}';

    setState(() {
      completeAddress = newCompleteAddress.trim();
    });

    return completeAddress;
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    Widget? showItemList() {}

    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            /*Padding(
              padding: const EdgeInsets.only(top: 5, left: 9, right: 9),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF266AFE),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: GestureDetector(
                      onTap: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: const Icon(
                          Icons.menu,
                          weight: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),*/
            Expanded(child: SizedBox(),),
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: completeAddress == null
                    ? const Text("")
                    : Text(
                        completeAddress,
                        style: const TextStyle(color: Colors.black),
                      ),
              ),
            ),
            Center(
              child: SizedBox(
                width: _screenWidth,
                child: showItemList(),
              ),
            ),
          ],
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
