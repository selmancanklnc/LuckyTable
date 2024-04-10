import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucky_table/Screens/customer_result.dart';
import 'package:lucky_table/Screens/qr_screen_result.dart';
// import 'package:lucky_table/Screens/qr_screen_result.dart';
import 'package:lucky_table/models/staticClass.dart';
import 'package:lucky_table/services/cafeService.dart';
import 'package:lucky_table/services/userService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerScanPage extends StatefulWidget {
  CustomerScanPage({super.key, required this.isCoupon});
  bool isCoupon;

  @override
  State<CustomerScanPage> createState() => _CustomerScanPageState(isCoupon);
}


class _CustomerScanPageState extends State<CustomerScanPage> {
  _CustomerScanPageState(this.isCoupon);
@override
void initState(){
    controller.stop();
    controller.start();
     
  super.initState();
}
  //* qr scan transaction
  bool isScanComplete = false;

  //* flash bool
  bool isFlash = false;
  bool isCoupon;

  //* cam bool
  bool isCam = false;

  //* toggle flash controller
  MobileScannerController controller = MobileScannerController();

  //* change page
  void closeScanner() {
    setState(() {
      isScanComplete = false;
    });
  }

  var lastScan;

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
          'QR Tarayın',
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
                    "Müşterinin QR Kodunu Kameraya Gösterin",
                    // style: Theme.of(context).textTheme.bodyLarge,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: 1,
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

                    var userBarcode =
                        await UserService().getUserBarcode(qrResult);
                    String error = "";
                    String customerResult = "";
                    if (userBarcode == null) {
                      error = "Bu QR Kod Geçersizdir!";
                    } else if (userBarcode.cafe != StaticClass.cafe) {
                      error = "Bu kod bu mekan için geçerli değildir.";
                    } else {
                      if (isCoupon) {
                        var cafeGiftCount = userBarcode.cafeGiftCount!;
                        var userGiftCount = userBarcode.userGiftCount!;
                        if (cafeGiftCount > userGiftCount) {
                          error = "Yetersiz Puan";
                        } else {
                          var updateResult = await CafeService().updateGift(
                              userBarcode.cafe,
                              userBarcode.user,
                              userBarcode.cafeGiftCount!);
                          if (updateResult.Result == true) {
                            customerResult =
                                "Puan Kontrolü Tamamlandı, Tebrikler!";
                          } else {
                            error = updateResult.Message!;
                          }
                        }
                      } else {
                        if (userBarcode.giftSuccess != true) {
                          error = "Hediye Bulunamadı";
                        } else if (userBarcode.giftCompleted == true) {
                          error = "Hediye daha önce verildi";
                        } else {
                          var updateResult = await CafeService()
                              .completeRaffleGift(userBarcode.document);
                          if (updateResult.Result == true) {
                            customerResult =
                                "Çekiliş Kontrolü Tamamlandı, Tebrikler!";
                          } else {
                            error = updateResult.Message!;
                          }
                        }
                      }
                    }

                    if (error != "") {
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
                            content: Text(error,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerResultPage(
                          customerResult: customerResult,
                        ),
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
