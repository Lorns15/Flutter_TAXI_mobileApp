import 'dart:convert';
import 'dart:io';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingHistoryPage extends StatefulWidget {
  final token;
  const BookingHistoryPage({Key? key, required this.token}) : super(key: key);

  @override
  _BookingHistoryPageState createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  var bookings = [];
  bool _isLoading = true;

  initializeValue() {
    var url = Uri.parse(domainBackend + "/api/driver/booking_history");

    http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: 'Bearer '+widget.token},
    ).then((response) {
      print(response.statusCode);
      print(response.body);
      setState(() {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey("data") && response.statusCode == 200) {
          bookings = jsonResponse['data'];
          _isLoading = false;
        }
      });
    });
    print(bookings);
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
                    "Booking History",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading ? Center(child: CircularProgressIndicator()) :
              bookings.isEmpty ? Center(child: noAvailableBooking()) : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    return Card(
                        elevation: 5,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: horizontalPadding),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Time: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: genThirdColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                                TextSpan(
                                  text: bookings[index]['created_at'].toString() + "\n\n",
                                  style: TextStyle(
                                    color: genThirdColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                                TextSpan(
                                  text: "Pick-Up Location: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: genThirdColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                                TextSpan(
                                  text: bookings[index]['pick_up_location'].toString() + "\n\n",
                                  style: TextStyle(
                                    color: genThirdColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                                TextSpan(
                                  text: "Drop-Off Location: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: genThirdColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                                TextSpan(
                                  text: bookings[index]['drop_off_location'].toString()  + "\n\n",
                                  style: TextStyle(
                                    color: genThirdColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                                if (bookings[index]['rating'] != null) TextSpan(
                                  text: "Rating: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: genThirdColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                                if (bookings[index]['rating'] != null) TextSpan(
                                  text: ratings[bookings[index]['rating'].toString()].toString()  + "\n\n",
                                  style: TextStyle(
                                    color: genThirdColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                                if (bookings[index]['comments'] != null) TextSpan(
                                  text: "Comment: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: genThirdColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                                if (bookings[index]['comments'] != null) TextSpan(
                                  text: bookings[index]['comments'].toString() + "\n\n",
                                  style: TextStyle(
                                    color: genThirdColor,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
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

  Container noAvailableBooking() {
    return Container(
      child: Text(
        "No Available Booking.",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
      ),
    );
  }
}
