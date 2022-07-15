import 'dart:convert';
import 'dart:io';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DriverRatingAndComments extends StatefulWidget {
  final globalToken;
  final driverId;
  const DriverRatingAndComments({Key? key, required this.driverId, required this.globalToken}) : super(key: key);

  @override
  _DriverRatingAndCommentsState createState() => _DriverRatingAndCommentsState();
}

class _DriverRatingAndCommentsState extends State<DriverRatingAndComments> {
  bool _isLoading = true;
  var reviewData = [];


  initializeValue() {
    var url = Uri.parse(domainBackend + "/api/driver/"+widget.driverId+"/booking");

    http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: 'Bearer '+widget.globalToken},
    ).then((response) {
      print(response.statusCode);
      print(response.body);
      setState(() {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey("data") && response.statusCode == 200) {
          reviewData = jsonResponse['data'];
        }
        _isLoading = false;
      });
    });
    print(reviewData);
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
                    "Drivers Activity Logs",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading ? Center(child: CircularProgressIndicator()) :
              reviewData.isEmpty ? Center(child: noActivitylog()) : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: reviewData.length,
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
                                  // TextSpan(
                                  //   text: reviewData[index]['passenger']['fname'].toString() + " " +
                                  //       reviewData[index]['passenger']['lname'].toString() + "\n\n",
                                  //   style: TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //     color: genPrimaryColor,
                                  //     fontSize: 25.0,
                                  //   ),
                                  // ),
                                  TextSpan(
                                    text: "Pick-up Location: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: reviewData[index]['pick_up_location'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Drop-off Location: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: reviewData[index]['drop_off_location'].toString() + "\n\n",
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
                                    text: reviewData[index]['passenger_count'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  if (reviewData[index]['rating'] != null) TextSpan(
                                    text: "Rating: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  if (reviewData[index]['rating'] != null) TextSpan(
                                    text: ratings[reviewData[index]['rating'].toString()].toString()  + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  if (reviewData[index]['comments'] != null) TextSpan(
                                    text: "Comment: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  if (reviewData[index]['comments'] != null) TextSpan(
                                    text: reviewData[index]['comments'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container noActivitylog() {
    return Container(
      child: Text(
        "No Reviews yet.",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
      ),
    );
  }
}
