import 'package:flutter/material.dart';

class NumberInputWithIncrementDecrement extends StatefulWidget {
  final Function callback;
  const NumberInputWithIncrementDecrement({Key? key, required this.callback}) : super(key: key);

  @override
  _NumberInputWithIncrementDecrementState createState() => _NumberInputWithIncrementDecrementState();
}

class _NumberInputWithIncrementDecrementState extends State<NumberInputWithIncrementDecrement> {
  int _itemCount = 1;

  @override
  Widget build(BuildContext context) {
    return  Row(
        children: <Widget>[
          IconButton(icon: Icon(Icons.remove),
            onPressed: () {
              if (_itemCount>1) {
                setState(() => _itemCount--);
                widget.callback(_itemCount);
              }
            },
          ),
          Text(
            _itemCount.toString(),
            style: TextStyle(
                fontSize: 25,
            ),
          ),
          IconButton(icon: Icon(Icons.add),
            onPressed: () {
              if (_itemCount<3) {
                setState(() => _itemCount++);
                widget.callback(_itemCount);
              }
            },
          ),
        ],
    );
  }
}