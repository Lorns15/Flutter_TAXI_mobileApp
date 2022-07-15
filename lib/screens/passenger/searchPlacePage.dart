import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/widgets/textFormFields.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class SearchPlacePage extends StatefulWidget {
  final Function callback;
  const SearchPlacePage({Key? key, required this.callback}) : super(key: key);


  @override
  _SearchPlacePageState createState() => _SearchPlacePageState();
}

class _SearchPlacePageState extends State<SearchPlacePage> {
  var googlePlace = GooglePlace(kGoogleApiKey);
  List<AutocompletePrediction> predictions = [];
  late DetailsResult detailsPlaceResult;


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

  void getDetails(String placeId) async {
    var result = await this.googlePlace.details.get(placeId);
    if (result != null && result.result != null && mounted) {
      setState(() {
        detailsPlaceResult = result.result!;
        // print(detailsPlaceResult.geometry!.location!.lat.toString());
        // print(detailsPlaceResult.geometry!.location!.lng.toString());
        widget.callback(detailsPlaceResult);
        Navigator.pop(context);
      });
    }
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
                    "Your journey",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
                  ),
                ],
              ),
            ),
            TextFormFieldGen(
              labelText: "Where do you want to go?",
              icon: const Icon(Icons.location_pin),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.pin_drop,
                        ),
                      ),
                      title: Text(predictions[index].description.toString()),
                      onTap: () {
                        debugPrint(predictions[index].reference);
                        getDetails(predictions[index].placeId.toString());
                      },
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
}
