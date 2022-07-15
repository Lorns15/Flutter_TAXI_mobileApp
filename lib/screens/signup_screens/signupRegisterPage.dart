
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
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';



class SignupRegisterPage extends StatefulWidget {
  static const routeName = '/signupRegisterPage';
  @override
  _SignupRegisterPageState createState() => _SignupRegisterPageState();
}

class _SignupRegisterPageState extends State<SignupRegisterPage> {

  bool _isLoading = true;
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController confirmPasswordController = new TextEditingController();

  final TextEditingController lastNameController = new TextEditingController();
  final TextEditingController firstNameController = new TextEditingController();
  final TextEditingController birthdayController = new TextEditingController();
  final TextEditingController addressController = new TextEditingController();
  final TextEditingController driveLicenseController = new TextEditingController();
  final TextEditingController plateNumberController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  // final TextEditingController plateNoController = new TextEditingController();

  late SharedPreferences sharedPreferences;
  final _formKey = GlobalKey<FormState>();

  late File imageFile;

  Future pickImage() async{
    try{
      final image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: 200.0,
          maxHeight: 100.0,
          imageQuality: 20
      );
      if (image == null) return;
      print("image");
      print(image.path);
      print(image.name);
      final imageTemp = File(image.path);
      this.imageFile = imageTemp;
    } on PlatformException catch (e) {
      print("Failed tp pick image: $e");
    }

  }

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
    // _isLoading = false;
    // imageFile = File("images/original logo.jpg");
    // print(imageFile);
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
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            sharedPreferences.setString("password", passwordController.text);
            print("dito");
            var token = sharedPreferences.getString("otp_token");
            print(token);
            setState(() => _isLoading = true);

            if (sharedPreferences.getString("role") == "driver") {
              Map<String,String> headers={
                "Authorization":"Bearer $token",
                "Content-type": "multipart/form-data"
              };
              var postUri = Uri.parse(domainBackend + "/api/auth/register-update");
              http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
              print("imageFile.path");
              print(imageFile.path);

              http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
                  "driver_license_photo", imageFile.path);
              request.files.add(multipartFile);
              request.headers.addAll(headers);
              request.fields.addAll({
                "_method": "PUT",
                "lname": lastNameController.text,
                "fname": firstNameController.text,
                "bday": birthdayController.text,
                "address": addressController.text,
                "driver_license": driveLicenseController.text,
                "plate_no": plateNumberController.text,
                "email": emailController.text,
                "password": passwordController.text
              });
              await request.send().then((value) {
                print(value.statusCode);
                if (value.statusCode >= 200 && value.statusCode <= 299) {
                  Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.routeName, (route) => false);
                } else {
                  notify(context, "No respond");
                }
              }).catchError((e){
                print(e.toString());
                notify(context, "No respond, please check the image size");
              });

              setState(() => _isLoading = false);
            } else if (sharedPreferences.getString("role") == "passenger") {
              Map data = {
                "lname": lastNameController.text,
                "fname": firstNameController.text,
                "bday": birthdayController.text,
                "address": addressController.text,
                "driver_license": driveLicenseController.text,
                "email": emailController.text,
                "password": passwordController.text
              };

              http.put(
                Uri.parse(domainBackend + "/api/auth/register-update"),
                headers: {
                  HttpHeaders.authorizationHeader: 'Bearer $token',
                },
                body: data,
              ).then((response) {
                print(response.statusCode);

                if (response.statusCode != 500) {
                  var jsonResponse = json.decode(response.body);
                  print(jsonResponse);

                  if (response.statusCode >= 200 && response.statusCode <= 299) {
                    if(jsonResponse != null) {
                      notify(context, "Registerion complete");
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





          }
        },
        text: "REGISTER",

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
              controller: lastNameController,
              labelText: "Lastname",
              icon: const Icon(Icons.account_box),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field';
                } else if (value.toString().length < 2
                || value.toString().length > 100) {
                  return 'Must be between 2 and 100 characters';
                }
                return null;
              },
            ),
            // SizedBox(height: 20.0),
            TextFormFieldGen(
              controller: firstNameController,
              labelText: "Firstname",
              icon: const Icon(Icons.account_box),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field';
                } else if (value.toString().length < 2
                    || value.toString().length > 100) {
                  return 'Must be between 2 and 100 characters';
                }
                return null;
              },
            ),
            // SizedBox(height: 20.0),
            TextFormFieldGen(
              controller: birthdayController,
              labelText: "Birthdate",
              icon: const Icon(Icons.date_range),
              keyboardType: TextInputType.datetime,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field';
                }
                return null;
              },
              onTap: () async{
                FocusScope.of(context).requestFocus(new FocusNode());
                var dateNow = DateFormat("yyyy-MM-dd").format(DateTime.now()).toString();
                var year = int.parse(dateNow.substring(0, 4));
                var month = int.parse(dateNow.substring(5, 7));
                var day = int.parse(dateNow.substring(8));
                var legalDate = DateTime(year-18, month, day);

                DateTime? date = await showDatePicker(

                    context: context,

                    initialDate:legalDate,
                    firstDate:DateTime(1900),
                    lastDate: legalDate
                );
                print(date.toString());

                if (date.toString() == "null") {
                  date = legalDate;
                }

                birthdayController.text = DateFormat("yyyy-MM-dd").format(date!).toString();
              },
            ),
            // SizedBox(height: 20.0),
            TextFormFieldGen(
              controller: addressController,
              labelText: "Address",
              icon: const Icon(Icons.location_pin),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field';
                } else if (value.toString().length < 2
                    || value.toString().length > 100) {
                  return 'Must be between 2 and 100 characters';
                }
                return null;
              },
            ),
            // SizedBox(height: 20.0),

            // if (sharedPreferences.getString("role") == "driver")
              (sharedPreferences.getString("role") == "driver") ? TextFormFieldGen(
                controller: driveLicenseController,
                labelText: "Driver license",
                icon: const Icon(Icons.card_membership),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please fill out this field';
                  }
                  return null;
                },
              ):TextFormFieldGen(
                controller: emailController,
                labelText: "Email",
                icon: const Icon(Icons.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please fill out this field';
                  } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                    return 'The email must be a valid email address.';
                  }
                  return null;
                },
              ),
            if (sharedPreferences.getString("role") == "driver") Container(
              width: MediaQuery.of(context).size.width,
              height: 60.0,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: ButtonOutline(
                onPressed: () => pickImage(),
                text: 'upload Driver license Image \n(NOTE* Image should only 2mb max.)',
              ),
            ),
            if (sharedPreferences.getString("role") == "driver") TextFormFieldGen(
              controller: plateNumberController,
              labelText: "Plate number",
              icon: const Icon(Icons.code),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please fill out this field';
                } else if (!RegExp(r"[a-zA-Z]").hasMatch(value)) {
                  return 'Invalid!';
                } else if (!RegExp(r"[0-9]").hasMatch(value)) {
                  return 'Invalid!';
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
                } else if (value.toString().length < 6) {
                  return 'The password must be at least 6 characters.';
                }
                return null;
              },
            ),
            // SizedBox(height: 20.0),
            // TextFormFieldGen(
            //   controller: confirmPasswordController,
            //   labelText: "Confirm Password",
            //   obscureText: true,
            //   icon: const Icon(Icons.lock),
            // ),
          ],
        ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 15.0),
      child: Text('Please fill out the required fields below and click on the "Register"',
        style: TextStyle( fontWeight: FontWeight.bold, color: genThirdColor),
      ),
    );
  }
}