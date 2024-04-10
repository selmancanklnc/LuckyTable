import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucky_table/Screens/intro_page.dart';
// import 'package:lucky_table/Screens/register.dart';
// import 'package:lucky_table/main.dart';
import 'package:lucky_table/services/userService.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: prefer_const_constructors

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
FirebaseAuth _auth = FirebaseAuth.instance;
Future<void> signInWithGoogle(BuildContext context) async {
  try {
    await _googleSignIn.signOut();
    final account = await _googleSignIn.signIn();
    final authentication = await account?.authentication;

    if (authentication != null) {
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );
      var authResult = await _auth.signInWithCredential(credential);

      if (authResult.user != null) {
        var user = authResult.user;

        UserService().createNewUser(user!.displayName, user.email, user.uid);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("userId", user.uid);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => IntroPage()));
      }
      // You can use the authentication.idToken and authentication.accessToken
      // to authenticate with your backend server or Firebase.
      print('User signed in with Google: ${account?.displayName}');
    } else {
      print('Sign in with Google canceled.');
    }
  } catch (error) {
    print('Error signing in with Google: $error');
  }
}

void _showToast(BuildContext context, String msg) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(msg),
    ),
  );
}

class LoginState extends StatelessWidget {
  bool isEnabled = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height - 80,
            margin: EdgeInsets.only(top: 60, bottom: 20),
            color: Colors.brown[400],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/login.png'),
                          fit: BoxFit.fitHeight),
                    )),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        border:
                            Border.all(color: Color.fromRGBO(38, 38, 38, 1)),
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        child: Row(
                          children: [
                            Image(
                              image: AssetImage('assets/images/google.png'),
                              width: 20,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                            ),
                            Text(
                              'Google ile devam et',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromRGBO(38, 38, 38, 1),
                                  fontFamily: 'SF Pro',
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            ),
                          ],
                        ),
                        onTap: () async => {await signInWithGoogle(context)},
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        color: Color.fromRGBO(38, 38, 38, 1),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Image(
                            image: AssetImage('assets/images/apple.png'),
                            width: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                          ),
                          Text(
                            'Apple ile devam et',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'SF Pro',
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                height: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
