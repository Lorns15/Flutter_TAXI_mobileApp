import 'dart:convert';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/paints/backgroundPaint.dart';
import 'package:btsi_taxi/Utility/snackBar.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/Utility/widgets/logo.dart';
import 'package:btsi_taxi/Utility/widgets/textFormFields.dart';
import 'package:btsi_taxi/screens/forgotPassword/forgotPasswordPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'driver/driverMainPage.dart';
import 'operator/operatorMainPage.dart';
import 'passenger/mapPage.dart';
import 'signup_screens/signupSelectionPage.dart';

// import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  static const routeName = '/loginPage';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isLoading = false;
  final TextEditingController mobileNumberController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                // SizedBox(height: 110.0),
                Logo(),
                // SizedBox(height: 30.0),
                // headerSection(),
                textSection(),
                Container(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: genThirdColor,
                        fontSize: 15.0,
                      ),
                    ),
                    onPressed: (){
                      Navigator.of(context).pushNamed(ForgotPasswordPage.routeName);
                    },
                  ),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                ),
                buttonSection(),
                Container(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: (){
                      Navigator.of(context).pushNamedAndRemoveUntil(SignupSelectionPage.routeName, (route) => false);
                    },
                    child: RichText(
                      text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15.0,
                              ),
                            ),
                            TextSpan(
                              text: "create a new account",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: genThirdColor,
                                fontSize: 15.0,
                              ),
                            ),
                          ]
                      ),
                    ),
                    // Text(
                    //   "Don't have account? create a new account",
                    // ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                ),
                SizedBox(height: 110.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  logIn(String mobileNumber, pass) async {
    Map data = {
      'mobile_no': mobileNumber,
      'password': pass
    };
    print(mobileNumber);
    print(pass);
    var url = Uri.parse(domainBackend + "/api/auth/login");
    // var response = await http.post(url, body: data);
    http.post(url, body: data).then((response) async {
      print(response.statusCode);

      if (response.statusCode != 500) {
        var jsonResponse = json.decode(response.body);
        print(response.statusCode);

        if(response.statusCode >= 200 && response.statusCode <= 299) {
          if(jsonResponse != null) {
            // notify(context, "login successful");
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            // sharedPreferences.setString("access_token", jsonResponse['access_token']);
            // sharedPreferences.setString("token_type", jsonResponse['token_type']);
            sharedPreferences.setString("response", response.body);
            print("jsonResponse");
            print(jsonResponse);
            print(jsonResponse['data']['role']);
            if (jsonResponse['data']['role'] == 'driver') {
              Navigator.of(context).pushNamedAndRemoveUntil(DriverMainPage.routeName, (route) => false);
            } else if (jsonResponse['data']['role'] == 'passenger') {
              Navigator.of(context).pushNamedAndRemoveUntil(MapPage.routeName, (route) => false);
            } else if (jsonResponse['data']['role'] == 'admin') {
              Navigator.of(context).pushNamedAndRemoveUntil(OperatorMainPage.routeName, (route) => false);
            }
          } else {
            notify(context, "No respond");
            setState(() => _isLoading = false);
          }
        } else {
          notify(context, jsonResponse != null ? jsonResponse["message"]: "Invalid credentials");
          setState(() => _isLoading = false);
        }
      } else {
        notify(context, "server error, check the mobile number field or try again later");
        setState(() => _isLoading = false);
      }
      // setState(() => _isLoading = false);
    });

  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: ButtonSolid(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            setState(() => _isLoading = true);
            logIn(mobileNumberController.text, passwordController.text);
          }
        },
        text: "LOGIN",

      ),
    );
  }


  Container textSection() {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormFieldGen(
              controller: mobileNumberController,
              keyboardType: TextInputType.number,
              labelText: "Mobile Number",
              prefixText: "+63",
              icon: const Icon(Icons.account_box),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field';
                }
                return null;
              },
            ),
            // SizedBox(height: 20.0),
            TextFormFieldGen(
              controller: passwordController,
              labelText: "Password",
              obscureText: true,
              icon: const Icon(Icons.lock),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field';
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
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text("WELCOME TO BTSI TAXI",
        textAlign: TextAlign.center,
        style: TextStyle( fontWeight: FontWeight.bold, color: genPrimaryColor),
      ),
    );
  }
}