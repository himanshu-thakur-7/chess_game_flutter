import 'dart:io';

import '../widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:email_validator/email_validator.dart";

class AuthForm extends StatefulWidget {
  final bool isLoading;
  final void Function(
    String? email,
    String? password,
    String? userName,
    File? userImage,
    bool isLogin,
    BuildContext ctx,
  )? submitFn;

  const AuthForm({Key? key, this.submitFn, required this.isLoading})
      : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = false;
  String? _userEmail = "";
  String? _userName = "";
  String? _userPassword = "";
  File? _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState?.validate();

    FocusScope.of(context).unfocus(); // close the keybpard after submission

    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please pick an image.',
          ),
          backgroundColor: Colors.amber[800],
        ),
      );
      return;
    }

    if (isValid == true) {
      _formKey.currentState?.save();

      widget.submitFn!(_userEmail!.trim(), _userPassword!.trim(),
          _userName!.trim(), _userImageFile, _isLogin, context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: const Color.fromRGBO(155, 96, 248, 1.0),
        margin: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isLogin)
                      UserImagePicker(
                        imagePickFn: _pickedImage,
                      ),
                    TextFormField(
                      cursorColor: Colors.amber,
                      style: const TextStyle(color: Colors.white),
                      key: const ValueKey('email'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            EmailValidator.validate(value) == false) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.amber[200]),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.amberAccent[100]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.amberAccent[100]!),
                          ),
                          // fillColor: Colors.white,
                          labelStyle: TextStyle(color: Colors.white70),
                          // filled: true,
                          focusColor: Colors.white,
                          // filled: true,
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email,
                            color: Theme.of(context).accentColor,
                          )),
                      onSaved: (value) {
                        _userEmail = value;
                      },
                    ),
                    if (!_isLogin)
                      TextFormField(
                        cursorColor: Colors.amber,
                        style: const TextStyle(color: Colors.white),
                        key: const ValueKey('username'),
                        validator: (val) {
                          if (val == null || val.isEmpty || val.length < 4) {
                            return "Please enter atleast 4 characters";
                          }
                          if (val.length > 10) {
                            return "Username can be of 10 characters (max)";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.amber[200]),
                          labelStyle: TextStyle(color: Colors.white70),
                          labelText: 'Username',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Theme.of(context).accentColor,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.amberAccent[100]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.amberAccent[100]!),
                          ),
                        ),
                        onSaved: (value) {
                          _userName = value;
                        },
                      ),
                    TextFormField(
                      cursorColor: Colors.amber,
                      style: const TextStyle(color: Colors.white),
                      key: const ValueKey('password'),
                      validator: (val) {
                        if (val == null || val.isEmpty || val.length < 7) {
                          return "Password must be atleast 7 characters long";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.amber[200]),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.amberAccent[100]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.amberAccent[100]!),
                          ),
                          labelStyle: TextStyle(color: Colors.white70),
                          labelText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).accentColor,
                          )),
                      onSaved: (value) {
                        _userPassword = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    if (widget.isLoading)
                      const CircularProgressIndicator(
                        color: Colors.amber,
                      ),
                    if (!widget.isLoading)
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.amber[600])),
                        child: Text(_isLogin ? 'Login' : 'Signup'),
                        onPressed: _trySubmit,
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? 'Create Acoount'
                            : 'I already have an account',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
