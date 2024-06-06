import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/TextField.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Provider
import 'package:hanap/provider/Auth_Provider.dart';
import 'package:hanap/provider/User_Provider.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Controllers declaration
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPWController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscure = true;
  bool _isObscureRepeat = true;

  // Initial State
  @override
  void initState() {
    super.initState();

    _firstNameController.addListener(() {});
    _lastNameController.addListener(() {});
    _emailController.addListener(() {});
    _passwordController.addListener(() {});
    _repeatPWController.addListener(() {});
  }

  // Dispose
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPWController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
          body: Padding(
              padding: padding,
              child: Center(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo Image
                          Container(
                            height: 50,
                            width: 50,
                            child: Image.asset('assets/images/logo.png'),
                          ),

                          // LogIn Here text
                          Text(
                            "Create Account",
                            style: HEADER_BLUE,
                          ),

                          // First Name
                          Container(
                              padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                              child:
                                  textField(_firstNameController, "First Name",
                                      // Validator
                                      (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your first name.";
                                }
                              })),

                          // Last Name
                          Container(
                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                              child: textField(_lastNameController, "Last Name",
                                  // Validator
                                  (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your last name.";
                                }
                              })),

                          // Username
                          Container(
                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                              child: textField(
                                  _emailController, "Email", // Validator
                                  (value) {
                                final emailRegex =
                                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                                if (value!.isEmpty) {
                                  return "Please enter your email.";
                                }
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                              })),

                          // Password
                          Container(
                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                              child: textFieldPassword(
                                  _passwordController, "Password", _isObscure,
                                  // Validator
                                  (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your password";
                                } else if (value.length < 6) {
                                  return "Password must be at least 6 characters.";
                                }
                              },
                                  // Action button
                                  () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              })),

                          // Repeat Password
                          Container(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 15, 10, 20),
                              child: textFieldPassword(_repeatPWController,
                                  "Password", _isObscureRepeat,
                                  // Validator
                                  (value) {
                                if (value!.isEmpty) {
                                  return "Please repeat your password";
                                } else if (value.length < 6) {
                                  return "Password must be at least 6 characters.";
                                } else if (_passwordController.text !=
                                    _repeatPWController.text) {
                                  return "Password does not match.";
                                }
                              },
                                  // Action button
                                  () {
                                setState(() {
                                  _isObscureRepeat = !_isObscureRepeat;
                                });
                              })),

                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              // By Signing up... prompt
                              const Text(
                                "By signing up, you agree to our ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Quicksand",
                                  fontSize: 15,
                                ),
                              ),

                              // Text Button
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: textButton(
                                    "Terms and Conditions",
                                    BLUE,
                                    15,
                                    Quicksand,
                                    () => Navigator.pushNamed(
                                        context, '/view-terms-and-conditions')),
                              ),
                            ],
                          ),

                          // Sign Up Button
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: SizedBox(
                                width: double.infinity,
                                child:
                                    elevatedButton("Sign Up", GREEN, () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await context.read<AuthProvider>().signUp(
                                        _emailController.text,
                                        _passwordController.text);
                                    String id =
                                        context.read<AuthProvider>().uid!;
                                    await context.read<UserProvider>().addUser(
                                          id,
                                          _firstNameController.text,
                                          _lastNameController.text,
                                        );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Navigator.pop(context);
                                  }
                                })),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have account?",
                                  style: BODY_TEXT,
                                ),
                                textButton("Log in", GREEN, 15, Quicksand,
                                    () => {Navigator.pop(context)}),
                              ])
                        ],
                      ),
                    ],
                  ),
                ),
              ))),
      if (_isLoading)
        Container(
          color: Colors.white.withOpacity(0.75),
          child: Center(
            child: circularProgressIndicator(),
          ),
        ),
    ]);
  }
}
