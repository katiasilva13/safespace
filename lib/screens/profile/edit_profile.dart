import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _nicknameController = TextEditingController();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  File _imagem;
  String _idLoggedUser;
  bool _uploadingImage = false;
  String _recoveredImageUrl;

  BuildContext _dialogContext;

  _abrirDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text("Salvando perfil"),
              ],
            ),
          );
        });
  }

  Future _recoverImage(String source) async {
    File selectedImage;

    switch (source) {
      case "camera":
        selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "galeria":
        selectedImage =
            await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = selectedImage;
      if (_imagem != null) {
        _uploadingImage = true;
        _uploadImage();
      }
    });
  }

  Future _uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo =
        pastaRaiz.child("perfil").child(_idLoggedUser + ".jpg");

    StorageUploadTask task = arquivo.putFile(_imagem);

    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _uploadingImage = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _uploadingImage = false;
        });
      }
    });
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recoverImageUrl(snapshot);
    });
  }

  Future _recoverImageUrl(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore(url);
    setState(() {
      _recoveredImageUrl = url;
    });
  }

  _atualizarNameFirestore() {
    _abrirDialog(_dialogContext);

    String nickname = _nicknameController.text;
    String name = _nameController.text;
    String bio = _bioController.text;
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "nickname": nickname,
      "name": name,
      "bio": bio
    };

    db
        .collection("users")
        .document(_idLoggedUser)
        .updateData(dadosAtualizar)
        .then((_) {
      Navigator.pop(_dialogContext);
      Navigator.pop(context);
    });
  }

  _atualizarUrlImagemFirestore(String url) {
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {"photo": url};

    db.collection("users").document(_idLoggedUser).updateData(dadosAtualizar);
  }

  _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idLoggedUser = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_idLoggedUser).get();

    Map<String, dynamic> dados = snapshot.data;

    _nicknameController.text = dados["nickname"];
    _nameController.text = dados["name"];
    _bioController.text = dados["bio"];

    if (dados["photo"] != null) {
      setState(() {
        _recoveredImageUrl = dados["photo"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _recoverUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Perfil"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  child: _uploadingImage
                      ? CircularProgressIndicator()
                      : Container(),
                ),
                CircleAvatar(
                  radius: 75,
                  backgroundImage: _recoveredImageUrl != null
                      ? NetworkImage(_recoveredImageUrl)
                      : null,
                  backgroundColor: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: () {
                          _recoverImage("camera");
                        },
                        child: Text("Câmera")),
                    FlatButton(
                        onPressed: () {
                          _recoverImage("galeria");
                        },
                        child: Text("Galeria")),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.green,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: TextFormField(
                    controller: _nicknameController,
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.alternate_email_rounded,
                        color: Colors.green,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Usuário",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: TextFormField(
                    controller: _bioController,
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.edit,
                        color: Colors.green,
                      ),
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 50),
                      hintText: "Biografia",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      "Salvar",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    textColor: Colors.white,
                    color: Color.fromARGB(255, 0, 100, 0),
                    onPressed: () {
                      _dialogContext = context;
                      _atualizarNameFirestore();
                    },
                    padding: EdgeInsets.fromLTRB(132, 16, 132, 16),
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
