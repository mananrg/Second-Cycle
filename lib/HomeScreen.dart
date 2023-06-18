import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resell_app/SearchScreen.dart';
import 'package:resell_app/Widgets/drawer.dart';
import 'package:resell_app/globalVar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resell_app/AdDescription.dart';
import 'package:resell_app/uploadAdScreen.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'GoogleAds/BannerAd.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  QuerySnapshot? items;
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  late var adUnitId;
  String docId='';
  Position? viewerPosition;
  initBannerAd() {
    if (Platform.isAndroid) {
      adUnitId = "ca-app-pub-3940256099942544/6300978111";
      if (kDebugMode) {
        print("*" * 100);
        print("its android");
        print("*" * 100);
      }

    } else if (Platform.isIOS) {
      adUnitId = "ca-app-pub-3940256099942544/2934735716";
      if (kDebugMode) {
        print("*" * 100);
        print("its apple");
        print("*" * 100);
      }

    }
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      listener: BannerAdListener(onAdLoaded: (ad) {
        setState(() {
          isAdLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        ad.dispose();
        if (kDebugMode) {
          print(error);
        }
      }),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

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
              backgroundColor: Colors.white,
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
    if (!mounted) return;

    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    position = newPosition;
   // viewerPosition= newPosition;
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
      });
    });
    getMyData();
    initBannerAd();
    requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text("Second Handz"),
        centerTitle: true,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()));
                },
              ))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen(),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BannerAdWidget(), // Top banner ad

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: () {},
                      child: Opacity(
                        opacity: 0.6,
                        child: Card(
                          color: Colors.orange,
                          child: SizedBox(
                            width: screenWidth * 0.45,
                            height: 100,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Events",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Coming Soon',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                  GestureDetector(
                    onTap: () {},
                    child: Opacity(
                      opacity: 0.6,
                      child: Card(
                        color: Colors.blue,
                        child: SizedBox(
                          width: screenWidth * 0.45,
                          height: 100,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Accommodation",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Coming Soon',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              /*  isAdLoaded
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: bannerAd.size.height.toDouble(),
                          width: bannerAd.size.width.toDouble(),
                          child: AdWidget(
                            ad: bannerAd,
                          ),
                        ),
                    ],
                  )
                  : const SizedBox(),*/
              BannerAdWidget(), // Top banner ad
              Expanded(
                child: items != null
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns in the grid
                          crossAxisSpacing: 8.0, // Spacing between columns
                          mainAxisSpacing: 8.0, // Spacing between rows
                          childAspectRatio:
                              0.82, // Width to height ratio of each grid item
                        ),
                        itemCount: items!.docs.length,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (context, i) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.grey, //color of border
                                width: 0.5, //width of border
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ImageSliderScreen(
                                            title:
                                                items?.docs[i].get('itemModel'),
                                            itemColor:
                                                items?.docs[i].get('itemColor'),
                                            userNumber: items?.docs[i]
                                                .get('userNumber'),
                                            itemPrice:
                                                items?.docs[i].get('itemPrice'),
                                            userName:
                                                items?.docs[i].get('userName'),
                                            description: items?.docs[i]
                                                .get('description'),
                                            sellerLat: items?.docs[i].get('lat'),
                                            sellerLng: items?.docs[i].get('lng'),
                                            address:
                                                items?.docs[i].get('address'),
                                            urlImage1:
                                                items?.docs[i].get('urlImage1'),
                                            urlImage2:
                                                items?.docs[i].get('urlImage2'),
                                            urlImage3:
                                                items?.docs[i].get('urlImage3'),
                                            urlImage4:
                                                items?.docs[i].get('urlImage4'),
                                            urlImage5:
                                                items?.docs[i].get('urlImage5'), time: items?.docs[i].get('time'),
                                            priceNegotiable:items?.docs[i].get('priceNegotiable'),
                                            returnEligible:items?.docs[i].get('returnEligible'),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.zero,
                                      height: 130,
                                      width: MediaQuery.of(context).size.width,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              items?.docs[i].get("urlImage1"),
                                          placeholder: (context, url) =>
                                              const Center(
                                            child: SizedBox(
                                              height: 50,
                                              width: 50,
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ), // Optional placeholder widget while loading
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons
                                                  .error), // Optional error widget if image fails to load
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: SizedBox(),
                                  ),
                                  Text(
                                    "\$${items?.docs[i].get("itemPrice")}",
                                    style: const TextStyle(
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: Text(
                                      "${items?.docs[i].get("itemModel")}"
                                          .toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: Text(tAgo.format(
                                      (items?.docs[i].get('time')).toDate(),
                                    )),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                    : const Center(
                        child: Text("Loading..."),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Post',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>  const UploadAdScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String getCurrentDocId(int index) {
    return items?.docs[index].id ?? '';
  }
}
