import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'HomeScreen.dart';
import 'globalVar.dart';
import 'imageSlider.dart';
import 'package:timeago/timeago.dart' as tAgo;

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchQueryController= TextEditingController();
  bool _isSearching =false;
  String searchQuery="";
  FirebaseAuth auth = FirebaseAuth.instance;
  QuerySnapshot? items;
  Widget _buildSearchField(){
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: const InputDecoration(hintText: "Search here.....",border: InputBorder.none, hintStyle: TextStyle(color: Colors.white30),

      ),
      style: const TextStyle(color: Colors.white,fontSize: 16.0,),
      onChanged: (value)=>updateSearchQuery(value),
    );
  }
 List<Widget> _buildActions(){
    if(_isSearching){
      return [IconButton(onPressed: (){
        if(_searchQueryController==null|| _searchQueryController.text.isEmpty){
          Navigator.pop(context);
          return;
        }
        _clearSearchQuery();
      }, icon:const Icon(Icons.clear))];
    }return [IconButton(onPressed: _startSearch, icon: const Icon(Icons.search),)];
  }
  _startSearch(){
    ModalRoute.of(context)?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching=true;
    });
  }
  updateSearchQuery(String newQuery){
    setState(() {
      getResults();
      searchQuery=newQuery;
    });
  }
  _stopSearching(){
    _clearSearchQuery();
    setState(() {
      _isSearching=false;
    });
  }
  _clearSearchQuery(){
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }
  _buildTitle(BuildContext context){
    return const Text("Search Product",style: TextStyle(color: Colors.white),);
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

  getResults(){
    FirebaseFirestore.instance.collection('items').where("itemModel",isGreaterThanOrEqualTo: _searchQueryController.text.trim()).where("status",isEqualTo: "approved").get().then((results){
      setState(() {
        items=results;
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
                            userNumber: items?.docs[i].get('userNumber'),
                            description: items?.docs[i].get('description'),
                            lat: items?.docs[i].get('lat'),
                            lng: items?.docs[i].get('lng'),
                            address: items?.docs[i].get('address'),
                            urlImage1: items?.docs[i].get('urlImage1'),
                            urlImage2: items?.docs[i].get('urlImage2'),
                            urlImage3: items?.docs[i].get('urlImage3'),
                            urlImage4: items?.docs[i].get('urlImage4'),
                            urlImage5: items?.docs[i].get('urlImage5'),
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
      return Center(
        child: (Text("Loading...")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching? const BackButton():_buildBackButton(),
        title: _isSearching? _buildSearchField():_buildTitle(context),
        actions: _buildActions(),
      flexibleSpace: Container(decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent,Colors.redAccent,],begin: FractionalOffset(0.0,0.0),end: FractionalOffset(0.0, 1.0),stops: [0.0,1.0],tileMode: TileMode.clamp),
      ),),
      ),body: Center(child: Container(width: MediaQuery.of(context).size.width,
      child: showItemsList(),
    ),),
    );
  }
}
