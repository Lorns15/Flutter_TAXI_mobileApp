
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/paints/backgroundPaint.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/Utility/widgets/logo.dart';
import 'package:btsi_taxi/Utility/widgets/textFormFields.dart';
import 'package:btsi_taxi/screens/signup_screens/signupRegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SignupInfoPage extends StatefulWidget {
  static const routeName = '/signupInfoPage';
  @override
  _SignupInfoPageState createState() => _SignupInfoPageState();
}

class _SignupInfoPageState extends State<SignupInfoPage> {

  bool _isLoading = false;

  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController birthdayController = new TextEditingController();
  final TextEditingController addressController = new TextEditingController();
  final TextEditingController driveLicenseController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        child: _isLoading ? Center(child: CircularProgressIndicator()) : CustomPaint(
          painter: BackgroundPainter(),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // SizedBox(height: 110.0),
              Logo(),
              // SizedBox(height: 30.0),
              textSection(),
              buttonSection(),
            ],
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
      margin: EdgeInsets.only(top: 15.0),
      child: ButtonSolid(
        onPressed: () async {
          if (lastNameController.text.isEmpty || firstNameController.text.isEmpty
              || birthdayController.text.isEmpty || addressController.text.isEmpty
              || driveLicenseController.text.isEmpty) {
            print("please enter information");
          } else {
            setState(() => _isLoading = true);
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            setState(() => _isLoading = false);
            print("sharedPreferences info page");
            sharedPreferences.setString("lname", lastNameController.text);
            sharedPreferences.setString("fname", firstNameController.text);
            sharedPreferences.setString("bday", birthdayController.text);
            sharedPreferences.setString("address", addressController.text);
            sharedPreferences.setString("driver_license", driveLicenseController.text);
            sharedPreferences.setString("email", emailController.text);
            print("sharedPreferences info page end");
            Navigator.of(context).pushNamed(SignupRegisterPage.routeName);
          }
        },
        text: "NEXT",

      ),
    );
  }



  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormFieldGen(
            controller: lastNameController,
            labelText: "Lastname",
            icon: const Icon(Icons.account_box),
          ),
          SizedBox(height: 10.0),
          TextFormFieldGen(
            controller: firstNameController,
            labelText: "Firstname",
            icon: const Icon(Icons.account_box),
          ),
          SizedBox(height: 10.0),
          TextFormFieldGen(
            controller: birthdayController,
            labelText: "Birthdate",
            icon: const Icon(Icons.date_range),
            keyboardType: TextInputType.datetime,
            onTap: () async{
              FocusScope.of(context).requestFocus(new FocusNode());


              DateTime? date = await showDatePicker(
                  context: context,
                  initialDate:DateTime.now(),
                  firstDate:DateTime(1900),
                  lastDate: DateTime.now()
              );
              print(date.toString());

              if (date.toString() == "null") {
                date = DateTime.now();
              }

              birthdayController.text = DateFormat("yyyy-MM-dd").format(date!).toString();
              },
          ),
          SizedBox(height: 10.0),
          TextFormFieldGen(
            controller: addressController,
            labelText: "Address",
            icon: const Icon(Icons.location_pin),
          ),
          SizedBox(height: 10.0),
          TextFormFieldGen(
            controller: driveLicenseController,
            labelText: "Driver license",
            icon: const Icon(Icons.card_membership),
          ),
          SizedBox(height: 10.0),
          TextFormFieldGen(
            controller: emailController,
            labelText: "Email",
            icon: const Icon(Icons.email),
          ),
        ],
      ),
    );
  }
}