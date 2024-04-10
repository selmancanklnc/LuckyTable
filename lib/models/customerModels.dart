import 'package:cloud_firestore/cloud_firestore.dart';

class CafeUserListModel {
  CafeUserListModel(
      {this.userId,
      this.name,
      this.email,
      this.phone,
      this.image,
      this.cafe,
      this.documentId,
      this.document});

  String? userId;
  String? email;
  String? name;
  String? phone;
  String? image;
  String? documentId;
  DocumentReference? document;
  DocumentReference? cafe;

  factory CafeUserListModel.fromFirestore(
      Map<dynamic, dynamic> json, DocumentReference? document) {
    return CafeUserListModel(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        phone: json["phone"],
        cafe: json["cafe"],
        image: json["image"],
        documentId: document?.id,
        document: document);
  }
}
