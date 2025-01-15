import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

  //late String email, password;
  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  var image;

  var imgUrl;
  Map map = {};
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              height: MediaQuery.of(context).size.height,
              color: Colors.purple.shade900,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              margin: EdgeInsets.only(
                top: 60,
              ),
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (builder) => bottomSheet());
                        },
                        child: CircleAvatar(
                          backgroundImage: image == null
                              ? AssetImage("assets/pic.png")
                              : FileImage(File(image!.path)) as ImageProvider,
                          radius: 70,
                        ),
                      ),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: "Name"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) return "Enter Name";
                        },
                        // onSaved: (value) {
                        //   email = value!;
                        // },
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: "Email"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) return "Enter Email";
                        },
                        // onSaved: (value) {
                        //   email = value!;
                        // },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: "Password"),
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value!.isEmpty) return "Enter Password";
                        },
                        // onSaved: (value) {
                        //   password = value!;
                        // },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (image != null) {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      Text(
                                        "Please wait...",
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              registerUser(context);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please upload your photo");
                            }
                          }
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerUser(context) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      Reference firebaseStorage = FirebaseStorage.instance
          .ref()
          .child("Profile Photos")
          .child(auth.currentUser!.uid);
      UploadTask uploadTask = firebaseStorage.putFile(File(image.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      await taskSnapshot.ref.getDownloadURL().then((url) => {imgUrl = url});

      await firestore
          .collection("Users")
          .doc(auth.currentUser!.uid)
          .set({
            'Name': nameController.text,
            'Email': emailController.text,
            'Image': imgUrl,
            'Password': passwordController.text,
            'Id': auth.currentUser!.uid,
          })
          .then((signedInUser) =>
              {Fluttertoast.showToast(msg: "Registration Successful")})
          .then((value) => {
                Navigator.of(context).pop(),
              })
          .then((value) => {
                Navigator.of(context).pop(),
              });
    } catch (e) {
      Fluttertoast.showToast(msg: "Registration failed");
      Navigator.of(context).pop();
    }
  }

  Future<void> takePhoto(ImageSource source) async {
    var img = await ImagePicker().pickImage(source: source);
    setState(() {
      image = img;
    });
  }

  Widget bottomSheet() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text("Choose profile photo"),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.camera),
                label: Text("Camera"),
              ),
              TextButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.image),
                label: Text("Gallery"),
              )
            ],
          )
        ],
      ),
    );
  }
}
