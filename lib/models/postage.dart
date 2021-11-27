import 'package:cloud_firestore/cloud_firestore.dart';

class Postage {
  String _id;
  String _idUser;
  String _message;
  DateTime _sendDate;
  List<String> _images;
  bool _hide;
  bool _block;
  bool _deleted;
  bool _reported;


  Postage();

  Postage.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    this.id = documentSnapshot.documentID;
    this.idUser = documentSnapshot["idUser"];
    this.message = documentSnapshot["message"];
    // this.sendDate = documentSnapshot["sendDate"];
    Timestamp t = documentSnapshot['sendDate'];
    this.sendDate = t.toDate();
    this.images = List<String>.from(documentSnapshot["images"]);
    this.hide = documentSnapshot["hide"];
    this.block = documentSnapshot["block"];
    this.deleted = documentSnapshot["deleted"];
    this.reported = documentSnapshot["reported"];
  }

  Postage.generateidUser() {
    Firestore db = Firestore.instance;
    CollectionReference postages = db.collection("my_posts");
    this.idUser = postages.document().documentID;
    this.images = [];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": this.id,
      "idUser": this.idUser,
      "sendDate": this.sendDate,
      "message": this.message,
      "hide": this.hide,
      "block": this.block,
      "deleted": this.deleted,
      "reported": this.reported,
      "images": this.images
    };
    return map;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  bool get block => _block;

  set block(bool value) {
    _block = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  List<String> get images => _images;

  set images(List<String> value) {
    _images = value;
  }

  String get idUser => _idUser;

  set idUser(String value) {
    _idUser = value;
  }

  DateTime get sendDate => _sendDate;

  set sendDate(DateTime value) {
    _sendDate = value;
  }

  bool get hide => _hide;

  set hide(bool value) {
    _hide = value;
  }

  bool get reported => _reported;

  set reported(bool value) {
    _reported = value;
  }

  bool get deleted => _deleted;

  set deleted(bool value) {
    _deleted = value;
  }
}
