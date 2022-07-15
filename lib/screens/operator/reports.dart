import 'dart:convert';
import 'dart:io';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/snackBar.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/Utility/widgets/textFormFields.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ReportsPage extends StatefulWidget {
  final globalToken;
  const ReportsPage({Key? key, required this.globalToken}) : super(key: key);

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool _isLoading = true;
  var reportData = [];
  final TextEditingController fromCtrl = new TextEditingController();
  final TextEditingController toCtrl = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  initializeValue() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    initializeValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  IconButton(
                    icon: new Icon(Icons.close_sharp, color: genSecondColor, size: 30,),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Reports",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading ? Center(child: CircularProgressIndicator()) :
              reportData.isEmpty ? Center(child: noReportsLog()) :Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: reportData.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(top: 10.0),
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Driver Name: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: reportData[index]['diver_name'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Driver license: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: reportData[index]['driver_license'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Plate No: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: reportData[index]['plate_no'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Passenger Count: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: reportData[index]['passenger_count'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Rating: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: reportData[index]['rating'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Date: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: reportData[index]['date'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ]
                              )
                            )
                          )
                        ]
                      )
                    );
                  },
                ),
              )
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.4,
              color: Colors.grey[300],
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormFieldGen(
                              controller: fromCtrl,
                              labelText: "From",
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
                                fromCtrl.text = DateFormat("yyyy-MM-dd").format(date!).toString();
                              },
                            ),
                            TextFormFieldGen(
                              controller: toCtrl,
                              labelText: "To",
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
                                toCtrl.text = DateFormat("yyyy-MM-dd").format(date!).toString();
                              },
                            ),
                          ]
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: ButtonSolid(
                        text: "Generate",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            generateReport();
                          }
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: ButtonOutline(
                        text: "Download",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            downloadReport();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container noReportsLog() {
    return Container(
      child: Text(
        "No reports available",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
      ),
    );
  }

  generateReport(){
    Map <String, dynamic> data = {
      "start_date": fromCtrl.text,
      "end_date": toCtrl.text
    };
    print(data);
    var url = Uri.parse(domainBackend + "/api/reports/bookings");
    url = url.replace(queryParameters: data);
    setState(() => _isLoading = true);

    http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: 'Bearer '+widget.globalToken},
    ).then((response) {
      print(response.statusCode);
      print(response.body);
      if (response.statusCode != 500) {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);

        if (response.statusCode >= 200 && response.statusCode <= 299) {
          if(jsonResponse != null) {
            reportData = jsonResponse;
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

  downloadReport(){
    Map <String, dynamic> data = {
      "start_date": fromCtrl.text,
      "end_date": toCtrl.text
    };
    var url = Uri.parse(domainBackend + "/booking/download-pdf");
    url = url.replace(queryParameters: data);
    setState(() => _isLoading = true);

    http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: 'Bearer '+widget.globalToken}
    ).then((response) async {
      print(response.statusCode);
      print(response.body);
      print(response.contentLength);
      print(response.bodyBytes);

      Directory? tempDir = await getExternalStorageDirectory();
      String? tempPath = tempDir?.path;
      // String tempPath = "/storage/emulated/0/Download";
      print("tempPath");
      print(tempPath);
      File file = new File('$tempPath/reports.pdf');
      await file.writeAsBytes(response.bodyBytes);
      await file.readAsBytes();
      print(file);
      print(file.path);
      // displayImage(file);
      // if (response.statusCode != 500) {
      //   var jsonResponse = json.decode(response.body);
      //   print(jsonResponse);
      //
      //   if (response.statusCode >= 200 && response.statusCode <= 299) {
      //     if(jsonResponse != null) {
      //       // reportData = jsonResponse;
      //     } else {
      //       notify(context, "No respond");
      //     }
      //   } else {
      //     notify(context, "Invalid credentials");
      //   }
      // } else {
      //   notify(context, "server error, check the mobile number field or try again later");
      // }
      notify(context, "File save on $tempPath/reports.pdf");
      setState(() => _isLoading = false);
    });
  }
}
