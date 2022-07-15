
import 'dart:convert';
import 'dart:io';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/paints/backgroundPaint.dart';
import 'package:btsi_taxi/Utility/snackBar.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/Utility/widgets/logo.dart';
import 'package:btsi_taxi/screens/forgotPassword/resetPasswordPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class ConfirmOTPPage extends StatefulWidget {
  static const routeName = '/ConfirmOTPPage';
  @override
  _ConfirmOTPPageState createState() => _ConfirmOTPPageState();
}

class _ConfirmOTPPageState extends State<ConfirmOTPPage> {

  bool _isLoading = false;
  final TextEditingController otpNumberController = new TextEditingController();
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
              children: <Widget>[
                Logo(),
                headerSection(),
                textSection(context),
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
      // margin: EdgeInsets.only(top: 15.0),
      child: ButtonSolid(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            SharedPreferences sharedPreferences = await SharedPreferences
                .getInstance();
            print(otpNumberController.text);

            Map data = {
              'mobile_no': sharedPreferences.getString("mobile_no"),
              'otp': otpNumberController.text
            };

            print(data);

            // setState(() => _isLoading = true);

            var url = Uri.parse(domainBackend + "/api/auth/forgot_password/confirm_otp");
            // var token = sharedPreferences.getString("otp_token");

            http.post(url,
                body: data).then((response) {
              print(response.statusCode);

              if (response.statusCode != 500) {
                var jsonResponse = json.decode(response.body);
                print(jsonResponse);

                if (response.statusCode >= 200 && response.statusCode <= 299) {
                  setState(() => _isLoading = true);
                  if(jsonResponse != null) {
                    notify(context, "OTP confirmed");
                    // sharedPreferences.setString("otp_token", jsonResponse['access_token']);
                    Navigator.of(context).pushNamed(ResetPasswordPage.routeName);
                  } else {
                    notify(context, "No respond");
                  }
                  setState(() => _isLoading = false);
                } else {
                  notify(context, jsonResponse != null ? jsonResponse["message"]: "Invalid credentials");
                }
              } else {
                notify(context, "server error, check the mobile number field or try again later");
              }
              // setState(() => _isLoading = false);
            });
          }
        },
        text: "NEXT",

      ),
    );
  }


  Container textSection(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 15.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            PinCodeTextField(
              controller: otpNumberController,
              appContext: context,
              onChanged: (String value) {
                print(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field';
                } else if (value.length != 6) {
                  return 'Please complete this field';
                }
                return null;
              },
              length: 6,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(3.0),
                fieldHeight: 50,
                fieldWidth: 50,
                activeColor: genPrimaryColor,
                inactiveColor: Colors.grey,
                selectedColor: genPrimaryColor,
              ),
              keyboardType: TextInputType.number,
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
      child: Text("Enter the OTP sent to your mobile number",
        style: TextStyle( fontWeight: FontWeight.bold, color: genThirdColor),
      ),
    );
  }
}