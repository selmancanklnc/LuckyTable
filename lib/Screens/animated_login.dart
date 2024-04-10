import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucky_table/Screens/customer.dart';
import 'package:lucky_table/Screens/intro_page.dart';
import 'package:lucky_table/main.dart';
import 'package:lucky_table/models/staticClass.dart';
import 'package:lucky_table/services/customerService.dart';
import 'package:lucky_table/services/userService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
FirebaseAuth _auth = FirebaseAuth.instance;
late BuildContext dialogContext;

Future<void> signInWithFacebook(BuildContext context) async {
  try {
    _auth.signOut();

    await FirebaseAuth.instance.setLanguageCode("TR");

    final LoginResult loginResult = await FacebookAuth.instance.login();
    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    var authResult = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);
    if (authResult.user != null) {
      var user = authResult.user;

      UserService().createNewUser(user!.displayName, user.email, user.uid);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", user.uid);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => IntroPage()));
      print('Giriş Baaşarılı');
      Fluttertoast.showToast(msg: 'Facebook Hesabı ile Giriş Yapıldı');
    }
    // You can use the authentication.idToken and authentication.accessToken
    // to authenticate with your backend server or Firebase.

    else {
      print('Sign in with Facebook canceled.');
      Fluttertoast.showToast(msg: 'Facebook ile Giriş İptal Edildi');

      Navigator.pop(dialogContext);
    }
  } catch (error) {
    String errorMessage = "";

    // Firebase ve Facebook hata kodlarını kontrol ederek kendi mesajlarınızı oluşturun
    if (error is FirebaseAuthException) {
      if (error.code == 'account-exists-with-different-credential') {
        errorMessage = 'Bu hesap zaten farklı bir yöntemle kayıtlı.';
        // veya istediğiniz bir işlemi gerçekleştirin
      } else if (error.code == 'invalid-credential') {
        errorMessage = 'Geçersiz kimlik bilgileri. Lütfen tekrar deneyin.';
        // veya istediğiniz bir işlemi gerçekleştirin
      } else {
        errorMessage = 'Facebook ile Giriş İptal Edildi';
        // veya istediğiniz bir işlemi gerçekleştirin
      }
    } else {
      errorMessage = 'Facebook ile Giriş İptal Edildi';
      // veya istediğiniz bir işlemi gerçekleştirin
    }

    print('Error signing in with Facebook: $error');
    Fluttertoast.showToast(msg: 'Giriş Başarısız: $errorMessage');

    Navigator.pop(dialogContext);
  }
}

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
      Fluttertoast.showToast(msg: 'Google Hesabı ile Giriş Yapıldı');
    } else {
      print('Sign in with Google canceled.');
      Fluttertoast.showToast(msg: 'Google ile Giriş İptal Edildi');

      Navigator.pop(dialogContext);
    }
  } catch (error) {
    String errorMessage = "";

    // Firebase ve Facebook hata kodlarını kontrol ederek kendi mesajlarınızı oluşturun
    if (error is FirebaseAuthException) {
      if (error.code == 'account-exists-with-different-credential') {
        errorMessage = 'Bu hesap zaten farklı bir yöntemle kayıtlı.';
        // veya istediğiniz bir işlemi gerçekleştirin
      } else if (error.code == 'invalid-credential') {
        errorMessage = 'Geçersiz kimlik bilgileri. Lütfen tekrar deneyin.';
        // veya istediğiniz bir işlemi gerçekleştirin
      } else {
        errorMessage = 'Google ile Giriş İptal Edildi';
        // veya istediğiniz bir işlemi gerçekleştirin
      }
    } else {
      errorMessage = 'Google ile Giriş İptal Edildi';
      // veya istediğiniz bir işlemi gerçekleştirin
    }

    print('Error signing in with Google: $error');
    Fluttertoast.showToast(msg: 'Giriş Başarısız: $errorMessage');

    Navigator.pop(dialogContext);
  }
}

