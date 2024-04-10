import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucky_table/main.dart';
import 'package:lucky_table/services/userService.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: prefer_const_constructors

FirebaseAuth _auth = FirebaseAuth.instance;

void _showToast(BuildContext context, String msg) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(msg),
    ),
  );
}

class Register extends StatefulWidget {
  bool isEnabled = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int index = 0;
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  @override
  void initState() {
    super.initState();
    _firebaseStreamEvents =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      print(user);
    });
  }

  late final StreamSubscription _firebaseStreamEvents;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int index = 0;
  String labelText = "İsminiz nedir?";
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: Container(
        margin: EdgeInsets.only(top: 50, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              labelText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(29, 29, 31, 1),
                  fontFamily: 'SF Pro',
                  fontSize: 24,
                  letterSpacing: -0.699999988079071,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
            Visibility(
              visible: index == 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Color.fromRGBO(255, 255, 255, 1),
                  border: Border.all(
                    color: Color.fromRGBO(148, 148, 148, 1),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: Color.fromRGBO(75, 88, 133, 1), fontSize: 16)),
                ),
              ),
            ),
            Visibility(
              visible: index == 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Color.fromRGBO(255, 255, 255, 1),
                  border: Border.all(
                    color: Color.fromRGBO(148, 148, 148, 1),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: Color.fromRGBO(75, 88, 133, 1), fontSize: 16)),
                ),
              ),
            ),
            Visibility(
              visible: index == 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Color.fromRGBO(255, 255, 255, 1),
                  border: Border.all(
                    color: Color.fromRGBO(148, 148, 148, 1),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: Color.fromRGBO(75, 88, 133, 1), fontSize: 16)),
                ),
              ),
            ),
            Visibility(
              visible: index == 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Color.fromRGBO(255, 255, 255, 1),
                  border: Border.all(
                    color: Color.fromRGBO(148, 148, 148, 1),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: Color.fromRGBO(75, 88, 133, 1), fontSize: 16)),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                index++;
                setState(() {
                  switch (index) {
                    case 1:
                      labelText = "Telefon numaranızı girin";
                      break;
                    case 2:
                      labelText = "E-posta adresinizi girin";
                      break;
                    case 3:
                      labelText = "Şifre oluşturun";
                      break;

                    default:
                  }
                });
                if (index == 4) {
                  final credential = await _auth.createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  if (credential.user != null) {
                    var user = credential.user;

                    user?.sendEmailVerification();

                    UserService().createNewUser(
                        nameController.text, user!.email, user.uid);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString("userId", user.uid);
                    // ignore: use_build_context_synchronously
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  }
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 500, left: 15, right: 15),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Color.fromRGBO(197, 197, 197, 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Sonraki',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromRGBO(74, 74, 74, 1),
                      fontFamily: 'SF Pro',
                      fontSize: 23,
                      letterSpacing: -0.699999988079071,
                      fontWeight: FontWeight.normal,
                      height: 1),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
