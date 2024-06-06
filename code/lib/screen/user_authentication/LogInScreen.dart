import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hanap/Themes.dart';
import 'package:hanap/provider/User_Provider.dart';
import 'package:provider/provider.dart';

// Components
import 'package:hanap/components/TextField.dart';
import 'package:hanap/components/Buttons.dart';
import 'package:hanap/components/CircularProgressIndicator.dart';

// Provider
import 'package:hanap/provider/Auth_Provider.dart';

class LogIn extends StatefulWidget {
  LogIn({super.key});

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // Controllers declaration
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscure = true;
  bool _isInvalid = false;

  // Initial State
  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {});
    _passwordController.addListener(() {});
  }

  // Dispose
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Image
                  Container(
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/images/logo.png'),
                  ),

                  // LogIn Here text
                  Text(
                    "Login Here",
                    style: HEADER_BLUE,
                  ),

                  // Username
                  Container(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      child: textField(_emailController, "Email",
                          // Validator
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
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
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

                  // Log In Button
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                    child: SizedBox(
                        width: double.infinity,
                        child: elevatedButton("Log In", GREEN, () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            final authProvider = context.read<AuthProvider>();
                            await context.read<AuthProvider>().signIn(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                            if (!mounted) return;

                            String? uid = authProvider.uid;
                            // If no uid, it is invalid
                            if (uid == null) {
                              setState(() {
                                _isLoading = false;
                                _isInvalid = true;
                              });
                            }
                          }
                        })),
                  ),
                  // Invalid email or password. Display only when invalid credentials
                  if (_isInvalid)
                    Text(
                      "Wrong email or password.",
                      style: VALIDATE_TEXT,
                    ),
                  Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "First Access? ",
                            style: BODY_TEXT,
                          ),
                          textButton("Sign Up Here", GREEN, 15, Quicksand,
                              () => {Navigator.pushNamed(context, '/signup')})
                        ]),
                  )
                ],
              )),
        ),
      )),
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
