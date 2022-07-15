import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/paints/backgroundPaint.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/Utility/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../loginPage.dart';
import 'signupMobilePage.dart';

class SignupSelectionPage extends StatelessWidget  {
  static const routeName = '/signupSelectionPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: CustomPaint(
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
                buttonSection(context),
                Container(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: (){
                      Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.routeName, (route) => false);
                    },
                    child: RichText(
                      text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "Already have a account? ",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15.0,
                              ),
                            ),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: genThirdColor,
                                fontSize: 15.0,
                              ),
                            ),
                          ]
                      ),
                    ),
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

  Container buttonSection(context) {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            child: ButtonSolid(
              onPressed: () async {
                Navigator.of(context).pushNamed(SignupMobilePage.routeName);
                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.setString("role", "passenger");
              },
              text: "PASSENGER",
            ),
          ),
          SizedBox(height: 15.0),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            child: ButtonOutline(
              onPressed: () async {
                Navigator.of(context).pushNamed(SignupMobilePage.routeName);
                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.setString("role", "driver");
              },
              text: "DRIVER",
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5.0),
      // child: RichText(
      //   text: TextSpan(
      //       children: <TextSpan>[
      //         TextSpan(
      //           text: "Please choose your ",
      //           style: TextStyle(color: Colors.black87, fontSize: 15.0,),
      //         ),
      //         TextSpan(
      //           text: "Account type",
      //           style: TextStyle(fontWeight: FontWeight.bold, color: genThirdColor, fontSize: 15.0,),
      //         ),
      //       ]
      //   ),
      // ),
      child: Text("Choose your account type",
        style: TextStyle(color: genThirdColor, fontSize: 17.0,),
      ),
    );
  }
}