import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucky_table/models/staticClass.dart';
import 'package:lucky_table/models/userModels.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class BarcodeList extends StatelessWidget {
  BarcodeList({super.key, this.userBarcodes, this.scrollController});
  ScrollController? scrollController;

  List<UserBarcodeListModel>? userBarcodes;
  DateFormat formatter = DateFormat('dd.MM.yyyy');
  bool isTablet = false;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var width = MediaQuery.of(context).devicePixelRatio;
    Size size = MediaQuery.of(context).size;
    double realSisze = screenWidth * width;
    isTablet = realSisze > 1500;
    return ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        itemCount: userBarcodes?.length,
        itemBuilder: (context, i) {
          var category = userBarcodes?[i];

          return InkWell(
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          child: QrImageView(
                            data:
                                "${StaticClass.document?.id}-${category.userVisit?.id}-${category.documentId}",
                            size: 200,
                            version: QrVersions.auto,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Kapat',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 64, 73, 83),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              padding: EdgeInsets.only(bottom: 0, left: 15, right: 15),
              margin: EdgeInsets.only(top: 10, left: 4, right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: category?.giftCompleted == true
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.greenAccent.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                // image: DecorationImage(
                //     image: image,
                //     fit: BoxFit.fitWidth)
              ),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                height: MediaQuery.of(context).size.height *
                    (isTablet ? 0.16 : 0.15),
                child: ClipPath(
                  clipper: DolDurmaClipper(right: 40, holeRadius: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: category?.giftCompleted == true
                          ? Colors.grey
                          : Colors.greenAccent,
                    ),
                    width: 300,
                    height: 95,
                    padding: EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category!.cafeName ?? "",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 64, 73, 83),
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      height: 1)),
                              Text("Masa: ${category!.tableName}",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 64, 73, 83),
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      height: 1)),
                              Text(
                                  "Tarih: ${formatter.format(DateTime.fromMillisecondsSinceEpoch(category.date!.millisecondsSinceEpoch)).toString()}",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 64, 73, 83),
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      height: 1)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.20,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    QrImageView(
                                      data:
                                          "${StaticClass.document?.id}-${category.userVisit?.id}-${category.documentId}",
                                      version: QrVersions.auto,
                                    ),
                                    Visibility(
                                      visible: category.giftCompleted == true,
                                      child: Container(
                                          margin: EdgeInsets.only(top: 10),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.check_rounded,
                                            color: Colors.greenAccent,
                                            size: isTablet ? 140 : 60,
                                          )),
                                    )
                                  ],
                                ),
                              ]),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class DolDurmaClipper extends CustomClipper<Path> {
  DolDurmaClipper({required this.right, required this.holeRadius});

  final double right;
  final double holeRadius;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - right - holeRadius, 0.0)
      ..arcToPoint(
        Offset(size.width - right, 0),
        clockwise: false,
        radius: Radius.circular(1),
      )
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - right, size.height)
      ..arcToPoint(
        Offset(size.width - right - holeRadius, size.height),
        clockwise: false,
        radius: Radius.circular(1),
      );

    path.lineTo(0.0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(DolDurmaClipper oldClipper) => true;
}
