
import 'dart:convert';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/paints/backgroundPaint.dart';
import 'package:btsi_taxi/Utility/snackBar.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/Utility/widgets/logo.dart';
import 'package:btsi_taxi/Utility/widgets/textFormFields.dart';
import 'package:btsi_taxi/screens/forgotPassword/confirmOTPPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class ForgotPasswordPage extends StatefulWidget {
  static const routeName = '/ForgotPasswordPage';
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  bool _isLoading = false;
  final TextEditingController mobileNumberController = new TextEditingController();
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
              children: <Widget>[
                Logo(),
                headerSection(),
                textSection(),
                buttonSection(),
                SizedBox(height: 110.0),
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
      margin: EdgeInsets.only(top: 10.0),
      child: ButtonSolid(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            SharedPreferences sharedPreferences = await SharedPreferences
                .getInstance();
            sharedPreferences.setString(
                "mobile_no", mobileNumberController.text);

            Map data = {
              'mobile_no': mobileNumberController.text,
            };

            setState(() => _isLoading = true);
            print(mobileNumberController.text);
            var url = Uri.parse(domainBackend + "/api/auth/forgot_password");

            http.post(url, body: data).then((response) {
              print(response.statusCode);

              if (response.statusCode != 500) {
                var jsonResponse = json.decode(response.body);
                print(jsonResponse);

                if (response.statusCode >= 200 && response.statusCode <= 299) {
                  if(jsonResponse != null) {
                    notify(context, "OTP send");
                    // sharedPreferences.setString("otp_token", jsonResponse['access_token']);
                    Navigator.of(context).pushNamed(ConfirmOTPPage.routeName);
                  } else {
                    notify(context, "No respond");
                  }
                } else {
                  notify(context, jsonResponse != null ? jsonResponse["message"]: "Invalid credentials");
                }
              } else {
                notify(context, "server error, check the mobile number field or try again later");
              }
              setState(() => _isLoading = false);
            });
          }
        },
        text: "NEXT",
      ),
    );
  }

  Container textSection() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormFieldGen(
              controller: mobileNumberController,
              keyboardType: TextInputType.number,
              labelText: "Mobile Number",
              prefixText: "+63",
              icon: const Icon(Icons.phone_android),
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
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.0),
      child: Text("Please enter your mobile number",
        style: TextStyle( fontWeight: FontWeight.bold, color: genThirdColor),
      ),
    );
  }
}