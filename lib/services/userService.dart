import 'dart:ffi'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lucky_table/models/staticClass.dart';
import 'package:lucky_table/models/userModels.dart';
import 'package:lucky_table/services/cafeService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  Future<void> createNewUser(
    String? name,
    String? email,
    String? userId,
  ) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

// Example of adding a document
    CollectionReference users = firestore.collection('users');
    QuerySnapshot user =
        await users.where('userId', isEqualTo: userId).limit(1).get();
    var token = await FirebaseMessaging.instance.getToken();

    if (user.docs.isEmpty) {
      await users.add(
          {'name': name, 'email': email, 'userId': userId, 'token': token});
      await getUser(userId);
    } else {
      user.docs[0].reference.update({'token': token});
      await getUser(userId);
    }
  }

  Future<void> updateUserImage(String? image, String? userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

// Example of adding a document
    try {
      CollectionReference users = firestore.collection('users');
      QuerySnapshot user =
          await users.where('userId', isEqualTo: userId).limit(1).get();
      if (user.docs.isEmpty == false) {
        await firestore
            .collection('users')
            .doc(user.docs.first.id)
            .update({'image': image});
      }
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<bool> getUser(String? userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var user = await firestore
        .collectionGroup('users')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    var documents = user.docs;
    if (documents.isNotEmpty) {
      try {
        var user = documents.map((document) {
          UserListModel bookingList = UserListModel.fromFirestore(
              Map<String, dynamic>.from(document.data()), document.reference);

          return bookingList;
        }).first;

        StaticClass.name = user.name;
        StaticClass.phone = user.phone;
        StaticClass.email = user.email;
        StaticClass.image = user.image;
        StaticClass.document = user.document;
        await FirebaseMessaging.instance.subscribeToTopic("all_users");
        return true;
      } catch (e) {
        print("Exception $e");
        return false;
      }
    }
    return false;
  }

  Future<int> getUserCafeGiftCount(
      DocumentReference? cafe, DocumentReference? user) async {
    // Example of adding a document
    CollectionReference users = user!.collection('userVisits');
    QuerySnapshot userVisit =
        await users.where('cafe', isEqualTo: cafe).limit(1).get();
    if (userVisit.docs.isEmpty) {
      return 0;
    }
    var doc = userVisit.docs[0];
    return doc["gift"];
  }

  Future<List<UserBarcodeListModel>?> getUserBarcodes(
      DocumentReference? userVisit, DocumentSnapshot? lastDocument) async {
    Query<Map<String, dynamic>> query =
        userVisit!.collection('userBarcodes').orderBy('date', descending: true);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    var barcodes = await query.limit(6).get();
    var documents = barcodes.docs;
    if (documents.isNotEmpty) {
      try {
        List<UserBarcodeListModel> userBarcodes = [];

        for (var document in documents) {
          UserBarcodeListModel bookingList = UserBarcodeListModel.fromFirestore(
              Map<String, dynamic>.from(document.data()),
              document.reference,
              document);
          var cafe = await CafeService().getCafe(bookingList.cafe);
          if (cafe == null || cafe.isActive == false) {
            continue;
          }
          var table = await CafeService().getTable(bookingList.table);
          if (table != null) {
            bookingList.tableName = table.name;
          }

          bookingList.cafeName = cafe.name;
          bookingList.cafeGiftActive = cafe.giftActive;
          bookingList.cafeGiftCount = cafe.giftCount;

          userBarcodes.add(bookingList);
        }
        return userBarcodes;
      } catch (e) {
        print("Exception $e");
        return [];
      }
    }
    return null;
  }

  Future<List<UserBarcodeListModel>?> getUserSuccessBarcodes(
      DocumentSnapshot? lastDocument) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Query<Map<String, dynamic>> query =
        firestore.collectionGroup('userBarcodes');
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    var barcodes = await query
        .where('giftSuccess', isEqualTo: true)
        .where('user', isEqualTo: StaticClass.document)
        .orderBy('date', descending: true)
        .limit(6)
        .get();
    var documents = barcodes.docs;
    if (documents.isNotEmpty) {
      try {
        List<UserBarcodeListModel> userBarcodes = [];

        for (var document in documents) {
          UserBarcodeListModel bookingList = UserBarcodeListModel.fromFirestore(
              Map<String, dynamic>.from(document.data()),
              document.reference,
              document);
          var cafe = await CafeService().getCafe(bookingList.cafe);
          if (cafe == null || cafe.isActive == false) {
            continue;
          }
          var table = await CafeService().getTable(bookingList.table);
          if (table != null) {
            bookingList.tableName = table.name;
          }

          bookingList.cafeName = cafe.name;
          bookingList.cafeGiftActive = cafe.giftActive;
          bookingList.cafeGiftCount = cafe.giftCount;

          userBarcodes.add(bookingList);
        }
        return userBarcodes;
      } catch (e) {
        print("Exception $e");
        return [];
      }
    }
    return null;
  }

  Future<List<UserVisitListModel>?> getUserVisits(
      DocumentReference? user) async {
    Query<Map<String, dynamic>> query = user!.collection('userVisits');

    var barcodes = await query.orderBy('lastVisitDate', descending: true).get();
    var documents = barcodes.docs;
    if (documents.isNotEmpty) {
      try {
        List<UserVisitListModel> userBarcodes = [];

        for (var document in documents) {
          UserVisitListModel bookingList = UserVisitListModel.fromFirestore(
              Map<String, dynamic>.from(document.data()),
              document.reference,
              document);

          var cafe = await CafeService().getCafe(bookingList.cafe);
          if (cafe == null || cafe.isActive == false) {
            continue;
          }
          bookingList.cafeName = cafe.name;
          bookingList.cafeGiftActive = cafe.giftActive;
          bookingList.cafeGiftCount = cafe.giftCount;
          bookingList.cafeImage = cafe.image;
          bookingList.cafeColor = cafe.color;

          userBarcodes.add(bookingList);
        }
        return userBarcodes;
      } catch (e) {
        print("Exception $e");
        return [];
      }
    }
    return null;
  }

  Future<UserBarcodeListModel?> getUserBarcode(String? barcode) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var ids = barcode!.split('-');
    var document = await firestore
        .collection('users')
        .doc(ids[0])
        .collection('userVisits')
        .doc(ids[1])
        .collection('userBarcodes')
        .doc(ids[2])
        .get();

    if (document.exists) {
      try {
        UserBarcodeListModel bookingList = UserBarcodeListModel.fromFirestore(
            Map<String, dynamic>.from(document.data() as Map<dynamic, dynamic>),
            document.reference,
            document);
        var cafe = await CafeService().getCafe(bookingList.cafe);

        if (cafe != null) {
          bookingList.cafeName = cafe.name;
          bookingList.cafeGiftActive = cafe.giftActive;
          bookingList.cafeGiftCount = cafe.giftCount;
          var userGiftCount = await getUserCafeGiftCount(
              cafe.document, document.reference.parent.parent?.parent.parent);
          bookingList.userGiftCount = userGiftCount;
          bookingList.user = document.reference.parent.parent?.parent.parent;
        }

        return bookingList;
      } catch (e) {
        print("Exception $e");
        return null;
      }
    }
    return null;
  }

  void createUserNotification(
      String title, String body, String? userId, DateTime? date) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

// Example of adding a document
    CollectionReference users = firestore.collection('userNotifications');
    users.add({'title': title, 'body': body, 'userId': userId, 'date': date});
  }

  Future<List<NotificationListModel>> getNotifications() async {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    Query<Map<String, dynamic>> query =
        fireStore.collection("userNotifications");
    query = query
        .where("userId", isEqualTo: userId)
        .orderBy('date', descending: true);
    var val = await query.get();
    var documents = val.docs;
    if (documents.isNotEmpty) {
      try {
        return documents.map((document) {
          NotificationListModel bookingList =
              NotificationListModel.fromFirestore(
                  Map<String, dynamic>.from(document.data()),
                  document.reference);

          return bookingList;
        }).toList();
      } catch (e) {
        print("Exception $e");
        return [];
      }
    }
    return [];
  }
}
