import 'dart:async';
 
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart';
 import 'package:lucky_table/Screens/intro_page.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucky_table/Screens/qr_screen_result.dart';
// import 'package:lucky_table/Screens/qr_screen_result.dart';
import 'package:lucky_table/models/staticClass.dart';
import 'package:lucky_table/services/cafeService.dart';
import 'package:lucky_table/services/userService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

@override
void initState(){
    controller.stop();
    controller.start();
     
getCurrentLocation();    
  super.initState();
}
Future<void> getCurrentLocation() async {
location = await getUserCurrentLocation();
if (location == null) {
      
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => IntroPage()));
      return;
   
      
    }
 }

  //* qr scan transaction
  bool isScanComplete = false;

  //* flash bool
  bool isFlash = false;

  //* cam bool
  bool isCam = false;

  //* toggle flash controller
  MobileScannerController controller = MobileScannerController();
  @override
  void dispose() {
    controller?.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  //* change page
  void closeScanner() {
    setState(() {
      isScanComplete = false;
    });
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

   
  var lastScan;
  Position? location;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      //* app bar
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
        title: Text(
          'QR Tarama',
          style: GoogleFonts.poppins(
            fontSize: 25,
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
          // style: Theme.of(context).textTheme.displayLarge,
        ),
        centerTitle: true,
      ),

      //* body
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            //* Body title
            Expanded(
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.only(top: 50)),
                  Text(
                    "QR kodunuzu kameraya gösterin",
                    // style: Theme.of(context).textTheme.bodyLarge,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Otomatik Olarak Taranır",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontWeight: FontWeight.normal,
                    ),
                    // style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            //* Camera Container
            Expanded(
              flex: 2,
              child: MobileScanner(
              
                controller: controller,
                // fit: BoxFit.contain,
                onDetect: (capture) async {
                  var currentScan = DateTime.now();
                  if (lastScan != null &&
                      currentScan.difference(lastScan) <
                          const Duration(seconds: 5)) {
                    return;
                  }
                  lastScan = currentScan;
                  final List<Barcode> barcodes = capture.barcodes;
                  var barcode = barcodes.first;
                  if (!isScanComplete) {
                    String qrResult = barcode.rawValue ?? "---";

                    var table =
                        await CafeService().getTableWithBarcode(qrResult);

                    if (table == null) {
                      //alert basılacak "QR Kod Geçersiz"!
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Color.fromARGB(255, 64, 73, 83),
                            title: Text('Hata',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2)),
                            content: Text('Bu QR Kod Geçersizdir!',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 1)),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Tamam',
                                    style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2)),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }


                    var result = await CafeService().createUserBarcode2(
                        table.document, table.cafe, StaticClass.document,LatLng(location!.latitude, location!.longitude));


                    //Gift Hakkı Ekle
                    // await updateGiftNum();

                    if (result.Result == false) {
                      //alert basılacak "result.message"!
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Color.fromARGB(255, 64, 73, 83),
                            title: Text('Hata',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2)),
                            content: Text(result.Message.toString(),
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 1)),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Tamam',
                                    style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2)),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }
                    setState(() {
                      isScanComplete = true;
                    });
                    await FirebaseMessaging.instance
                        .subscribeToTopic("cafe${table.cafe?.id}");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrResultPage(
                            closeScreen: closeScanner,
                            qrResult: result.ResultId!),
                      ),
                    );
                  }
                },
              ),
            ),

            //* Tools Container
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //* flash toggle
                  // MyTool(
                  //   onPressed: () {
                  //     HapticFeedback.heavyImpact();
                  //     setState(() {
                  //       isFlash = !isFlash;
                  //     });
                  //     controller.toggleTorch();
                  //   },
                  //   text: "Flash",
                  //   icon: Icon(
                  //     Icons.flash_on,
                  //     color: isFlash ? Colors.yellow : Colors.white,
                  //   ),
                  // ),
                  ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.heavyImpact();
                      setState(() {
                        isFlash = !isFlash;
                      });
                      controller.toggleTorch();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 64, 73, 83),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(50.0), // Kenar yuvarlaklığı
                      ),
                      padding: EdgeInsets.all(16.0), // Düğme iç içe boşluğu
                    ),
                    child: Container(
                      padding: EdgeInsets.only(top: 4),
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.flash_on,
                            color: isFlash ? Colors.yellow : Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Flaş',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //* camera toggle
                  // MyTool(
                  //   onPressed: () {
                  //     HapticFeedback.heavyImpact();
                  //     setState(() {
                  //       isCam = !isCam;
                  //     });
                  //     controller.switchCamera();
                  //   },
                  //   text: "Camera",
                  //   icon: const Icon(
                  //     Icons.switch_camera_outlined,
                  //     color: Colors.white,
                  //   ),
                  // ),

                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      setState(() {
                        isCam = !isCam;
                      });
                      controller.switchCamera();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 64, 73, 83),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(50.0), // Kenar yuvarlaklığı
                      ),
                      padding: EdgeInsets.all(16.0), // Düğme iç içe boşluğu
                    ),
                    child: Container(
                      padding: EdgeInsets.only(top: 4),
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isCam
                                ? Icons.camera_front_outlined
                                : Icons.switch_camera_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Kamera',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //* gallery toggle
                  // MyTool(
                  //   text: "Gallery",
                  //   onPressed: () {
                  //     HapticFeedback.heavyImpact();
                  //   },
                  //   icon: const Icon(
                  //     Icons.browse_gallery_outlined,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
