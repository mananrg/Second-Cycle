import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import 'BannerAd.dart';

class ImageSliderScreen extends StatefulWidget {
  ImageSliderScreen({
    Key? key,
    required this.title,
    required this.itemColor,
    required this.userNumber,
    required this.description,
    required this.lat,
    required this.lng,
    required this.address,
    required this.urlImage1,
    required this.urlImage2,
    required this.urlImage3,
    required this.urlImage4,
    required this.urlImage5,
  }) : super(key: key);

  final String title, itemColor, userNumber, description, address;
  final String urlImage1, urlImage2, urlImage3, urlImage4, urlImage5;
  final double lat, lng;

  @override
  State<ImageSliderScreen> createState() => _ImageSliderScreenState();
}

class _ImageSliderScreenState extends State<ImageSliderScreen> {
  late CarouselController _carouselController;
  late List<String> links;
  int _currentPage = 0; // Track the current page

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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BannerAdWidget(), // Top banner ad
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 6.0, right: 12.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_pin,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.address,
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(letterSpacing: 2.0),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 2),
              ),
              child: CarouselSlider(
                carouselController: _carouselController,
                items: links.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      url,
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  initialPage: 0, // Set the initial page
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentPage = index; // Update the current page
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Description",
              style: TextStyle(
                fontSize: 19,
                color: Colors.black54,
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
            Text("Item Color: ${widget.itemColor}"),
            Text("Description: ${widget.description}"),
            Expanded(child: SizedBox()),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 368),
                child: ElevatedButton(
                  child: const Text("Check Seller Location"),
                  onPressed: () {
                    MapsLauncher.launchCoordinates(widget.lat, widget.lng);
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 368),
                child: ElevatedButton(
                  child: const Text("Contact Seller"),
                  onPressed: () async {
                    final link = WhatsAppUnilink(
                      phoneNumber: '+1 ${widget.userNumber}',
                      text: "Hey! I'm inquiring about the ${widget.title}",
                    );
                    await launch(link.toString());
                  },
                ),
              ),
            ),
            BannerAdWidget(), // Bottom banner ad
          ],
        ),
      ),
    );
  }
}
