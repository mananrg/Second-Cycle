import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
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
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'GoogleAds/BannerAd.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  QuerySnapshot? items;
  final ZoomDrawerController zoomController = ZoomDrawerController();

//  late BannerAd bannerAd;
  bool isAdLoaded = false;
  late var adUnitId;
  String docId = '';
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
    /*
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
    bannerAd.load();*/
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

      body: ZoomDrawer(
        menuBackgroundColor: Colors.blue,
        controller: zoomController,
        mainScreen: AllHomeAds(screenWidth: screenWidth, items: items, zoomController: zoomController,),
        menuScreen: const MyDrawer(),
        borderRadius: 24.0,
mainScreenScale: 0.1,

        slideWidth: MediaQuery.of(context).size.width * 0.6,
        openCurve: Curves.fastOutSlowIn,
        closeCurve: Curves.bounceOut,
        showShadow: true,
        angle: 0,
        drawerShadowsBackgroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Post',
        onPressed: () {
          Navigator.push(
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

  String getCurrentDocId(int index) {
    return items?.docs[index].id ?? '';
  }
}

class AllHomeAds extends StatefulWidget {
  const AllHomeAds({
    super.key,
    required this.screenWidth,
    required this.items,
    required this.zoomController
  });

  final double screenWidth;
  final QuerySnapshot<Object?>? items;
  final ZoomDrawerController zoomController;

  @override
  State<AllHomeAds> createState() => _AllHomeAdsState();
}

class _AllHomeAdsState extends State<AllHomeAds> {
 bool drawerState = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const HomeScreen(),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              if (drawerState) {
                widget.zoomController.close!();
                print("DrawerState Closed");
              } else {
                widget.zoomController.open!();
                print("DrawerState Open");
              }
              setState(() {
                drawerState = !drawerState;
              });
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
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BannerAdWidget(), // Top banner ad
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
                            width: widget.screenWidth * 0.45,
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
                          width: widget.screenWidth * 0.45,
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
              //BannerAdWidget(), // Top banner ad
              Expanded(
                child: widget.items != null
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns in the grid
                          crossAxisSpacing: 8.0, // Spacing between columns
                          mainAxisSpacing: 8.0, // Spacing between rows
                          childAspectRatio:
                              0.82, // Width to height ratio of each grid item
                        ),
                        itemCount: widget.items!.docs.length,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ImageSliderScreen(
                                    title: widget.items?.docs[i].get('itemModel'),
                                    itemColor: widget.items?.docs[i].get('itemColor'),
                                    userNumber: widget.items?.docs[i].get('userNumber'),
                                    itemPrice: widget.items?.docs[i].get('itemPrice'),
                                    userName: widget.items?.docs[i].get('userName'),
                                    userEmail: widget.items?.docs[i].get('userEmail'),
                                    description:
                                        widget.items?.docs[i].get('description'),
                                    sellerLat: widget.items?.docs[i].get('lat'),
                                    sellerLng: widget.items?.docs[i].get('lng'),
                                    address: widget.items?.docs[i].get('address'),
                                    urlImage1: widget.items?.docs[i].get('urlImage1'),
                                    urlImage2: widget.items?.docs[i].get('urlImage2'),
                                    urlImage3: widget.items?.docs[i].get('urlImage3'),
                                    urlImage4: widget.items?.docs[i].get('urlImage4'),
                                    urlImage5: widget.items?.docs[i].get('urlImage5'),
                                    time: widget.items?.docs[i].get('time'),
                                    priceNegotiable:
                                        widget.items?.docs[i].get('priceNegotiable'),
                                    returnEligible:
                                        widget.items?.docs[i].get('returnEligible'),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 180,
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
                                    Container(
                                      padding: EdgeInsets.zero,
                                      height: 130,
                                      width: MediaQuery.of(context).size.width,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageUrl: widget.items?.docs[i].get("urlImage1"),
                                          imageBuilder: (context, imageProvider) => Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) {
                                            print("Fetching image from network...");
                                            return const Center(
                                              child: SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: CircularProgressIndicator(),
                                              ),
                                            );
                                          },
                                          errorWidget: (context, url, error) {
                                            print("Error loading image: $error");
                                            return Icon(Icons.error);
                                          },
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "\$${widget.items?.docs[i].get("itemPrice")}",
                                          style: const TextStyle(
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                        Text(tAgo.format(
                                          (widget.items?.docs[i].get('time')).toDate(),
                                        )),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: Text(
                                        "${widget.items?.docs[i].get("itemModel")}"
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }
}
