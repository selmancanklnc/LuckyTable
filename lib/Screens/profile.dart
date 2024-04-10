import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:lucky_table/Screens/animated_login.dart';
import 'package:lucky_table/Screens/intro_page.dart';
import 'package:lucky_table/Screens/userBarcodes.dart';
import 'package:lucky_table/Widgets/barcodeList.dart';
import 'package:lucky_table/models/staticClass.dart';
import 'package:lucky_table/models/userModels.dart';
import 'package:lucky_table/services/userService.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ProfilePage> {
  Future<List<UserVisitListModel>?>? userVisits;
  List<UserBarcodeListModel>? userSuccessBarcodes = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool isFinished = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    userVisits = UserService().getUserVisits(StaticClass.document);
    getData();
  }

  Future<void> _postInit() async {
    _scrollController.animateTo(
      _scrollController.position.pixels + 50,
      duration: Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  Future getData() async {
    if (isFinished) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    var newList = await UserService().getUserSuccessBarcodes(lastDocument);
    if (lastDocument != null) {
      _postInit();
    }
    setState(() {
      newList?.forEach((data) {
        userSuccessBarcodes?.add(data);
      });
      if (newList != null) {
        lastDocument = newList.last.documentSnapshot;
        isFinished = newList.length < 6 ? true : false;
      } else {
        isFinished = true;
      }
      isLoading = false;
    });
  }

  Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  bool indActive = false;
  bool isTablet = false;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var width = MediaQuery.of(context).devicePixelRatio;
    Size size = MediaQuery.of(context).size;
    double realSisze = screenWidth * width;
       isTablet =  realSisze > 1500;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            bottom: const TabBar(
              unselectedLabelColor: Colors.white,
              labelColor: Colors.green,
              tabs: [
                Tab(icon: Icon(Icons.home_rounded), child: Text("Mekanlar")),
                Tab(
                    icon: Icon(Icons.sell_rounded),
                    child: Text("Kazandığım Çekilişler")),
              ],
            ),
            backgroundColor: Color.fromARGB(255, 64, 73, 83),
            leading: IconButton(
              color: Colors.white,
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
            ),
            centerTitle: true,
            title: Text(
              'Ziyaret Geçmişi',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: TabBarView(
            children: [
              FutureBuilder<List<UserVisitListModel>?>(
                  future: userVisits,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, i) {
                            var category = snapshot.data?[i];
                            late ImageProvider image;
                            if (category?.cafeImage != null) {
                              Uint8List brandBytes =
                                  base64.decode(category?.cafeImage ?? "");
                              image = Image.memory(brandBytes).image;
                            }
                            return InkWell(
                              onTap: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserBarcodePage(
                                            category!.document!,
                                            category.cafeName!)));
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    bottom: 0, left: 10, right: 5),
                                margin: EdgeInsets.only(
                                    top: 10, bottom: 0, right: 10, left: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(3),
                                    bottomLeft: Radius.circular(3),
                                    bottomRight: Radius.circular(25),
                                  ),
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.2),
                                      width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      // color: fromHex(category!.cafeColor!),
                                      color: Color.fromARGB(255, 64, 73, 83)
                                          .withOpacity(0.85),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.60,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(category?.cafeName ?? "",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Colors.greenAccent,
                                                    fontFamily: 'SF Pro Text',
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1)),
                                            Text(
                                                category?.cafeGiftActive == true
                                                    ? "Hediye Puan: ${category!.gift}/${category.cafeGiftCount}"
                                                    : "Puan sistemi yok",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'SF Pro Text',
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    height: 1)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.30,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              category?.cafeImage != null
                                                  ? Image(
                                                      image: image,
                                                      color: Colors.white,
                                                      fit: BoxFit.fill,
                                                      
                                                      width: isTablet ? null : 90,

                                                //       width: MediaQuery.of(context).size.width *
                                                // 0.15,
                                                    )
                                                  : Image.asset(
                                                      "assets/images/AppLogo3.png",
                                                      color: Colors.white,
                                                      fit: BoxFit.fitWidth,
                                                      width: 90,
                                                    )
                                            ]),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return Center(
                          child: Text(
                        "Ziyaret Geçmişi bulunmamaktadır.",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ));
                    } else {
                      return Center(
                          child: CircularProgressIndicator(
                        color: Colors.grey,
                      ));
                    }
                  }),
              userSuccessBarcodes!.isEmpty
                  ? Center(
                      child: Text(
                      "Kazandığım çekiliş bulunmamaktadır.",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ))
                  : LazyLoadScrollView(
                      isLoading: isLoading,
                      scrollDirection: Axis.vertical,
                      onEndOfPage: () => getData(),
                      child: Stack(
                        children: [
                          BarcodeList(
                            userBarcodes: userSuccessBarcodes,
                            scrollController: _scrollController,
                          ),
                          if (isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                              ),
                            )
                        ],
                      )),
            ],
          )),
    );
  }
}
