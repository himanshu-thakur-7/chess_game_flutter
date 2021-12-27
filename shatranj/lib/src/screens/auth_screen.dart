import 'dart:io';

import 'package:chess_ui/src/widgets/auth_form.dart';
import 'package:chess_ui/src/widgets/curve_clipper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;

  var _isLoading = false;

  void _submitAuthForm(
    String? email,
    String? password,
    String? username,
    File? userImage,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email!,
          password: password!,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email!,
          password: password!,
        );
        // perform image upload
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${authResult.user?.uid}.jpg');

        await ref
            .putFile(userImage!)
            .whenComplete(() => {print("image uploaded success!")});

        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user?.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': url,
          'wins': 0,
          'losses': 0,
          'draws': 0,
          'total': 0,
        }).then((value) => print("database updated"));
      }
    } on PlatformException catch (err) {
      print("inside platform exception block");
      var message = "An error Occured, Please check your credentials";

      if (err.message != null) {
        message = err.message!;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      List<String> components = error.toString().split('] ');
      String message = components[1];
      print("inside catch block");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.amber[700], content: Text(message)));

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
              child: AuthForm(
                submitFn: _submitAuthForm,
                isLoading: _isLoading,
              ),
            ),
            ClipPath(
              clipper: CurveClipper(),
              child: Image(
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height / 2.3,
                width: double.infinity,
                image: const AssetImage("graphics/poster2.jpg"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
