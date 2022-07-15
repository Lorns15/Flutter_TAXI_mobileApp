
import 'dart:convert';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/paints/backgroundPaint.dart';
import 'package:btsi_taxi/Utility/snackBar.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/Utility/widgets/logo.dart';
import 'package:btsi_taxi/screens/signup_screens/signupRegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class SignupMobileVerifyPage extends StatefulWidget {
  static const routeName = '/signupMobileVerifyPage';
  @override
  _SignupMobileVerifyPageState createState() => _SignupMobileVerifyPageState();
}

class _SignupMobileVerifyPageState extends State<SignupMobileVerifyPage> {

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
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // SizedBox(height: 110.0),
                Logo(),
                // SizedBox(height: 30.0),
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
              // 'mobile_no': "9108773780",
              'otp': otpNumberController.text
            };

            print(data);

            // setState(() => _isLoading = true);

            var url = Uri.parse(domainBackend + "/api/auth/confirm-otp");

            http.post(url, body: data).then((response) {
              print(response.statusCode);

              if (response.statusCode != 500) {
                var jsonResponse = json.decode(response.body);

                if (response.statusCode >= 200 && response.statusCode <= 299) {
                  setState(() => _isLoading = true);
                  if(jsonResponse != null) {
                    notify(context, "OTP confirmed");
                    sharedPreferences.setString("otp_token", jsonResponse['access_token']);
                    Navigator.of(context).pushNamed(SignupRegisterPage.routeName);
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

            // var response = await http.post(url, body: data);
            // print("otp ---->");
            // print(response.statusCode);
            // print(response.body);
            // print("otp ----<");
            //
            // if (response.statusCode >= 200 && response.statusCode <= 299) {
            //   setState(() => _isLoading = false);
            //   var jsonResponse = json.decode(response.body);
            //   print(jsonResponse);
            //
            //   if (jsonResponse != null) {
            //     sharedPreferences.setString(
            //         "otp_token", jsonResponse['access_token']);
            //     Navigator.of(context).pushNamed(SignupInfoPage.routeName);
            //   }
            // } else {
            //   setState(() => _isLoading = false);
            // }
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
      // child: RichText(
      //   text: TextSpan(
      //       children: <TextSpan>[
      //         TextSpan(
      //           text: "Please choose your ",
      //           style: TextStyle(color: Colors.black87),
      //         ),
      //         TextSpan(
      //           text: "Account type",
      //           style: TextStyle(fontWeight: FontWeight.bold, color: genThirdColor),
      //         ),
      //       ]
      //   ),
      // ),
      child: Text("Enter the OTP sent to your mobile number",
        style: TextStyle( fontWeight: FontWeight.bold, color: genThirdColor),
      ),
    );
  }
}