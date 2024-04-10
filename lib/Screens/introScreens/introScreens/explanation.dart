import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ExplanationData {
  final String title;
  final String localImageSrc;
  final Color backgroundColor;
  final List<TabInfo> tabs;
  ExplanationData(
      {required this.title,
      required this.tabs,
      required this.localImageSrc,
      required this.backgroundColor});
}

class ExplanationPage extends StatelessWidget {
  final ExplanationData data;
  ExplanationPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<Widget> tabInfoItems = [
      for (final tab in data.tabs)
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(tab.icon, color: Colors.green),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  tab.description,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        )
    ];
    tabInfoItems = tabInfoItems
        .animate(interval: 600.ms)
        .fadeIn(duration: 900.ms, delay: 300.ms)
        .shimmer(
            blendMode: BlendMode.srcOver,
            color: Color.fromARGB(31, 109, 109, 109))
        .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);

    return Column(
      children: [
        Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(data.localImageSrc), fit: BoxFit.fitHeight),
            )),
        Container(
          decoration: const BoxDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'SF Pro',
                    fontSize: 29,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ).animate().fade().scale(),
              const SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  children: tabInfoItems,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class TabInfo {
  const TabInfo(this.icon, this.description);

  final IconData icon;
  final String description;
}
