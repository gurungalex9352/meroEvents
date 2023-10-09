import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mero_events/screens/home_screen.dart';
import 'package:http/http.dart' as http;
// utils
import './../utils/constants.dart';

// screens
import './../screens/register_screen.dart';

// components
// import './../components/custom_button.dart';
// import './../components/custom_link_badge.dart';
import './../components/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRemembered = false;

  RegExp usernRegX = RegExp(r'^(^[A-Za-z][A-Za-z0-9_]{7,29}$)$');
  RegExp passwordRegX =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

  // handlers
  String? emailValidation(String? value) {
    if (value == null || value.isEmpty || value.trim() == '') {
      return 'Username is required';
    }
    // else if (!usernRegX.hasMatch(value)) {
    //   return 'Invalid Username';
    // }
    return null;
  }

  String? passwordValidation(String? value) {
    if (value == null || value.isEmpty || value.trim() == '') {
      return 'Password is required';
    }
    // else if (!passwordRegX.hasMatch(value)) {
    //   return 'Invalid Password';
    // }
    return null;
  }

  void handleLogin() async {
    if (_formkey.currentState!.validate()) {
      try {
        final response = await http.post(
        Uri.parse('http://192.168.1.69:3000/login'),
        headers: {'Content-Type': 'application/json'},  // Specify JSON content type
        body: jsonEncode({  // Encode the data as JSON
          'username': _emailController.text,
          'password': _passwordController.text,
        }),
      );

        print(
            'Sending data: ${_emailController.text}, ${_passwordController.text}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          // Login successful
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Login failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Incorrect credentials.'),
              backgroundColor: Colors.red.shade300,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 2500),
            ),
          );
        }
      } catch (e) {
        print('Error during login: $e');
      }
    }
  }

  void clearData() {
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50.0,
                  ),
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomTextField(
                    label: 'Username',
                    placeholder: 'Your Username',
                    inputType: TextInputType.emailAddress,
                    fieldController: _emailController,
                    handleValidation: emailValidation,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextField(
                    label: 'Password',
                    placeholder: 'Your Password',
                    inputType: TextInputType.emailAddress,
                    fieldController: _passwordController,
                    handleValidation: passwordValidation,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isRemembered,
                            onChanged: (value) {
                              setState(() {
                                isRemembered = value!;
                              });
                            },
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          print('Forgot Password is clicked');
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: kLinkColor,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    // name: 'Login',
                    // handleClicked: handleLogin,
                    child: Text("Login"),
                    onPressed: handleLogin, // Call the handleLogin function
                  ),
                  const SizedBox(
                    height: 45.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 75,
                        child: Divider(
                          height: 1.0,
                          thickness: 1.0,
                          color: kIconColor,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: kIconColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "Register now",
                          style: TextStyle(
                            color: kLinkColor,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
