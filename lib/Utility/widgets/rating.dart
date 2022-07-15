import 'package:flutter/material.dart';

import '../colors.dart';

class RatingStars extends StatefulWidget {
  final Function callback;
  const RatingStars({Key? key, required this.callback}) : super(key: key);

  @override
  _RatingStars createState() => _RatingStars();
}

class _RatingStars extends State<RatingStars> {
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: <Widget>[
        IconButton(
          icon: new Icon( rating >= 1 ? Icons.star : Icons.star_border, color: genSecondColor, size: 50,),
          onPressed: () {
            rating = 1;
            widget.callback(rating);
            setState(() {});
          },
        ),
        IconButton(
          icon: new Icon(rating >= 2 ? Icons.star : Icons.star_border, color: genSecondColor, size: 50,),
          onPressed: () {
            rating = 2;
            widget.callback(rating);
            setState(() {});
          },
        ),
        IconButton(
          icon: new Icon(rating >= 3 ? Icons.star : Icons.star_border, color: genSecondColor, size: 50,),
          onPressed: () {
            rating = 3;
            widget.callback(rating);
            setState(() {});
          },
        ),
        IconButton(
          icon: new Icon(rating >= 4 ? Icons.star : Icons.star_border, color: genSecondColor, size: 50,),
          onPressed: () {
            rating = 4;
            widget.callback(rating);
            setState(() {});
          },
        ),
        IconButton(
          icon: new Icon(rating >= 5 ? Icons.star : Icons.star_border, color: genSecondColor, size: 50,),
          onPressed: () {
            rating = 5;
            widget.callback(rating);
            setState(() {});
          },
        )
      ],
    );
  }
}