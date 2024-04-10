import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:lucky_table/Screens/animated_login.dart';
import 'package:lucky_table/Screens/introScreens/introScreens/intro.dart';
import 'package:lucky_table/main.dart';

class InternetCheck extends StatefulWidget {
  @override
  _InternetCheckState createState() => _InternetCheckState();
}

class _InternetCheckState extends State<InternetCheck> {
  bool hasInternet = false;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
 checkInternet();
     _connectivity.onConnectivityChanged.listen((event) {
      if (event != ConnectivityResult.none) {
        // Internet bağlandığında ana sayfaya yönlendir

        setState(() {
          hasInternet = true;
        });
      }
    });
    super.initState();
  }

  Future checkInternet() async {
   var result= await  _connectivity.checkConnectivity();
   if (result != ConnectivityResult.none) {
        // Internet bağlandığında ana sayfaya yönlendir

        setState(() {
          hasInternet = true;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet == true ? const MyApp() : NoInternetScreen();
  }
}

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.signal_wifi_connected_no_internet_4,
              size: 50,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "İnternet Bağlantısını Kontrol Edin!",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