Future<void> signInWithApple(BuildContext context) async {
  try {
    _auth.signOut();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    if (credential.identityToken != null) {
      var pr = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      var authResult = await _auth.signInWithCredential(pr);
      if (authResult.user != null) {
        var user = authResult.user;

        UserService().createNewUser(user!.displayName, user!.email, user!.uid);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Fluttertoast.showToast(msg: 'Apple Hesabı ile Giriş Yapıldı');
        Navigator.pop(dialogContext);

        prefs.setString("userId", user.uid);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => IntroPage()));
      }
    } else {
      Fluttertoast.showToast(msg: 'Apple ile Giriş İptal Edildi');
      Navigator.pop(dialogContext);
    }
  } catch (error) {
    String errorMessage = "";

    // Firebase ve Facebook hata kodlarını kontrol ederek kendi mesajlarınızı oluşturun
    if (error is FirebaseAuthException) {
      if (error.code == 'account-exists-with-different-credential') {
        errorMessage = 'Bu hesap zaten farklı bir yöntemle kayıtlı.';
        // veya istediğiniz bir işlemi gerçekleştirin
      } else if (error.code == 'invalid-credential') {
        errorMessage = 'Geçersiz kimlik bilgileri. Lütfen tekrar deneyin.';
        // veya istediğiniz bir işlemi gerçekleştirin
      } else {
        errorMessage = 'Apple ile Giriş İptal Edildi';
        // veya istediğiniz bir işlemi gerçekleştirin
      }
    } else {
      errorMessage = 'Apple ile Giriş İptal Edildi';
      // veya istediğiniz bir işlemi gerçekleştirin
    }

    print('Error signing in with Apple: $error');
    Fluttertoast.showToast(msg: 'Giriş Başarısız: $errorMessage');

    Navigator.pop(dialogContext);
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

class HomePageX extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageX> with TickerProviderStateMixin {
  late AnimationController controller1;
  late AnimationController controller2;
  late Animation<double> animation1;
  late Animation<double> animation2;
  late Animation<double> animation3;
  late Animation<double> animation4;
  bool isFirstContainerVisible = true;
  bool isSecondContainerVisible = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  

  @override
  void initState() {
    super.initState();

    controller1 = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 5,
      ),
    );
    animation1 = Tween<double>(begin: .1, end: .15).animate(
      CurvedAnimation(
        parent: controller1,
        curve: Curves.easeInOut,
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller1.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller1.forward();
        }
      });
    animation2 = Tween<double>(begin: .02, end: .08).animate(
      CurvedAnimation(
        parent: controller1,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    controller2 = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 5,
      ),
    );
    animation3 = Tween<double>(begin: .41, end: .35).animate(CurvedAnimation(
      parent: controller2,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller2.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller2.forward();
        }
      });
    animation4 = Tween<double>(begin: 170, end: 190).animate(
      CurvedAnimation(
        parent: controller2,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });
    if (controller1.isDismissed == false) {
      Timer(Duration(milliseconds: 2500), () {
        controller1.forward();
      });
    }

    controller2.forward();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }
  bool isTablet = false;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var width = MediaQuery.of(context).devicePixelRatio;
    Size size = MediaQuery.of(context).size;
    double realSisze = screenWidth * width;
       isTablet =  realSisze > 1500;

    late BuildContext popContext;
    return WillPopScope(
      onWillPop: () async {
        await SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xff192028),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Stack(
                children: [
                  Positioned(
                    top: size.height * (animation2.value + .58),
                    left: size.width * .21,
                    child: CustomPaint(
                      painter: MyPainter(50),
                    ),
                  ),
                  Positioned(
                    top: size.height * .98,
                    left: size.width * .1,
                    child: CustomPaint(
                      painter: MyPainter(animation4.value - 30),
                    ),
                  ),
                  Positioned(
                    top: size.height * .5,
                    left: size.width * (animation2.value + .8),
                    child: CustomPaint(
                      painter: MyPainter(30),
                    ),
                  ),
                  Positioned(
                    top: size.height * animation3.value,
                    left: size.width * (animation1.value + .1),
                    child: CustomPaint(
                      painter: MyPainter(60),
                    ),
                  ),
                  Positioned(
                    top: size.height * .1,
                    left: size.width * .8,
                    child: CustomPaint(
                      painter: MyPainter(animation4.value),
                    ),
                  ),
                  Visibility(
                    visible: isFirstContainerVisible,
                    child: Container(
                      padding: EdgeInsets.only(
                          right: size.height * .03, top: size.height * .05),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaY: 25, sigmaX: 25),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        isSecondContainerVisible = true;
                                        isFirstContainerVisible = false;
                                      });
                                    },
                                    child: Icon(
                                      Icons.local_cafe,
                                      size: 30,
                                    ),
                                  ),
                                ))),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: size.height * .17),
                          child: Container(
                            width: MediaQuery.of(context).size.width * (isTablet == true ? 0.50 : 0.70),
                            child: const Image(
                              image: AssetImage("assets/images/AppLogo3.png"),
                              fit: BoxFit.fitWidth,
                              color: Colors.white,
                              opacity: AlwaysStoppedAnimation(.85),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isFirstContainerVisible,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaY: 25, sigmaX: 25),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                width: size.width * .9,
                                padding: EdgeInsets.only(
                                    top: size.width * .1,
                                    bottom: size.width * .1),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Image(
                                        image: AssetImage(
                                            "assets/images/profile.png"),
                                        width: 150,
                                        opacity: AlwaysStoppedAnimation(0.4),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Visibility(
                                      visible: Platform.isIOS,
                                      child: Column(
                                        children: [
                                          component2('Apple ile Giriş Yap', 1.4,
                                              () async {showDialog(
                                        context: context,
                                        builder: (context) {
                                          dialogContext = context;
                                          return Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.grey,
                                          ));
                                        },
                                      );

                                      HapticFeedback.lightImpact();
                                      await signInWithApple(context);
                                      Navigator.of(context).pop;
                                          },
                                              Image(
                                                image: AssetImage(
                                                    'assets/images/apple2.png'),
                                                color: Colors.white
                                                    .withOpacity(.8),
                                                width: 20,
                                              )),
                                          SizedBox(
                                            height: 25,
                                          ),
                                        ],
                                      ),
                                    ),
                                    component2('Google ile Giriş Yap', 1.4,
                                        () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          dialogContext = context;
                                          return Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.grey,
                                          ));
                                        },
                                      );

                                      HapticFeedback.lightImpact();
                                      await signInWithGoogle(context);
                                      Navigator.of(context).pop;
                                    },
                                        Image(
                                          image: AssetImage(
                                              'assets/images/google2.png'),
                                          color: Colors.white.withOpacity(.8),
                                          width: 20,
                                        )),
                                    SizedBox(
                                      height: 25,
                                    ),

                                    component2('Facebook ile Giriş Yap', 1.4,
                                        () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          dialogContext = context;
                                          return Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.grey,
                                          ));
                                        },
                                      );

                                      HapticFeedback.lightImpact();
                                      await signInWithFacebook(context);
                                      Navigator.of(context).pop;
                                    },
                                        Image(
                                          image: AssetImage(
                                              'assets/images/facebook.png'),
                                          color: Colors.white.withOpacity(.8),
                                          width: 20,
                                        )),
                                    // component2('İşletme Girişi', 1.4, () async {
                                    //   setState(() {
                                    //     isSecondContainerVisible = true;
                                    //     isFirstContainerVisible = false;
                                    //   });
                                    // },
                                    //     Image(
                                    //       image: AssetImage(
                                    //           'assets/images/cafe_icon.png'),
                                    //       color: Colors.white.withOpacity(.8),
                                    //       width: 20,
                                    //     )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isSecondContainerVisible,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaY: 25, sigmaX: 25),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                width: size.width * .9,
                                padding: EdgeInsets.only(
                                    top: size.width * .05,
                                    bottom: size.width * .05),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 20,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.cancel,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isSecondContainerVisible = false;
                                            isFirstContainerVisible = true;
                                          });
                                        },
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Center(
                                          child: Image(
                                            image: AssetImage(
                                                "assets/images/business.png"),
                                            width: 130,
                                            opacity:
                                                AlwaysStoppedAnimation(0.4),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Center(
                                          child: Text(
                                            "İşletme Girişi",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        component3(
                                          2.5,
                                          () {
                                            print('Tapped!');
                                          },
                                          Icon(
                                            Icons.person,
                                            size: 32.0,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                          'Kullanıcı Adı',
                                          false,
                                        ),
                                        SizedBox(height: 30),
                                        component3(
                                          2.5,
                                          () {
                                            print('Tapped!');
                                          },
                                          Icon(
                                            Icons.lock,
                                            size: 32.0,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                          'Şifre',
                                          true,
                                        ),
                                        SizedBox(height: 30),
                                        ElevatedButton(
                                          onPressed: () async {
                                            popContext=context;
                                            // Show CircularProgressIndicator while processing
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                popContext = context;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                            );
                                            String errorMessage = '';
                                            try {
                                              var result = await _auth
                                                  .signInWithEmailAndPassword(
                                                      email: usernameController
                                                          .text
                                                          .trim(),
                                                      password:
                                                          passwordController
                                                              .text);
                                              Navigator.of(popContext,
                                                      rootNavigator: true)
                                                  .pop();
                                              final user = result.user;
                                              if (user != null) {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                var result =
                                                    await CustomerService()
                                                        .getCafeUser(user.uid);
                                                if (result == false) {
                                                  errorMessage =
                                                      "Geçersiz Kullanıcı";
                                                } else {
                                                  prefs.setString(
                                                      "userId", user.uid);
                                                  prefs.setBool("isCafe", true);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CustomerPage(),
                                                    ),
                                                  );
                                                }
                                              }
                                              // Dismiss the CircularProgressIndicator
                                            } on FirebaseAuthException catch (e) {
                                              Navigator.of(popContext,
                                                      rootNavigator: true)
                                                  .pop();
                                              switch (e.code) {
                                                case 'user-not-found':
                                                  errorMessage =
                                                      'Kullanıcı bulunamadı';
                                                  break;
                                                case 'invalid-credential':
                                                  errorMessage =
                                                      'Kullanıcı adı veya şifre geçersiz';
                                                  break;
                                                default:
                                                  errorMessage =
                                                      'Giriş başarısız.';
                                              }
                                            }

                                            if (errorMessage != '') {
                                              // ignore: use_build_context_synchronously
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 64, 73, 83),
                                                    title: Text('Hata',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 11,
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    2)),
                                                    content: Text(errorMessage,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                letterSpacing:
                                                                    1)),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Tamam',
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    2)),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Color.fromARGB(255, 64, 73, 83)
                                                    .withOpacity(0.4),
                                            onPrimary: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                            ),
                                            padding: EdgeInsets.all(10.0),
                                          ),
                                          child: Container(
                                            height: 30,
                                            width: 240,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 10.0,
                                                  ),
                                                  child: const Icon(
                                                    Icons.login,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 30.0),
                                                      child: Text(
                                                        'Giriş Yap',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget component1(
      IconData icon, String hintText, bool isPassword, bool isEmail) {
    Size size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaY: 15,
          sigmaX: 15,
        ),
        child: Container(
          height: size.width / 8,
          width: size.width / 1.2,
          alignment: Alignment.center,
          padding: EdgeInsets.only(right: size.width / 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            style: TextStyle(color: Colors.white.withOpacity(.8)),
            cursorColor: Colors.white,
            obscureText: isPassword,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.white.withOpacity(.7),
              ),
              border: InputBorder.none,
              hintMaxLines: 1,
              hintText: hintText,
              hintStyle:
                  TextStyle(fontSize: 14, color: Colors.white.withOpacity(.5)),
            ),
          ),
        ),
      ),
    );
  }

  Widget component2(
      String string, double width, VoidCallback voidCallback, Image image) {
     Size size = MediaQuery.of(context).size;
    

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: voidCallback,
          child: Container(
            height: isTablet ?  size.width / 12 : size.width / 8,
            width: size.width / width,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                image,
                SizedBox(
                  width: 25,
                ),
                Text(
                  string,
                  style: TextStyle(color: Colors.white.withOpacity(.8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customTextField(String hintText, bool isPassword) {
    return TextFormField(
      validator: (value) {
        if (value == null || value == "" || value.isEmpty) {
          return 'Kullanıcı adı ve şifre boş bırakılamaz';
        }
        return null;
      },
      obscureText: isPassword,
      controller: isPassword ? passwordController : usernameController,
      style: TextStyle(color: Colors.white.withOpacity(.8), fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(.5)),
        border: InputBorder.none,
      ),
    );
  }

  Widget component3(
    double width,
    VoidCallback voidCallback,
    Icon icon,
    String hintText,
    bool isPassword,
  ) {
    Size size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: voidCallback,
          child: Container(
            height: 60,
            width: 270,
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                icon,
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: customTextField(hintText, isPassword),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final double radius;

  MyPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
              colors: [Color(0xffFD5E3D), Color(0xffC43990)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(Rect.fromCircle(
        center: Offset(0, 0),
        radius: radius,
      ));

    canvas.drawCircle(Offset.zero, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
