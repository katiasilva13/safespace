// import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:profanity_filter/profanity_filter.dart';
// import 'package:commons/commons.dart';
import 'package:safespace/models/postage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class PostageScreen extends StatefulWidget {
  @override
  _PostageScreenState createState() => _PostageScreenState();
}

class _PostageScreenState extends State<PostageScreen> {
  Postage _postage;

  BuildContext _dialogContext;

  final _formKey = GlobalKey<FormState>();

  final _messageController = TextEditingController();

  final filter = ProfanityFilter();

  List<File> _imageList = List();

  _selectImage() async {
    File selectedImage;
    selectedImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        _imageList.add(selectedImage);
      });
    }
  }

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
                Text("Publicando..."),
              ],
            ),
          );
        });
  }

  _post() async {
    _abrirDialog(_dialogContext);

    await _uploadImages();

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    String idLoggedUser = loggedUser.uid;
    _postage.idUser = idLoggedUser;
    _postage.sendDate = DateTime.now();
    if (_postage.images.length < 1) _postage.images.add('');

    Firestore db = Firestore.instance;
    db
        .collection("my_posts")
        .document(idLoggedUser)
        .collection("posts")
        .document(_postage.id)
        .setData(_postage.toMap())
        .then((_) {
      db
          .collection("posts")
          .document(_postage.id)
          .setData(_postage.toMap())
          .then((_) {
        Navigator.pop(_dialogContext);
        Navigator.of(context).pushReplacementNamed('/base');
      });
    });
  }

  Future _uploadImages() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();

    for (var imagem in _imageList) {
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference arquivo =
          pastaRaiz.child("my_posts").child(_postage.id).child(nomeImagem);

      StorageUploadTask uploadTask = arquivo.putFile(imagem);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      String url = await taskSnapshot.ref.getDownloadURL();
      _postage.images.add(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _postage = Postage.generateId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      FormField<List>(
                        initialValue: _imageList,
                        builder: (state) {
                          return Column(
                            children: [
                              Container(
                                height: 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _imageList.length + 1,
                                    itemBuilder: (context, indice) {
                                      if (indice == _imageList.length) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              _selectImage();
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey[400],
                                              radius: 40,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_a_photo,
                                                    size: 40,
                                                    color: Colors.grey[100],
                                                  ),
                                                  Text(
                                                    "Adicionar",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[100]),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      if (_imageList.length > 0) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.file(
                                                                _imageList[
                                                                    indice]),
                                                            FlatButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  _imageList
                                                                      .removeAt(
                                                                          indice);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                });
                                                              },
                                                              child: Text(
                                                                  "Excluir"),
                                                              textColor:
                                                                  Colors.red,
                                                            ),
                                                          ],
                                                        ),
                                                      ));
                                            },
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundImage:
                                                  FileImage(_imageList[indice]),
                                              child: Container(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 0.4),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return Container();
                                    }),
                              ),
                              if (state.hasError)
                                Container(
                                  child: Text(
                                    "${state.errorText}",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      TextFormField(
                        // expands: true,
                        onSaved: (message) {
                          _postage.message = message;
                        },
                        maxLines: 50,
                        minLines: 1,
                        // maxLines: null,
                        // minLines: null,
                        controller: _messageController,
                        keyboardType: TextInputType.text,
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Escreva o conteúdo da sua postagem";
                          } else {
                            _messageController.text = filter.censor(text);
                            return null;
                          }
                        },
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 0, 32, 80),
                          hintText: "Post",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 10),
                        child: RaisedButton(
                          child: Text(
                            "Publicar",
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          textColor: Colors.white,
                          color: Color.fromARGB(255, 0, 100, 0),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();

                              _dialogContext = context;

                              _post();
                            }
                          },
                          padding: EdgeInsets.fromLTRB(122, 16, 122, 16),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ],
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
