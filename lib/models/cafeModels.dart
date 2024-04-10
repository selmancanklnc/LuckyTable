import 'package:cloud_firestore/cloud_firestore.dart';

class TableListModel {
  TableListModel(
      {this.barcode, this.cafe, this.name, this.documentId, this.document});

  String? barcode;
  DocumentReference? cafe;
  String? name;
  String? documentId;
  DocumentReference? document;

  factory TableListModel.fromFirestore(
      Map<dynamic, dynamic> json, DocumentReference? document) {
    return TableListModel(
        barcode: json['barcode'],
        cafe: json['cafe'],
        name: json['name'],
        documentId: document?.id,
        document: document);
  }
}

class CafeListModel {
  CafeListModel(
      {this.name,
      this.giftActive,
      this.giftCount,
      this.documentId,
      this.distance,
      this.lat,
      this.lon,
      this.image,
      this.color,
      this.position,
      this.documentSnapshot,
      this.document,
      this.isActive});

  String? name;
  int? giftCount;
  bool? giftActive;
  double? distance;
  double? lat;
  double? lon;
  String? image;
  String? color;
  bool? isActive;
  String? documentId;
  PositionListModel? position;
  DocumentReference? document;
  DocumentSnapshot? documentSnapshot;

  factory CafeListModel.fromFirestore(Map<dynamic, dynamic> json,
      DocumentReference? document, DocumentSnapshot? documentSnapshot) {
    return CafeListModel(
        name: json['name'],
        giftActive: json["giftActive"],
        giftCount: json["giftCount"],
        image: json['image'],
        isActive: json["isActive"],
        color: json["color"],
        position: PositionListModel.fromFirestore(json["position"]),
        documentId: document?.id,
        documentSnapshot: documentSnapshot,
        document: document);
  }
}
class PositionListModel {
  PositionListModel(
      {this.geoPoint});

  GeoPoint? geoPoint; 

  factory PositionListModel.fromFirestore(
      Map<dynamic, dynamic> json) {
    return PositionListModel(
        geoPoint: json['geopoint'],
        );
  }
}
