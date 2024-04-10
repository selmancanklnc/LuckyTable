import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucky_table/Screens/animated_login.dart';
import 'package:lucky_table/Screens/cafes.dart';
import 'package:lucky_table/Screens/customer_scan.dart';
import 'package:lucky_table/Screens/profile.dart';
// import 'Screens/animated_login.dart';

// import 'package:lucky_table/Screens/qr_generate.dart';
import 'package:lucky_table/Widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'qr_scanner.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});
  @override
  Widget build(BuildContext context) {
    Widget component2(String string, double width, VoidCallback voidCallback) {
      Size size = MediaQuery.of(context).size;
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 20, sigmaX: 20),
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: voidCallback,
            child: Container(
              height: size.width / 8,
              width: size.width / width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 64, 73, 83),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                string,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.8),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // Geri tuşuna basıldığında alert dialog göster
        bool exit = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 45, 51, 58),
              content: const Text(
                  'Uygulamadan çıkmak istediğinize emin misiniz?',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal)),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Kullanıcı "Hayır" dedi
                  },
                  child: const Text('Hayır',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text('Evet',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );

        // Eğer kullanıcı "Evet" dediyse uygulamayı kapat
        return exit == true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: Padding(
          padding: const EdgeInsets.only(top: 55.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //todo logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Image.asset(
                  'assets/images/customer.png',
                  height: 300,
                ),
              ),

              const Spacer(flex: 1),

              SizedBox(height: 20.0),
              Text(
                "Çekiliş Kontrolü İçin QR Kod Taratın",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Color.fromARGB(255, 64, 73, 83),
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal,
                ),
              ),

              // const Spacer(flex: 1),

              const SizedBox(
                height: 10,
              ),

              Center(
                child: SizedBox(
                  width: 200.0, // Düğme genişliği
                  child: ElevatedButton(
                    onPressed: () async {
                      // HapticFeedback.vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerScanPage(
                            isCoupon: false,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.withOpacity(.1),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(50.0), // Kenar yuvarlaklığı
                      ),
                      padding: EdgeInsets.all(16.0), // Düğme iç içe boşluğu
                    ),
                    child: Text(
                      'Çekiliş  Tara',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 60,
              ),

              Text(
                "Puan Kontrolü İçin QR Kod Taratın",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Color.fromARGB(255, 64, 73, 83),
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal,
                ),
              ),

              // const Spacer(flex: 1),

              const SizedBox(
                height: 10,
              ),

              Center(
                child: SizedBox(
                  width: 200.0, // Düğme genişliği
                  child: ElevatedButton(
                    onPressed: () async {
                      // HapticFeedback.vibrate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerScanPage(
                            isCoupon: true,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(.1),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(50.0), // Kenar yuvarlaklığı
                      ),
                      padding: EdgeInsets.all(16.0), // Düğme iç içe boşluğu
                    ),
                    child: Text(
                      'Puan  Tara',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.0),
                child: Divider(
                  color: Colors.white,
                  thickness: 2,
                ),
              ),

              //todo developer details
              Text(
                "Developed by TrdSoft",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 2.0),
              Icon(
                Icons.code,
                color: Colors.blueAccent,
              ),
              SizedBox(height: 2.0),

              Image(
                image: AssetImage("assets/images/AppLogo3.png"),
                width: 50,
                color: Colors.white,
                opacity: AlwaysStoppedAnimation(1),
              ),
              const SizedBox(
                height: 55,
              ),
            ],
          ),
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 10.0,
              right: 15.0,
              child: ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shadowColor: Colors.white,
                        title: Text('Oturumu Kapat',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Color.fromARGB(255, 64, 73, 83),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                        content: Text('Hesabınızdan çıkış yapılacaktır.',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 1)),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              // Close the dialog
                              Navigator.of(context).pop();
                            },
                            child: Text('İptal',
                                style: GoogleFonts.poppins(
                                    color: Color.fromARGB(255, 64, 73, 83),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2)),
                          ),
                          TextButton(
                            onPressed: () async {
                              await _auth.signOut();
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.clear();

                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePageX()));
                            },
                            child: Text('Çıkış',
                                style: GoogleFonts.poppins(
                                    color: Color.fromARGB(255, 64, 73, 83),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2)),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 64, 73, 83),
                  padding: EdgeInsets.all(10.0),
                ),
                child: Icon(
                  Icons.logout,
                  size: 28.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
