import 'dart:async';
import 'dart:ffi';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucky_table/Screens/customer.dart';
import 'package:lucky_table/Screens/introScreens/introScreens/intro.dart';
import 'package:lucky_table/Screens/intro_page.dart';
import 'package:lucky_table/Screens/noInternet.dart';
import 'package:lucky_table/firebase_options.dart';
import 'package:lucky_table/services/customerService.dart';
import 'package:lucky_table/services/userService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/animated_login.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:connectivity/connectivity.dart';
import 'package:permission_handler/permission_handler.dart';

late String? userId;
late bool? isCafe;
late bool? introCompleted;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  if (await Permission.notification.request().isGranted) {
    //notifications permission is granted do some stuff
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  userId = prefs.getString("userId");
  isCafe = prefs.getBool("isCafe");
  introCompleted = prefs.getBool("introCompleted");

  if (isCafe == null) {
    isCafe = false;
  }
  if (isCafe == false) {
    if (userId != null) {
      var result = await UserService().getUser(userId);
      if (result == false) {
        userId = "";
        prefs.setString("userId", userId!);
      }
    }
  } else {
    if (userId != null) {
      var result = await CustomerService().getCafeUser(userId);
      if (result == false) {
        userId = "";
        prefs.setString("userId", userId!);
      }
    }
  }

  runApp(MaterialApp(
      home: InternetCheck(),
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      title: 'Şanslı Mekan',
      theme: ThemeData(
        colorScheme: ColorScheme.dark()
            .copyWith(primary: Colors.white, onPrimaryContainer: Colors.white),
        useMaterial3: true,
        scaffoldBackgroundColor: Color.fromARGB(255, 45, 51, 58),
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 45, 51, 58),
          elevation: 1,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          displaySmall: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineSmall: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.black,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      )));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call initializeApp before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the AndroidManifest.xml file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

Future<void> showFlutterNotification(RemoteMessage message) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    var userId = prefs.getString("userId");

    if (userId != null) {
      UserService().createUserNotification(
          notification.title!, notification.body!, userId, message.sentTime);
    }

    // flutterLocalNotificationsPlugin.show(
    //   notification.hashCode,
    //   notification.title,
    //   notification.body,
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       channel.id,
    //       channel.name,
    //       channelDescription: channel.description,
    //       // TODO add a proper drawable resource to android, for now using
    //       //      one that already exists in example app.
    //       icon: 'launch_background',
    //     ),
    //   ),
    // );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Timer _everySecond;
  String? _token;
  String? initialMessage;
  bool _resolved = false;
  late Timer _splashTimer;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        // Internet bağlandığında ana sayfaya yönlendir
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => InternetCheck()));
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
              _resolved = true;
              initialMessage = value?.data.toString();
            },
          ),
        );

    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });

    _splashTimer = Timer(Duration(seconds: 2), () {
      if (introCompleted != true) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => InfoPage()));
      } else {
        if (userId == null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePageX()));
        } else {
          if (isCafe == true) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CustomerPage()));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => IntroPage()));
          }
        }
      }
      // Timer süresi dolunca ana sayfaya geç
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Özel splash ekran tasarımı burada oluşturulur
        child: Image.asset(
            'assets/images/appstore.jpg', // Kullanmak istediğiniz splash ekran resmi
            width: MediaQuery.of(context).size.width * 0.8),
      ),
    );
  }
}
