import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego/src/di/data_layer_injector.dart';
import 'package:zego/src/domain/entities/user_model.dart';
import 'package:zego/src/domain/usecase/set_user_use_case.dart';
import 'package:zego/src/presentations/screens/home/home_screen.dart';
import 'package:zego/src/presentations/screens/sign_up/sign_up_screen.dart';

class ZimLogInScreen extends StatefulWidget {
  const ZimLogInScreen({super.key});

  @override
  State<ZimLogInScreen> createState() => _ZimLogInScreenState();
}

class _ZimLogInScreenState extends State<ZimLogInScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  String? _nameError;
  String? _idError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Sign In Zego',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.purple,
                    )),
                const SizedBox(height: 20),
                //text fields one for email and one for password
                TextFormField(
                    decoration: InputDecoration(
                        labelText: 'User Name',
                        errorText: _nameError,
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.purple,
                          ),
                        )),
                    controller: userNameController,
                    keyboardType: TextInputType.name,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        _nameError = 'Please enter valid name';
                      } else {
                        _nameError = null;
                      }
                      setState(() {});
                    }),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'ID',
                    errorText: _idError,
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  controller: userIdController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      _idError = 'Please enter valid ID';
                    } else {
                      _idError = null;
                    }
                    setState(() {});
                  },
                ),
                const SizedBox(height: 50),
                //sign up button
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(
                      Colors.purple,
                    ),
                  ),
                  onPressed: () {
                    bool isValid = true;
                    if (userNameController.text.isEmpty) {
                      _nameError = 'Please enter valid name';
                      isValid = false;
                    }
                    if (userIdController.text.isEmpty) {
                      _idError = 'Please enter valid ID';
                      isValid = false;
                    }

                    if (isValid) {
                      //TODO: send request to server
                    }
                  },
                  child: const Text(
                    'Sign In Zego',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
