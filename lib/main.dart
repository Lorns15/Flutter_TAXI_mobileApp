import 'package:btsi_taxi/screens/forgotPassword/confirmOTPPage.dart';
import 'package:btsi_taxi/screens/forgotPassword/forgotPasswordPage.dart';
import 'package:btsi_taxi/screens/forgotPassword/resetPasswordPage.dart';
import 'package:btsi_taxi/screens/operator/operatorMainPage.dart';
import 'package:btsi_taxi/screens/signup_screens/signupSelectionPage.dart';

import 'screens/driver/driverMainPage.dart';
import 'screens/mainPage.dart';
import 'package:flutter/material.dart';
import 'screens/loginPage.dart';
import 'screens/passenger/mapPage.dart';
import 'screens/signup_screens/signupInfoPage.dart';
import 'screens/signup_screens/signupMobilePage.dart';
import 'screens/signup_screens/signupMobileVerifyPage.dart';
import 'screens/signup_screens/signupRegisterPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'BTSI TAXI',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        // backgroundColor: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
      ),
      // home: MainPage(),
      initialRoute: LoginPage.routeName,
      routes: {
        MainPage.routeName: (ctx) => MainPage(),
        LoginPage.routeName: (ctx) => LoginPage(),
        SignupSelectionPage.routeName: (ctx) => SignupSelectionPage(),
        SignupMobilePage.routeName: (ctx) => SignupMobilePage(),
        SignupMobileVerifyPage.routeName: (ctx) => SignupMobileVerifyPage(),
        SignupInfoPage.routeName: (ctx) => SignupInfoPage(),
        SignupRegisterPage.routeName: (ctx) => SignupRegisterPage(),
        MapPage.routeName: (ctx) => MapPage(),
        DriverMainPage.routeName: (ctx) => DriverMainPage(),
        OperatorMainPage.routeName: (ctx) => OperatorMainPage(),
        ForgotPasswordPage.routeName: (ctx) => ForgotPasswordPage(),
        ConfirmOTPPage.routeName: (ctx) => ConfirmOTPPage(),
        ResetPasswordPage.routeName: (ctx) => ResetPasswordPage()
      },
    );
  }
}
