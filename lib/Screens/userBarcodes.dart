import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:lucky_table/Screens/animated_login.dart';
import 'package:lucky_table/Screens/intro_page.dart';
import 'package:lucky_table/Widgets/barcodeList.dart';
import 'package:lucky_table/models/staticClass.dart';
import 'package:lucky_table/models/userModels.dart';
import 'package:lucky_table/services/userService.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class UserBarcodePage extends StatefulWidget {
  UserBarcodePage(this.userVisit, this.cafeName);

  DocumentReference userVisit;
  String cafeName;
  @override
  _MyHomePageState createState() => _MyHomePageState(userVisit, cafeName);
}

class _MyHomePageState extends State<UserBarcodePage> {
  List<UserBarcodeListModel>? userVisits = [];
  final ScrollController _scrollController = ScrollController();

  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool isFinished = false;
  _MyHomePageState(this.userVisit, this.cafeName);
  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> _postInit() async {
    if (_scrollController.positions.isNotEmpty) {
      _scrollController.animateTo(
        _scrollController.position.pixels + 50,
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
  }

  Future getData() async {
    if (isFinished) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    var newList = await UserService().getUserBarcodes(userVisit, lastDocument);
    if (lastDocument != null) {
      _postInit();
    }
    setState(() {
      newList?.forEach((data) {
        userVisits?.add(data);
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

  DocumentReference userVisit;
  String cafeName;
  bool indActive = false;
  DateFormat formatter = DateFormat('dd.MM.yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
          cafeName,
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: userVisits == null
          ? (isLoading == true
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                )
              : Center(
                  child: Text(
                  "Kazandığım çekiliş bulunmamaktadır.",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                )))
          : LazyLoadScrollView(
              isLoading: isLoading,
              scrollDirection: Axis.vertical,
              onEndOfPage: () => getData(),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Stack(
                  children: [
                    BarcodeList(
                      userBarcodes: userVisits,
                      scrollController: _scrollController,
                    ),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                        ),
                      )
                  ],
                ),
              )),
    );
  }
}
