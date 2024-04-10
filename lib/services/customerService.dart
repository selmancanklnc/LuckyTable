import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:lucky_table/models/customerModels.dart';
import 'package:lucky_table/models/staticClass.dart';

class CustomerService {
  Future<bool> getCafeUser(String? userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var user = await firestore
        .collectionGroup('cafeUsers')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    var documents = user.docs;
    if (documents.isNotEmpty) {
      try {
        var user = documents.map((document) {
          CafeUserListModel bookingList = CafeUserListModel.fromFirestore(
              Map<String, dynamic>.from(document.data()), document.reference);

          return bookingList;
        }).first;

        StaticClass.name = user.name;
        StaticClass.phone = user.phone;
        StaticClass.email = user.email;
        StaticClass.image = user.image;
        StaticClass.document = user.document;
        StaticClass.cafe = user.cafe;
        return true;
      } catch (e) {
        print("Exception $e");
        return false;
      }
    }
    return false;
  }
}
