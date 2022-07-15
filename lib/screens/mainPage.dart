// import 'dart:js';

import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/screens/loginPage.dart';
import 'package:btsi_taxi/screens/signup_screens/signupSelectionPage.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

import 'package:google_place/google_place.dart';

class MainPage extends StatefulWidget  {
  static const routeName = '/mainPage';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // var ulrAPI = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Food%20Sh&sensor=false&radius=500&location=0,0&key=AIzaSyBcWLEsLk_sGziqi6j0AYqX0D-3nQZLuxw";
  // static const kGoogleApiKey = "AIzaSyCbvN4zL-wtPeJ-1AWIN1Ath9frpRJOwnk";

  var googlePlace = GooglePlace(kGoogleApiKey);
  List<AutocompletePrediction> predictions = [];
  late DetailsResult detailsResult;

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    print(value);
    if (result != null && result.predictions != null && mounted) {
      print(result.status);
      setState(() {
        predictions = result.predictions!;
        print(predictions);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: "Search",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    if (predictions.length > 0 && mounted) {
                      setState(() {
                        predictions = [];
                      });
                    }
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(predictions[index].description.toString()),
                      onTap: () {
                        debugPrint(predictions[index].reference);
                        getDetails(predictions[index].placeId.toString());
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => DetailsPage(
                        //       placeId: predictions[index].placeId,
                        //       googlePlace: googlePlace,
                        //     ),
                        //   ),
                        // );
                      },
                    );
                  },
                ),
              ),
              // Container(
              //   margin: EdgeInsets.only(top: 10, bottom: 10),
              //   child: Image.asset("assets/powered_by_google.png"),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void getDetails(String placeId) async {
    var result = await this.googlePlace.details.get(placeId);
    if (result != null && result.result != null && mounted) {
      setState(() {
        detailsResult = result.result!;
        print(detailsResult.geometry!.location!.lat.toString());
        print(detailsResult.geometry!.location!.lng.toString());

      });
    }
  }




  Container buttonSection(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            child: ButtonSolid(
              onPressed: () {
                Navigator.of(context).pushNamed(LoginPage.routeName);
              },
              text: "LOGIN",
            ),
          ),
          SizedBox(height: 15.0),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            child: ButtonOutline(
              onPressed: () {
                Navigator.of(context).pushNamed(SignupSelectionPage.routeName);
              },
              text: "SIGNUP",
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("BTSI TAXI Logo",
          style: TextStyle(
            // color: Colors.white70,
              fontSize: 50.0,
              fontWeight: FontWeight.bold)),
    );
  }

}