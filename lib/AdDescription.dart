import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:resell_app/Profile/AllProfileAds.dart';
import 'package:resell_app/Widgets/loadingWidget.dart';
import 'package:resell_app/globalVar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:video_player/video_player.dart';
import 'package:geocoding/geocoding.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'Widgets/GetCurrentLocation.dart';
import 'dart:core';

class ImageSliderScreen extends StatefulWidget {
  const ImageSliderScreen({
    Key? key,
    required this.title,
    required this.itemColor,
    required this.userNumber,
    required this.description,
    required this.itemPrice,
    required this.sellerLat,
    required this.sellerLng,
    required this.address,
    required this.urlImage1,
    required this.urlImage2,
    required this.urlImage3,
    required this.urlImage4,
    required this.urlImage5,
    required this.userName,
    required this.userEmail,
    required this.time,
    required this.priceNegotiable,
    required this.returnEligible,
    // required this.viewerPosition,
  }) : super(key: key);

  final String title,
      itemColor,
      userNumber,
      description,
      address,
      itemPrice,
      userName;
  final bool priceNegotiable, returnEligible;
  // Position? viewerPosition;
  final Timestamp time;
  final String urlImage1, urlImage2, urlImage3, urlImage4, urlImage5;
  final String userEmail;
  final double sellerLat, sellerLng;
  @override
  State<ImageSliderScreen> createState() => _ImageSliderScreenState();
}

