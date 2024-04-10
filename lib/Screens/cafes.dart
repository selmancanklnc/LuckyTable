import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucky_table/Screens/intro_page.dart';
import 'package:lucky_table/models/cafeModels.dart';
import 'package:lucky_table/models/staticClass.dart';
import 'package:lucky_table/models/userModels.dart';
import 'package:lucky_table/services/cafeService.dart';
import 'package:lucky_table/services/userService.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher_string.dart';

class CafesPage extends StatefulWidget {
  @override
  _CafesPageState createState() => _CafesPageState();
}

class _CafesPageState extends State<CafesPage> {
  List<CafeListModel> userBarcodes = [];
  DocumentSnapshot? lastDocument;
  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    getBarcodes();
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0)
          print('ListView scroll at top');
        else {
          print('ListView scroll at bottom');
          getBarcodes(); // Load next documents
        }
      }
    });
  }
  
  late GoogleMap googleMap;
  GoogleMapController? mapController;
  void _onMapCreated(GoogleMapController controller){
    setState(() {
      mapController = controller;
    });
  }

  bool indActive = false;
  Future<void> getBarcodes() async {
    setState(() {
      indActive = true;
    });
    var location = await getUserCurrentLocation();
    if (location == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => IntroPage()));
      return;
    }
    var values =
        await CafeService().getCafes(location?.latitude, location?.longitude);
    lastDocument = values?.last.documentSnapshot;
    setState(() {      Set<Marker> markers = new Set<Marker>();

      if(values != null){
  userBarcodes.addAll(values!);

      userBarcodes.sort((a, b) => a.distance!.compareTo(b.distance!));
      for (var item in userBarcodes) {
        var marker = Marker(
          //add first marker
          markerId: MarkerId(LatLng(item.lat!, item.lon!).toString()),
          position: LatLng(item.lat!, item.lon!), //position of marker

          infoWindow: InfoWindow(
            //popup info
            title: item.name,
            // snippet: 'My Custom Subtitle',
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        );
        mapController?.showMarkerInfoWindow(marker.markerId);
        markers.add(marker);
      }
      }
    

      indActive = false;
      googleMap = GoogleMap(
          onMapCreated: _onMapCreated,
          zoomGesturesEnabled: true, //enable Zoom in, out on map
          initialCameraPosition: CameraPosition(
            //innital position in map
            target: LatLng(
                location.latitude, location.longitude), //initial position
            zoom: 10.0, //initial zoom level
          ),
          
          //Map widget from google_maps_flutter package
          markers: markers);
          
    });
    
  }

  Future<void> onRefresh() async {
    userBarcodes = [];
    lastDocument = null;
    getBarcodes();
  }

  Future<Position?> getUserCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // ignore: use_build_context_synchronously
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    try {
      return await Geolocator.getCurrentPosition();
    } catch (error) {
      return null;
    }
  }

  Future<void> checkAndLaunchGoogleMaps() async {
    final url = 'comgooglemaps://'; // Google Maps uygulama URL'si

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Google Maps yüklü değilse, App Store'da Google Maps sayfasına yönlendir.
      final appStoreUrl =
          'https://apps.apple.com/tr/app/google-maps/id585027354';

      if (await canLaunch(appStoreUrl)) {
        await launch(appStoreUrl);
      } else {
        throw 'Google Maps yüklenemedi';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 64, 73, 83),
          leading: IconButton(
            color: Colors.white,
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
            ),
          ),
          title: Center(
            child: Text(
              'Şanslı Mekan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              color: Colors.white,
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            child: googleMap,
                            height: 500,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Kapat',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 64, 73, 83),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.location_pin,
              ),
            ),
          ],
        ),
        body: Center(
            child: userBarcodes.isNotEmpty
                ? RefreshIndicator(
                    onRefresh: onRefresh,
                    child: ListView.builder(
                      itemCount: userBarcodes.length,
                      controller: scrollController,
                      itemBuilder: (context, index) {
                        var document = userBarcodes[index];
                        var cafe = document.name;
                        var distance = document.distance;
                        var lat = document.lat;
                        var lon = document.lon;

                        var user = StaticClass.name;
                        late ImageProvider image;
                        if (document?.image != null) {
                          Uint8List brandBytes =
                              base64.decode(document?.image ?? "");
                          image = Image.memory(brandBytes).image;
                        }
                        return InkWell(
                          onTap: () async {
                            String googleMapsUrl =
                                'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving';

                            if (await canLaunchUrlString(googleMapsUrl)) {
                              await launchUrlString(googleMapsUrl);
                            } else {
                              throw 'Google Maps açılamıyor';
                            }
                          },
                          child: Container(
                            padding:
                                EdgeInsets.only(bottom: 0, left: 10, right: 5),
                            margin: EdgeInsets.only(
                                top: 10, bottom: 0, right: 10, left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(25),
                              ),
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.1),
                                  width: 1),
                              boxShadow: [
                                BoxShadow(
                                  // color: fromHex(category!.cafeColor!),
                                  color: Color.fromRGBO(58, 66, 86, 1.0)
                                      .withOpacity(0.9),
                                  // spreadRadius: 0,
                                  // blurRadius: 0,
                                  // offset: Offset(0,
                                  //     3), // changes position of shadow
                                ),
                              ],
                              // image: DecorationImage(
                              //     image: image,
                              //     fit: BoxFit.fitWidth)
                            ),
                            child: Container(
                              // decoration: const BoxDecoration(
                              //   borderRadius: BorderRadius.only(
                              //     topLeft: Radius.circular(24),
                              //     topRight: Radius.circular(24),
                              //     bottomLeft: Radius.circular(24),
                              //     bottomRight: Radius.circular(24),
                              //   ),
                              // ),
                              height: MediaQuery.of(context).size.height * 0.12,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.60,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(document?.name ?? "",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Colors.greenAccent,
                                                fontFamily: 'SF Pro Text',
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                height: 1)),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Mesafe: ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight
                                                      .bold, // Kalın font
                                                  fontSize: 15,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    '${distance?.toStringAsFixed(1)} km',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight
                                                      .normal, // Normal kalınlıkta font
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          document?.image != null
                                              ? Image(
                                                  image: image,
                                                  color: Colors.white,
                                                  fit: BoxFit.fitWidth,
                                                  width: 90,
                                                )
                                              : Image.asset(
                                                  "assets/images/AppLogo3.png",
                                                  color: Colors.white,
                                                  fit: BoxFit.fitWidth,
                                                  width: 90,
                                                )
                                        ]),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : CircularProgressIndicator(
                    color: Colors.grey,
                  )));
  }
}
