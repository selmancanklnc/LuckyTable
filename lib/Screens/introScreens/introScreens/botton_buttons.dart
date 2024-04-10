import 'package:flutter/material.dart';
import 'package:lucky_table/Screens/animated_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomButtons extends StatelessWidget {
  final int currentIndex;
  final int dataLength;
  final PageController controller;

  const BottomButtons(
      {Key? key,
      required this.currentIndex,
      required this.dataLength,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: currentIndex == dataLength - 1
          ? [
              Expanded(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 70.0,
                    ),
                    child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool("introCompleted", true);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePageX()));
                        },
                        // color: Colors.white,
                        // height: MediaQuery.of(context).size.height * 0.1,
                        // materialTapTargetSize:
                        //     MaterialTapTargetSize.shrinkWrap, // add this
                        // shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(100),
                        //     side: BorderSide.none),
                        child: Container(
                            child: const Text(
                          "Başla",
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontFamily: 'SF Pro Text',
                              fontSize: 18,
                              letterSpacing: -1.223181962966919,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        )))),
              )
            ]
          : [
              currentIndex == 1
                  ? ElevatedButton(
                      onPressed: () {
                        controller.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut);
                      },
                      child: const Text(
                        "Geri",
                        style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            fontFamily: 'SF Pro Text',
                            fontSize: 18,
                            letterSpacing: -1.223181962966919,
                            fontWeight: FontWeight.normal,
                            height: 1),
                      ),
                    )
                  : Container(),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      controller.nextPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut);
                    },
                    child: const Text(
                      "İleri",
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontFamily: 'SF Pro Text',
                          fontSize: 18,
                          letterSpacing: -1.223181962966919,
                          fontWeight: FontWeight.normal,
                          height: 1),
                    ),
                  ),
                ],
              )
            ],
    );
  }
}
