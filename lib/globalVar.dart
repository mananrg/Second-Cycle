import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

String userId = "";
String userEmail = "";
String userImageUrl = "";
String getUserName = "";
String getUserNumber = "";

String adUserName = "";
String adUserImageUrl = "";
String phoneNumber="";
String completeAddress = "";
List<Placemark>? placemarks;
Position? position;