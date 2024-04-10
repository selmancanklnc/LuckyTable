import 'package:flutter/material.dart';
import 'package:lucky_table/Screens/animated_login.dart';
import 'package:lucky_table/Screens/introScreens/introScreens/explanation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'botton_buttons.dart';

final List<ExplanationData> data = [
  ExplanationData(
      title: "Şanslı Mekan'a Hoşgeldin",
      localImageSrc: "assets/images/welcome.png",
      backgroundColor: Colors.white,
      tabs: [
        TabInfo(Icons.celebration_rounded,
            " Kullandıkça sürpriz hediyeler kazandıran fırsatlarla dolu uygulama."),
        TabInfo(Icons.exposure_plus_1_rounded,
            "Eğlenceli anların karşılığı puanlarla dolu. Kazandıkça keyfini katla.")
      ]),
  ExplanationData(
      title: "Şanslı Mekanı Bul",
      localImageSrc: "assets/images/info2.png",
      backgroundColor: Colors.white,
      tabs: [
        TabInfo(Icons.map_rounded, 'Çevrendeki şanslı mekanları keşfet.'),
        TabInfo(Icons.location_pin, 'Tek bir dokunuşla yol tarifini al.')
      ]),
  ExplanationData(
      title: "QR Tarat",
      localImageSrc: "assets/images/info1.png",
      backgroundColor: Colors.white,
      tabs: [
        TabInfo(Icons.qr_code_scanner_rounded,
            'QR kodu tarat ve çekiliş hakkı kazan.'),
        TabInfo(Icons.timer_rounded,
            'Her şanslı mekan için gündeF 1 kere tarama hakkın var.'),
      ]),
];

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> /*with ChangeNotifier*/ {
  final _controller = PageController();

  int _currentIndex = 0;

  // OpenPainter _painter = OpenPainter(3, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: data[_currentIndex].backgroundColor,
        child: SafeArea(
            child: Container(
          padding:
              const EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
          color: data[_currentIndex].backgroundColor,
          alignment: Alignment.center,
          child: Column(children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Image.asset('assets/images/AppLogo.png', width: 30),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("introCompleted", true);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePageX()));
                              },
                              child: Text(
                                'Atla',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 123, 255, 1),
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 23,
                                    letterSpacing: -1.223181962966919,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 12,
                      child: Container(
                          alignment: Alignment.center,
                          child: PageView(
                              scrollDirection: Axis.horizontal,
                              controller: _controller,
                              onPageChanged: (value) {
                                // _painter.changeIndex(value);
                                setState(() {
                                  _currentIndex = value;
                                });
                                // notifyListeners();
                              },
                              children: data
                                  .map((e) => ExplanationPage(data: e))
                                  .toList()))),
                  Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              // margin: const EdgeInsets.symmetric(vertical: 24),
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(data.length,
                                (index) => createCircle(index: index)),
                          )),
                          BottomButtons(
                            currentIndex: _currentIndex,
                            dataLength: data.length,
                            controller: _controller,
                          )
                        ],
                      ))
                ],
              ),
            )
          ]),
        )));
  }

  createCircle({required int index}) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(right: 4),
        height: 5,
        width: _currentIndex == index ? 15 : 5,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(3)));
  }
}
