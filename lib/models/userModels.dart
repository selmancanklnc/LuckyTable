import 'package:cloud_firestore/cloud_firestore.dart';

class UserListModel {
  UserListModel(
      {this.userId,
      this.name,
      this.email,
      this.phone,
      this.image,
      this.documentId,
      this.document});

  String? userId;
  String? email;
  String? name;
  String? phone;
  String? image;
  String? documentId;
  DocumentReference? document;

  factory UserListModel.fromFirestore(
      Map<dynamic, dynamic> json, DocumentReference? document) {
    return UserListModel(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        phone: json["phone"],
        image: json["image"],
        documentId: document?.id,
        document: document);
  }
}

class UserBarcodeListModel {
  UserBarcodeListModel(
      {this.date,
      this.cafeName,
      this.cafe,
      this.cafeGiftActive,
      this.cafeGiftCount,
      this.tableName,
      this.table,
      this.userGiftCount,
      this.user,
      this.documentId,
      this.document,
      this.userVisit,
      this.giftSuccess,
      this.giftCompleted,
      this.giftCompletedDate,
      this.documentSnapshot});

  Timestamp? date;
  String? cafeName;
  int? cafeGiftCount;
  int? userGiftCount;
  bool? cafeGiftActive;
  bool? giftSuccess;
  bool? giftCompleted;
  Timestamp? giftCompletedDate;
  String? tableName;
  DocumentReference? cafe;
  DocumentReference? table;
  DocumentReference? user;

  String? documentId;
  DocumentReference? document;
  DocumentReference? userVisit;
  DocumentSnapshot? documentSnapshot;

  factory UserBarcodeListModel.fromFirestore(Map<dynamic, dynamic> json,
      DocumentReference? document, DocumentSnapshot documentSnapshot) {
    return UserBarcodeListModel(
        date: json['date'],
        cafe: json['cafe'],
        table: json['table'],
        giftSuccess: json['giftSuccess'],
        giftCompletedDate: json['giftCompletedDate'],
        giftCompleted: json['giftCompleted'],
        documentId: document?.id,
        userVisit: document?.parent.parent,
        documentSnapshot: documentSnapshot,
        document: document);
  }
}

class UserVisitListModel {
  UserVisitListModel({
    this.cafeName,
    this.cafeColor,
    this.cafe,
    this.cafeGiftActive,
    this.cafeGiftCount,
    this.gift,
    this.cafeImage,
    this.documentId,
    this.document,
  });

  Timestamp? date;
  String? cafeName;
  String? cafeColor;
  String? cafeImage;
  int? cafeGiftCount;
  int? gift;
  bool? cafeGiftActive;
  DocumentReference? cafe;
  String? documentId;
  DocumentReference? document;

  factory UserVisitListModel.fromFirestore(Map<dynamic, dynamic> json,
      DocumentReference? document, DocumentSnapshot documentSnapshot) {
    return UserVisitListModel(
        cafe: json['cafe'],
        gift: json["gift"],
        documentId: document?.id,
        document: document);
  }
}

class NotificationListModel {
  NotificationListModel(
      {this.userId,
      this.title,
      this.body,
      this.documentId,
      this.document,
      this.date});

  String? userId;
  String? title;
  String? body;
  String? documentId;
  Timestamp? date;
  DocumentReference? document;

  factory NotificationListModel.fromFirestore(
      Map<dynamic, dynamic> json, DocumentReference? document) {
    return NotificationListModel(
        userId: json['userId'],
        title: json['title'],
        body: json['body'],
        date: json['date'],
        documentId: document?.id,
        document: document);
  }
}
