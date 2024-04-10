import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucky_table/models/cafeModels.dart';
import 'package:lucky_table/models/staticClass.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:http/http.dart' as http;
import 'package:lucky_table/models/userModels.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

class CafeService {
  // Distance Matrix API'yi kullanarak mesafe bilgisini çeken fonksiyon

  Future<CafeListModel?> getCafe(DocumentReference? doc) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var user = await firestore.collection('cafes').doc(doc?.id).get();
    var document = user;
    if (document.exists) {
      try {
        CafeListModel bookingList = CafeListModel.fromFirestore(
            Map<String, dynamic>.from(document.data() as Map<dynamic, dynamic>),
            document.reference,
            document);
        return bookingList;
      } catch (e) {
        print("Exception $e");

        return null;
      }
    }
  }

  Future<List<CafeListModel>?> getCafes(double? lat, double? lot) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var user = firestore.collection('cafes').where('isActive', isEqualTo: true);

    final geo = GeoFlutterFire();
    GeoFirePoint center = geo.point(latitude: lat!, longitude: lot!);

    double radius = 100;
    String field = 'position';

    var stream = await geo
        .collection(collectionRef: user)
        .within(
          center: center,
          radius: radius,
          field: field,
          strictMode: true,
        )
        .first;
    if (stream.isEmpty == false) {
      try {
        var table = stream.map((document) {
          var data = document.data() as Map<dynamic, dynamic>;
          CafeListModel bookingList = CafeListModel.fromFirestore(
              Map<String, dynamic>.from(
                  document.data() as Map<dynamic, dynamic>),
              document.reference,
              document);
          var latitude = data["position"]['geopoint'].latitude;

          var longitude = data['position']['geopoint'].longitude;

          final cityLondon = LatLng(lat, lot);
          final cityParis = LatLng(latitude, longitude);

          final distance =
              SphericalUtil.computeDistanceBetween(cityLondon, cityParis) /
                  1000.0;
          bookingList.distance = distance;
          bookingList.lat = latitude;
          bookingList.lon = longitude;
          return bookingList;
        }).toList();
        return table;
      } catch (e) {
        print("Exception $e");
        return null;
      }
    }
    return null;
  }

  Future<TableListModel?> getTable(DocumentReference? doc) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var user = await firestore.collection('tables').doc(doc?.id).get();
    var document = user;
    if (document.exists) {
      try {
        TableListModel bookingList = TableListModel.fromFirestore(
            Map<String, dynamic>.from(document.data() as Map<dynamic, dynamic>),
            document.reference);
        return bookingList;
      } catch (e) {
        print("Exception $e");

        return null;
      }
    }
  }

  Future<TableListModel?> getTableWithBarcode(String? barcode) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var user = await firestore
        .collection('tables')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    var documents = user.docs;
    if (documents.isNotEmpty) {
      try {
        var table = documents.map((document) {
          TableListModel bookingList = TableListModel.fromFirestore(
              Map<String, dynamic>.from(document.data()), document.reference);

          return bookingList;
        }).first;
        return table;
      } catch (e) {
        print("Exception $e");
        return null;
      }
    }
  }
 bool pointInCircle(LatLng point, int radius, LatLng center) {
    return (SphericalUtil.computeDistanceBetween(point, center) <= radius);
  }
  Future<ResultModel> createUserBarcode2(DocumentReference? table,
      DocumentReference? cafe, DocumentReference? user,LatLng location) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var model = new ResultModel();
    WriteBatch batch = firestore.batch();

    var cafeModel = await CafeService().getCafe(cafe);
    if (cafeModel == null) {
      model.Result = false;
      model.Message = "Bu mekan sistemde bulunamadı.";
      return model;
    }
    if (cafeModel.isActive == false) {
      model.Result = false;
      model.Message = "Bu mekan artık aktif değil.";
      return model;
    }
    //Kullanıcının kafeye olan mesafesini kontrol eder.  100 olacak!!!! 
    var isInArea=pointInCircle(LatLng(location.latitude, location.longitude), 100, LatLng(cafeModel.position!.geoPoint!.latitude!, cafeModel.position!.geoPoint!.longitude!));
   if (isInArea == false) {
      model.Result = false;
      model.Message = "Konum dışındasınız";
      return model;
    }
// Example of adding a document
    CollectionReference userVisits =
        firestore.collection('users/' + user!.id + '/userVisits');
    DocumentReference reference;
    QuerySnapshot userVisit =
        await userVisits.where('cafe', isEqualTo: cafe).limit(1).get();
    if (userVisit.docs.isEmpty == false && cafeModel?.giftActive == true) {
      var userGiftModel = userVisit.docs[0];
      reference = userGiftModel.reference;
      int gift = userGiftModel["gift"];
      gift++;
      batch.update(reference, {'gift': gift, 'lastVisitDate': DateTime.now()});
    } else {
      var giftCount = cafeModel?.giftActive == true ? 1 : 0;

      reference = userVisits.doc();
      batch.set(reference,
          {'gift': giftCount, 'cafe': cafe, 'lastVisitDate': DateTime.now()});
      // reference = await userVisits.add({'gift': giftCount, 'cafe': cafe});
    }

    Timestamp yesterday =
        Timestamp.fromDate(DateTime.now().add(const Duration(days: -1)));
    CollectionReference userTableDate = reference.collection('userBarcodes');
    QuerySnapshot userBarcode = await userTableDate
        .where('cafe', isEqualTo: cafe)
        .orderBy('date', descending: true)
        .limit(1)
        .get();
    if (userBarcode.docs.isEmpty == false) {
      var userTableDateModel = userBarcode.docs[0];
      Timestamp date = userTableDateModel["date"];
      if (date.compareTo(yesterday) > 0) {
        model.Result = false;
        model.Message = "Bu mekan için günlük tarama hakkınız bitmiştir.";
        return model;
      }
    }
    var userTableDateRef = userTableDate.doc();

    batch.set(userTableDateRef,
        {'table': table, 'user': user, 'cafe': cafe, 'date': DateTime.now()});

    batch.commit();
    model.ResultId = userTableDateRef.id;
    model.Result = true;
    return model;
  }

  Future<ResultModel> updateGift(DocumentReference? cafe,
      DocumentReference? user, int cafeGiftCount) async {
    var model = new ResultModel();

    CollectionReference userGifts = user!.collection('userVisits');

    QuerySnapshot userGift =
        await userGifts.where('cafe', isEqualTo: cafe).limit(1).get();
    if (userGift.docs.isNotEmpty) {
      var userGiftModel = userGift.docs[0];
      int gift = userGiftModel["gift"];
      gift = gift - cafeGiftCount;
      await user
          .collection('userVisits')
          .doc(userGiftModel.id)
          .update({'gift': gift});
      model.Result = true;
    } else {
      model.Message = "Geçersiz";
      model.Result = false;
    }
    return model;
  }

  Future<ResultModel> completeRaffleGift(DocumentReference? userBarcode) async {
    var model = new ResultModel();

    var document = await userBarcode!.get();
    UserBarcodeListModel bookingList = UserBarcodeListModel.fromFirestore(
        Map<String, dynamic>.from(document.data() as Map<dynamic, dynamic>),
        document.reference,
        document);
    if (bookingList.giftCompleted == true) {
      model.Result = false;
      model.Message = "Hediye daha önce verildi";
    } else {
      await userBarcode
          .update({'giftCompleted': true, 'giftCompletedDate': DateTime.now()});
      model.Result = true;
    }

    return model;
  }
}
