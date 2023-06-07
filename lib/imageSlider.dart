import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:resell_app/ProfileSection.dart';
import 'package:resell_app/globalVar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'BannerAd.dart';
import 'package:video_player/video_player.dart';

class ImageSliderScreen extends StatefulWidget {
  ImageSliderScreen(
      {Key? key,
      required this.title,
      required this.itemColor,
      required this.userNumber,
      required this.description,
      required this.itemPrice,
      required this.lat,
      required this.lng,
      required this.address,
      required this.urlImage1,
      required this.urlImage2,
      required this.urlImage3,
      required this.urlImage4,
      required this.urlImage5,
      required this.userName,
      })
      : super(key: key);

  final String title,
      itemColor,
      userNumber,
      description,
      address,
      itemPrice,
      userName;
  final String urlImage1, urlImage2, urlImage3, urlImage4, urlImage5;
  final double lat, lng;
  @override
  State<ImageSliderScreen> createState() => _ImageSliderScreenState();
}

class _ImageSliderScreenState extends State<ImageSliderScreen> {
  late CarouselController _carouselController;
  List<String> links = [];
  int _currentPage = 0; // Track the current page
  VideoPlayerController? _controller;
  String youtubeLink="https://youtu.be/8D2UNnN_flM";
  bool _isVideoPlaying = false;

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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
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
                //MapsLauncher.launchCoordinates(widget.lat, widget.lng);
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
                final link = WhatsAppUnilink(
                  phoneNumber: '+1 ${widget.userNumber}',
                  text: "Hey! I'm inquiring about the ${widget.title}",
                );
                await launch(link.toString());
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BannerAdWidget(), // Top banner ad
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 6.0, right: 12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_pin,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    Container(
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
              CarouselSlider.builder(
                itemCount: links.length,
                options: CarouselOptions(
                  autoPlay: true,
                  aspectRatio: 2.0,
                  enlargeCenterPage: true,
                ),
                itemBuilder: (context, index, realIdx) {
                  return Container(
                    child: Center(
                        child: Image.network(links[index],
                            fit: BoxFit.cover, width: 1000)),
                  );
                },
              ),
              /*    CarouselSlider(
                carouselController: _carouselController,
                items: links.map((url) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(
                      url,
                      fit: BoxFit.fitWidth,
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  initialPage: 0, // Set the initial page
                //  enlargeCenterPage: true,
                //  viewportFraction: 0.8,
                //  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentPage = index; // Update the current page
                    });
                  },
                ),
              ),*/
              /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text("${_currentPage+1}/5")
              ],),*/
              const SizedBox(height: 10),
              Text(
                "Price: \$${widget.itemPrice}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyProfile(sellerId: userId),
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
              BannerAdWidget(), // Bottom banner ad

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
              const SizedBox(
                height: 5,
              ),
           /*   Stack(
                children: [
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isVideoPlaying = !_isVideoPlaying;
                        _isVideoPlaying
                            ? _controller?.play()
                            : _controller?.pause();
                      });
                    },
                    child: AnimatedOpacity(
                      opacity: _isVideoPlaying ? 0.0 : 1.0,
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: Icon(
                          Icons.play_arrow,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),  */            GestureDetector(
                onDoubleTap: () {
                  //MapsLauncher.launchCoordinates(widget.lat, widget.lng);
                  MapsLauncher.launchQuery(widget.address);
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(widget.lat, widget.lng),
                      zoom: 13.0,
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayerOptions(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: LatLng(widget.lat, widget.lng),
                            builder: (ctx) => Icon(
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
    );
  }
}
