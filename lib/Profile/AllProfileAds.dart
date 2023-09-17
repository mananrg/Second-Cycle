import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resell_app/HomeScreen.dart';
import 'package:resell_app/globalVar.dart';
import 'package:timeago/timeago.dart' as tAgo;
import '../AdDescription.dart';

class MyAds extends StatefulWidget {
  MyAds({Key? key, required this.sellerId}) : super(key: key);
  String sellerId;
  @override
  State<MyAds> createState() => _MyAdsState();
}

class _MyAdsState extends State<MyAds> {
  FirebaseAuth auth = FirebaseAuth.instance;
  late String userName;
  late String userNumber;
  late String itemPrice;
  late String itemModel;
  late String itemColor;
  late String description;
  QuerySnapshot? items;
  Future<Future> showDialogForUpdateData(
      selectedDoc,
      oldUserName,
      oldPhoneNumber,
      oldItemPrice,
      oldItemName,
      oldItemColor,
      oldItemDescription,
      ) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: AlertDialog(
              title: const Text(
                "Edit AD",
                style: TextStyle(fontSize: 24, letterSpacing: 2.0),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 TextFormField(
                    initialValue: oldUserName,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldUserName = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    initialValue: oldPhoneNumber,
                    decoration: const InputDecoration(
                      hintText: 'Enter your Phone Number',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldPhoneNumber = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    initialValue: oldItemPrice,
                    decoration: const InputDecoration(
                      hintText: 'Enter Item Price',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldItemPrice = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    initialValue: oldItemName,
                    decoration: const InputDecoration(
                      hintText: 'Enter Item Name',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldItemName = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    initialValue: oldItemColor,
                    decoration: const InputDecoration(
                      hintText: 'Enter Item Color',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldItemColor = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    initialValue: oldItemDescription,
                    decoration: const InputDecoration(
                      hintText: 'Enter Item Description',
                    ),
                    onChanged: (value) {
                      setState(() {
                        oldItemDescription = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                    child: const Text("Update Now"),
                    onPressed: () {
                      Map<String, dynamic> itemData = {
                       'userName': oldUserName,
                        'userNumber': oldPhoneNumber,
                        'itemPrice': oldItemPrice,
                        'itemModel': oldItemName,
                        'itemColor': oldItemColor,
                        'description': oldItemDescription,
                      };
                      print("@"*100);
                      print(itemData);
                      print("@"*100);
                      FirebaseFirestore.instance
                          .collection('items')
                          .doc(selectedDoc)
                          .update(itemData)
                          .then((value) {
                            print("^"*100);
                            print("Updated");
                            print("^"*100);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: 'Ad Updated',
                                    message:
                                    "To update profile please go to Edit Profile Section",
                                    contentType: ContentType.success,
                                  ),
                                ),
                              );
                      }).catchError((onError) {
                        const AlertDialog(
                          title: Text("Issue Updating Data"),
                          content: Text("Please try again later!"),
                        );
                      });

                    })
              ],
            ),
          );
        });
  }
  _buildBackButton() {
    return IconButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      },
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
    );
  }

  _buildUserImage() {
    return Container(
      width: 50,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: NetworkImage(
              adUserImageUrl,
            ),
            fit: BoxFit.fill),
      ),
    );
  }

  getResults() {
    FirebaseFirestore.instance
        .collection('items')
        .where("uid", isEqualTo: widget.sellerId)
        .where("status", isEqualTo: "approved")
        .get()
        .then((value) {
      setState(() {
        items = value;
        adUserName = items?.docs[0].get('userName');
        // adUserImageUrl=items?.docs[0].get('userName');
      });
    });
  }

 Widget showItemsList() {
    if (items != null) {
      print("*" * 100);
      print(items);
      print("*" * 100);

     return ListView.builder(
          itemCount: items!.docs.length,
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, i) {
            print("*" * 100);
            print(items?.docs[i].get('itemModel'));
            print("*" * 100);

            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey, //color of border
                  width: 0.5, //width of border
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImageSliderScreen(
                            title: items?.docs[i].get('itemModel'),
                            itemColor: items?.docs[i].get('itemColor'),
                            itemPrice: items?.docs[i]
                                .get('itemPrice'),
                            userName: items?.docs[i]
                            .get('userName'),
                            userNumber: items?.docs[i].get('userNumber'),
                            userEmail: items?.docs[i].get('userEmail'),
                            description: items?.docs[i].get('description'),
                            sellerLat: items?.docs[i].get('lat'),
                            sellerLng: items?.docs[i].get('lng'),
                            address: items?.docs[i].get('address'),
                            urlImage1: items?.docs[i].get('urlImage1'),
                            urlImage2: items?.docs[i].get('urlImage2'),
                            urlImage3: items?.docs[i].get('urlImage3'),
                            urlImage4: items?.docs[i].get('urlImage4'),
                            urlImage5: items?.docs[i].get('urlImage5'),
                            time: items?.docs[i].get('time'),
                              priceNegotiable:items?.docs[i].get('priceNegotiable'),
                              returnEligible:items?.docs[i].get('returnEligible'),
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(items?.docs[i].get("urlImage1"),
                            fit: BoxFit.fill),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 190,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    "${items?.docs[i].get('userName')}"
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF266AFE),
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFF266AFE),
                                    ),
                                  ),
                                ),
                                items?.docs[i].get('uid') == userId
                                    ? Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                                if (items?.docs[i].get('uid') ==
                                                  userId) {
                                                showDialogForUpdateData(
                                                  items?.docs[i].id,
                                                  items?.docs[i]
                                                      .get('userName'),
                                                  items?.docs[i]
                                                      .get('userNumber'),
                                                  items?.docs[i]
                                                      .get('itemPrice'),
                                                  items?.docs[i]
                                                      .get('itemModel'),
                                                  items?.docs[i]
                                                      .get('itemColor'),
                                                  items?.docs[i]
                                                      .get('description'),
                                                );
                                              }
                                            },
                                            child: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                if (items?.docs[i].get("uid") ==
                                                    userId) {
                                                  FirebaseFirestore.instance
                                                      .collection("items")
                                                      .doc(items?.docs[i].id)
                                                      .delete();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          const HomeScreen(),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Icon(
                                                  Icons.delete_forever_sharp),
                                            ),
                                          )
                                        ],
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [],
                                      ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(top: 2),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: Text(
                                      "${items?.docs[i].get("itemModel")}"
                                          .toUpperCase(),
                                    ),
                                  ),
                                  Text(
                                    "\$${items?.docs[i].get("itemPrice")}",
                                    style: const TextStyle(
                                      letterSpacing: 2.0,
                                      fontSize: 24,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(tAgo.format(
                                          (items?.docs[i].get('time'))
                                              .toDate())),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          });
    } else {
      return const Center(
        child: (Text("Loading...")),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getResults();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          leading: _buildBackButton(),
          title: Text(
            "$adUserName",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade300,
                    Colors.deepPurple,
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: const [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
          ),
        ),
        body: RefreshIndicator(
   
    onRefresh: () => Navigator.pushReplacement(
    context,
    MaterialPageRoute(
    builder: (BuildContext context) =>  MyAds(sellerId: widget.sellerId),
    ),
    ),
          child: Center(
            child: Container(
              width: _screenWidth,
              child: showItemsList(),
            ),
          ),
        ));
  }
}
