
import 'dart:convert';
import 'dart:io';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/paints/backgroundPaint.dart';
import 'package:btsi_taxi/Utility/snackBar.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/Utility/widgets/logo.dart';
import 'package:btsi_taxi/Utility/widgets/textFormFields.dart';
import 'package:btsi_taxi/screens/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class ResetPasswordPage extends StatefulWidget {
  static const routeName = '/resetPasswordPage';
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {

  bool _isLoading = true;
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController confirmPasswordController = new TextEditingController();
  late SharedPreferences sharedPreferences;
  final _formKey = GlobalKey<FormState>();

  setSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      print(sharedPreferences);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    setSharedPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        child: _isLoading ? Center(child: CircularProgressIndicator()) : CustomPaint(
          painter: BackgroundPainter(),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // SizedBox(height: 30.0),
                Logo(),
                // SizedBox(height: 30.0),
                headerSection(),
                textSection(),
                buttonSection(),
                // SizedBox(height: 110.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: ButtonSolid(
        text: "Confirm",
        onPressed: () async {
          print(passwordController.text);
          print(confirmPasswordController.text);
          if (_formKey.currentState!.validate()) {
            sharedPreferences.setString("password", passwordController.text);

            Map data = {
              "mobile_no": sharedPreferences.getString("mobile_no"),
              "password": passwordController.text
            };

            setState(() => _isLoading = true);

            // var token = sharedPreferences.getString("otp_token");
            // print(token);
            http.put(
              Uri.parse(domainBackend + "/api/auth/reset_password"),
              body: data,
            ).then((response) {
              print(response.statusCode);

              if (response.statusCode != 500) {
                var jsonResponse = json.decode(response.body);
                print(jsonResponse);

                if (response.statusCode >= 200 && response.statusCode <= 299) {
                  if(jsonResponse != null) {
                    notify(context, "reset password complete");
                    // sharedPreferences.setString("response", response.body);
                    Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.routeName, (route) => false);
                  } else {
                    notify(context, "No respond");
                  }
                } else {
                  notify(context, "Invalid credentials");
                }
              } else {
                notify(context, "server error, check the mobile number field or try again later");
              }
              setState(() => _isLoading = false);
            });

          }
        },
      ),
    );
  }

  Container textSection() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // SizedBox(height: 20.0),
            TextFormFieldGen(
              controller: passwordController,
              labelText: "Password",
              obscureText: true,
              icon: const Icon(Icons.lock),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field';
                } else if (value.toString().length < 6) {
                  return 'The password must be at least 6 characters.';
                }
                return null;
              },
            ),
            // SizedBox(height: 20.0),
            TextFormFieldGen(
              controller: confirmPasswordController,
              labelText: "Confirm Password",
              obscureText: true,
              icon: const Icon(Icons.lock),
              validator: (value) {
                print("value");
                print(value);
                print(passwordController.value.text);
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field';
                } else if (value.toString().length < 6) {
                  return 'The password must be at least 6 characters.';
                } else if (value != passwordController.value.text) {
                  return 'Password and confirm password must be the same.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 15.0),
      child: Text('Enter new Password',
        style: TextStyle( fontWeight: FontWeight.bold, color: genThirdColor),
      ),
    );
  }
}