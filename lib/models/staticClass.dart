import 'package:cloud_firestore/cloud_firestore.dart';

class StaticClass {
  static String? name = "";
  static String? email = "";
  static String? phone = "";
  static String? image = "";
  static DocumentReference? document;
  static DocumentReference? cafe;
  static String baseUrl = "tunaapi.trdsoft.com";
}

class ResultModel {
  bool? Result;
  String? Message;
  String? ResultId;
}