class _ImageSliderScreenState extends State<ImageSliderScreen> {
  late CarouselController _carouselController;
  List<String> links = [];
  VideoPlayerController? _controller;
  String youtubeLink = "https://youtu.be/8D2UNnN_flM";
  List<Location>? locations;
  double viewerLatitude = 0.0;
  double viewerLongitude = 0.0;
  double distanceInMiles = 0;
  bool viewNumb = false;
  @override
  void initState() {
    super.initState();
    links = [
      widget.urlImage1,
      widget.urlImage2,
      widget.urlImage3,
      widget.urlImage4,
      widget.urlImage5,
    ];
    _carouselController = CarouselController();
    _controller = VideoPlayerController.network(youtubeLink)
      ..initialize().then((_) {
        setState(() {});
      });
    getLatLngFromAdress();
    getMyData();

  }
  void sendEmail() async {
    final emailLaunchUri = Uri(
      scheme: 'mailto',
      path: widget.userEmail, // Replace with the recipient's email address


      query: _encodeQueryParameters(<String, String>{
        'subject': "Inquiry about ${widget.title}",
        'body': 'I am interested in ${widget.title} can you share me some more details?',
      }),
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      print('Could not launch $emailLaunchUri');
    }
  }
  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }


  getLatLngFromAdress() async {
    List<Location> locations = await locationFromAddress(widget.address);
    if (locations.isNotEmpty) {
      Position currentPosition = await getUserPosition();
      viewerLatitude = currentPosition.latitude;
      viewerLongitude = currentPosition.longitude;

      // Use the latitude, longitude, and timestamp variables as needed
      // For example, you can print them or assign them to other variables
      if (kDebugMode) {
        print("&" * 100);
        print("Latitude: $viewerLatitude");
        print("Longitude: $viewerLongitude");
        print("&" * 100);
      }

      setState(() {
        distanceInMiles = Geolocator.distanceBetween(widget.sellerLat,
            widget.sellerLng, viewerLatitude, viewerLongitude) *
            0.00062137;
        if (kDebugMode) {
          print("(" * 100);
          print(distanceInMiles);
          print("(" * 100);
        }
      });
    } else {
      print("&" * 100);
      print("No location found for the given address");
      print("&" * 100);
    }
  }
  getMyData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((results) {
      setState(() {
        viewNumb = results.data()?['viewNumber'];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 5,
          title: Text(
            widget.title.toUpperCase(),
            style:
            const TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.white),
                child: const Text("Seller Location"),
                onPressed: () {
                  MapsLauncher.launchQuery(widget.address);
                  //MapsLauncher.launchCoordinates(widget.sellerLat, widget.sellerLng);
                },
              ),
              const SizedBox(
                height: 5,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue),
                child: const Text("Contact Seller"),
                onPressed: () async {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: sendEmail,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.mail),
                                    SizedBox(width: 5,),
                                    Text(
                                      "Email",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              viewNumb? TextButton(
                                onPressed: () async {
                                  final link = WhatsAppUnilink(
                                    phoneNumber: '+1 ${widget.userNumber}',
                                    text:
                                    "Hey! I'm inquiring about the ${widget.title}",
                                  );
                                  await launch(link.toString());
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.message),
                                    SizedBox(width: 5,),
                                    Text(
                                      "Whatsapp",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ):Container(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ImageSliderScreen(
                  title: widget.title,
                  itemColor: widget.itemColor,
                  userNumber: widget.userNumber,
                  userEmail: widget.userEmail,
                  description: widget.description,
                  itemPrice: widget.itemPrice,
                  sellerLat: widget.sellerLat,
                  sellerLng: widget.sellerLng,
                  address: widget.address,
                  urlImage1: widget.urlImage1,
                  urlImage2: widget.urlImage2,
                  urlImage3: widget.urlImage3,
                  urlImage4: widget.urlImage4,
                  urlImage5: widget.urlImage5,
                  userName: widget.userName,
                  time: widget.time,
                  priceNegotiable: widget.priceNegotiable,
                  returnEligible: widget.returnEligible),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  BannerAdWidget(), // Top banner ad
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 20, left: 6.0, right: 12.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Text(
                            widget.address,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(letterSpacing: 2.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //links.isEmpty
                  //   ?
                  CarouselSlider.builder(
                    itemCount: links.length,
                    options: CarouselOptions(
                      autoPlay: false,
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false
                    ),
                    itemBuilder: (context, index, realIdx) {
                      return Center(
                          child: Image.network(links[index],
                              fit: BoxFit.cover, width: 1000));
                    },
                  ),
                  //: circularProgress(),
                  const SizedBox(height: 10),
                  Text(
                    "Price: \$${widget.itemPrice}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Seller Information",
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyAds(sellerId: userId),
                            ),
                          );
                        },
                        child: const Text(
                          "View Profile",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                            decorationColor: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                  Text(widget.userName.toUpperCase()),
                  const SizedBox(
                    height: 5,
                  ),
                  //BannerAdWidget(), // Bottom banner ad

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  Container(
                    height: 3,
                  ),
                  Text("Item: ${widget.title}"),
                  Text("Color: ${widget.itemColor}"),
                  Text("Description: ${widget.description}"),

                  /*   Text("Distance: ${distanceInMiles.toStringAsFixed(1)}"),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      infoCard(
                        text: "${distanceInMiles.toStringAsFixed(1)} mil",
                        image: "assets/images/road.png",
                        color: Colors.black,
                      ),
                      infoCard(
                        text: "\$${widget.itemPrice}",
                        image: "assets/images/give-money.png",
                        color: Colors.green,
                      ),
                      infoCard(
                          text: tAgo.format(widget.time.toDate()),
                          image: "assets/images/hourglass.png",
                          color: Colors.red),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      widget.priceNegotiable
                          ? const infoCard(
                        text: "Negotiable",
                        image: "assets/images/money.png",
                        color: Colors.black,
                      )
                          : Container(),
                      widget.returnEligible
                          ? const infoCard(
                        text: "Returns",
                        image: "assets/images/security.png",
                        color: Colors.green,
                      )
                          : Container(),
                    ],
                  ),
                  widget.returnEligible
                      ? Opacity(
                    opacity: 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.yellow),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 8),
                        child: Text(
                            "Return Eligible, this item can be returned within 24 hrs of purchase."),
                      ),
                    ),
                  )
                      : Container(),

                  const SizedBox(
                    height: 6,
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  GestureDetector(
                    onDoubleTap: () {
                      //MapsLauncher.launchCoordinates(widget.sellerLat, widget.sellerLng);
                      MapsLauncher.launchQuery(widget.address);
                    },
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(widget.sellerLat, widget.sellerLng),
                          zoom: 13.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(widget.sellerLat, widget.sellerLng),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class infoCard extends StatelessWidget {
  const infoCard(
      {super.key,
        required this.text,
        required this.image,
        required this.color});

  final String text;
  final String image;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          width: 100,
          height: 105,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 3, left: 10, right: 10, top: 10),
                  child: ImageIcon(
                    AssetImage(image),
                    color: color,
                    size: 44,
                  ),
                ),
                AutoSizeText(
                  minFontSize:6,
                  maxFontSize:12,
                  text,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
