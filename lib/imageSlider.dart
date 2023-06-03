import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

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

class _ImageSliderScreenState extends State<ImageSliderScreen>
    with SingleTickerProviderStateMixin {
  late CarouselController _carouselController;

  late TabController tabController;
  static List<String> links = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLinks();
    _carouselController = CarouselController();
  }

  getLinks() {
    links.add(widget.urlImage1);
    links.add(widget.urlImage2);
    links.add(widget.urlImage3);
    links.add(widget.urlImage4);
    links.add(widget.urlImage5);
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 6.0, right: 12.00),
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
            const SizedBox(
              height: 20.0,
            ),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 2),
                  ),
                  child: CarouselSlider(
                    items: links.map((url) {
                      if (kDebugMode) {
                        print(url);
                      }
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
                      reverse: false, // Disable reverse sliding
                      enableInfiniteScroll: false, // Disable infinite scrolling
                      enlargeCenterPage: true, // Enlarge the center page
                      viewportFraction:
                          0.8, // Set the visible fraction of the carousel item
                      enlargeStrategy: CenterPageEnlargeStrategy.scale,
                      scrollDirection:
                          Axis.horizontal, // Set the scroll directio
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.brush),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Text(widget.itemColor),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.phone),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Text(widget.userNumber),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
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
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
