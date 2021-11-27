import 'package:cloud_firestore/cloud_firestore.dart';

class Postage {
  String _id;
  String _message;
  DateTime _sendDate;
  String _location;
  List<String> _images;
  bool _hide;
  bool _deleted;
  bool _reported;

  Postage();

  Postage.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    this.id = documentSnapshot.documentID;
    this.message = documentSnapshot["message"];
    this.sendDate = documentSnapshot["sendDate"];
    this.location = documentSnapshot["location"];
    this.images = List<String>.from(documentSnapshot["images"]);
    this.hide = documentSnapshot["hide"];
    this.deleted = documentSnapshot["deleted"];
    this.reported = documentSnapshot["reported"];
  }

  Postage.generateId() {
    Firestore db = Firestore.instance;
    CollectionReference postages = db.collection("my_posts");
    this.id = postages.document().documentID;
    this.images = [];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": this.id,
      "sendDate": this.sendDate,
      "location": this.location,
      "message": this.message,
      "hide": this.hide,
      "deleted": this.deleted,
      "reported": this.reported,
      "images": this.images
    };
    return map;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  String get location => _location;

  set location(String value) {
    _location = value;
  }

  List<String> get images => _images;

  set images(List<String> value) {
    _images = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
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
