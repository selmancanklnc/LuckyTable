import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucky_table/Screens/animated_login.dart';
import 'package:lucky_table/Screens/cafes.dart';
import 'package:lucky_table/Screens/notifications.dart';
import 'package:lucky_table/Screens/profile.dart';

// import 'package:lucky_table/Screens/qr_generate.dart';
import 'package:lucky_table/Widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'qr_scanner.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
   
    return WillPopScope(
      onWillPop: () async {
        // Geri tuşuna basıldığında alert dialog göster
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shadowColor: Colors.white,
              title: Text('Çıkış',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Color.fromARGB(255, 64, 73, 83),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              content: Text('Uygulamadan çıkmak istediğinize emin misiniz?',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1)),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Kullanıcı "Hayır" dedi
                    },
                    child: Text('Hayır',
                        style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 64, 73, 83),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2))),
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text('Evet',
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
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: Padding(
          padding: const EdgeInsets.only(top: 55.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  //todo logo
                  Center(
                    child: Image.asset(
                      'assets/images/qr_code_logo.png',
                      height: 300,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(left: 20),
                      child: IconButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              // Color.fromARGB(255, 64, 73, 83).withOpacity(0.4),
                              Colors.redAccent,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                50.0), // Kenar yuvarlaklığı
                          ),
                          padding: EdgeInsets.all(10.0), // Düğme iç içe boşluğu
                        ),
                        icon: Icon(Icons.notifications_rounded,
                            color: Colors.white),
                        iconSize: 25.0,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationPage()));
                        },
                      ),
                    ),
                  ),
                ],
              ),

              //todo Game title
              // Text(
              //   "Şanslı Masa",
              //   style: GoogleFonts.poppins(
              //     fontSize: 30,
              //     color: Colors.white,
              //     fontWeight: FontWeight.bold,
              //     letterSpacing: 3,
              //   ),
              // ),

              const Spacer(flex: 5),

              Text(
                "Qr kodunu taratın ve",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Color.fromARGB(255, 64, 73, 83),
                  letterSpacing: 3,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "çekiliş hakkı kazanın.",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Color.fromARGB(255, 64, 73, 83),
                  letterSpacing: 3,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 25.0),
              const Spacer(flex: 5),

              Center(
                child: SizedBox(
                  width: 200.0, // Düğme genişliği
                  child: ElevatedButton(
                    onPressed: () async {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(50.0), // Kenar yuvarlaklığı
                      ),
                      padding: EdgeInsets.all(16.0), // Düğme iç içe boşluğu
                    ),
                    child: Text(
                      'QR  Tara',
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
                height: 40,
              ),

              ElevatedButton(
                onPressed: () async {
                  // HapticFeedback.vibrate();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CafesPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 64, 73, 83),
                  padding: EdgeInsets.all(10.0),
                ),
                child: Icon(
                  Icons.location_pin,
                  size: 32.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Şanslı Mekanlar",
                style: GoogleFonts.poppins(
                  color: Color.fromARGB(255, 64, 73, 83),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(flex: 2),

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
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 2.0),
              Icon(
                Icons.code,
                color: Colors.blueAccent,
              ),
              // const Spacer(
              //   flex: 1,
              // ),
              SizedBox(height: 2.0),

              Image(
                image: AssetImage("assets/images/AppLogo3.png"),
                width: 50,
                color: Colors.white,
              ),
              const SizedBox(
                height: 55,
              ),
            ],
          ),
        ),

        // floatingActionButton: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Expanded(
        //       child: Container(
        //         child: FloatingActionButton.small(
        //           backgroundColor: Color.fromARGB(255, 64, 73, 83),
        //           focusColor: Colors.grey,
        //           hoverColor: Colors.white,
        //           onPressed: () async {
        //             await _auth.signOut();
        //             SharedPreferences prefs =
        //                 await SharedPreferences.getInstance();
        //             prefs.clear();

        //             // ignore: use_build_context_synchronously
        //             Navigator.push(context,
        //                 MaterialPageRoute(builder: (context) => HomePageX()));
        //           },
        //           child: const Icon(
        //             Icons.logout,
        //             color: Colors.white,
        //           ),
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //         child: Container(
        //       child: FloatingActionButton.small(
        //         backgroundColor: Color.fromARGB(255, 64, 73, 83),
        //         focusColor: Colors.grey,
        //         hoverColor: Colors.white,
        //         onPressed: () async {
        //           await _auth.signOut();
        //           SharedPreferences prefs =
        //               await SharedPreferences.getInstance();
        //           prefs.clear();

        //           // ignore: use_build_context_synchronously
        //           Navigator.push(context,
        //               MaterialPageRoute(builder: (context) => HomePageX()));
        //         },
        //         child: const Icon(
        //           Icons.logout,
        //           color: Colors.white,
        //         ),
        //       ),
        //     ))
        //   ],
        // ),

        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 10.0,
              left: 30.0,
              child: ElevatedButton(
                onPressed: () async {
                  // HapticFeedback.vibrate();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 64, 73, 83),
                  padding: EdgeInsets.all(10.0),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 32.0,
                  color: Colors.white,
                ),
              ),
            ),
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
