import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:segura_manegerial/Custom%20Function%20And%20Widgets/Functions.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:segura_manegerial/Main%20Page/main_page.dart';
import 'package:segura_manegerial/onpressedevents/crud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

String _uploadedImageUrl = '';

class EditProfile extends StatefulWidget {
  EditProfile({@required this.user});
  //  EditProfile({@required this.googleSignInAccount,@required this.user});
  // final GoogleSignInAccount googleSignInAccount;
  final FirebaseUser user;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String name, city, business, alternateNo;
  File _image;


  Future getImage() async {
    await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  Future uploadImage() async {
    // print(widget.user.uid);
    // print(widget.user.phoneNumber);
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('tests/${Path.basename(_image.path)}}');
    //.child('manager/${widget.user.phoneNumber}/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      CRUD.updateImageUrl(fileURL);
      setState(() {
        _uploadedImageUrl = fileURL;
      });
    });
  }

  Future getImageUrl() async {
    _uploadedImageUrl = await CRUD.getUploadedImageUrl();
    setState(() {
      
    });
  }
  @override
  void initState() {
    super.initState();
    getImageUrl();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 50),
            Stack(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(60),
                        elevation: 30,
                        child: (_uploadedImageUrl != '')
                            ? CachedNetworkImage(
                                imageUrl: _uploadedImageUrl,
                                fit: BoxFit.cover,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 140,
                                  width: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(80),
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                            Colors.white10, BlendMode.color)),
                                  ),
                                ),
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                            : CircleAvatar(
                              backgroundImage: AssetImage('assets/defaultUser.png'),
                              minRadius: 70,
                              maxRadius: 70,
                            ))),
                Padding(
                  padding: EdgeInsets.fromLTRB(200, 80, 0, 0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.edit, color: Colors.white70),
                    onPressed: () async {
                      await getImage();
                      await uploadImage();
                      setState(() {
                        print(_uploadedImageUrl);
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 48.0),
            TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  name = value;
                },
                decoration: buildRegisterInputDecoration('Name')),
            SizedBox(height: 8.0),
            TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  business = value;
                },
                decoration: buildRegisterInputDecoration('Business')),
            SizedBox(height: 8.0),
            TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  city = value;
                },
                decoration: buildRegisterInputDecoration('City')),
            SizedBox(height: 8.0),
            TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  alternateNo = value;
                },
                decoration:
                    buildRegisterInputDecoration('Alternate Contact No.')),
            SizedBox(height: 24.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40,vertical: 20),
                          child: MaterialButton(                        
                autofocus: true,
                height: 50,
                color: Colors.blue[900],
                child: Text('Go',style: TextStyle(color: Colors.white),),
                elevation: 10,
                splashColor: Colors.blue,
                onPressed: () async {
                  if (name == null ||
                      name == '' ||
                      city == null ||
                      city == '' ||
                      business == null ||
                      business == '' ||
                      alternateNo == null ||
                      alternateNo == '' ||
                      alternateNo.length != 10) {
                    Alert(
                            context: context,
                            title: "Segura Says",
                            desc: "Please Fill the Form Correctly",
                            type: AlertType.warning,
                            style: AlertStyle(backgroundColor: Colors.white))
                        .show();
                  } else {
                    CRUD.setProfile(name, city, business, alternateNo, '',
                        'user.email');
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                MainPage(phone: widget.user.phoneNumber)),
                        (Route<dynamic> route) => false);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
