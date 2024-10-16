import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego/src/domain/entity/user_model.dart';
import 'package:zego/src/presentations/screens/sing_in/sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _passwordError;
  String? _userNameError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.purple,
                      )),
                  const SizedBox(height: 20),
                  //user name
                  TextFormField(
                      decoration: InputDecoration(
                          labelText: 'User Name',
                          errorText: _userNameError,
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.purple,
                            ),
                          )),
                      controller: userNameController,
                      onChanged: (value) {
                        print(value);
                        if (value.isEmpty || value.length < 3) {
                          _userNameError = 'Please enter valid name';
                        } else {
                          _userNameError = null;
                        }
                        setState(() {});
                      }),
                  const SizedBox(height: 20),
                  //text fields one for email and one for password
                  TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Email',
                          errorText: _emailError,
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.purple,
                            ),
                          )),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        if (value.isEmpty ||
                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                          _emailError = 'Please enter valid email';
                        } else {
                          _emailError = null;
                        }
                        setState(() {});
                      }),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _passwordError,
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    controller: passwordController,
                    onChanged: (value) {
                      if (value.isEmpty || value.length < 6) {
                        _passwordError = 'Please enter valid password';
                      } else {
                        _passwordError = null;
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 50),
                  //sign up button
                  Row(
                    children: [
                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                            Colors.purple,
                          ),
                        ),
                        onPressed: () {
                          bool isValid = true;
                          if (userNameController.text.isEmpty ||
                              userNameController.text.length < 3) {
                            _userNameError = 'Please enter valid name';
                            isValid = false;
                          }

                          if (emailController.text.isEmpty ||
                              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(emailController.text)) {
                            _emailError = 'Please enter valid email';
                            isValid = false;
                          }
                          if (passwordController.text.isEmpty ||
                              passwordController.text.length < 6) {
                            _passwordError = 'Please enter valid password';
                            isValid = false;
                          }

                          if (isValid) {
                            FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text)
                                .then((userCredential) {
                              _saveDataInFirestore(userCredential);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sign Up Successful'),
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignInScreen(),
                                ),
                              );
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error.toString())),
                              );
                            });
                          }
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveDataInFirestore(UserCredential userCredential) {
    UserModel userModel = UserModel(
      name: userNameController.text,
      email: emailController.text,
      uid: userCredential.user!.uid,
      createdAt: DateTime.now(),
    );

    if (userCredential.user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());
    }
  }
}
