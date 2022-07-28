import 'package:fiberapp/screenrendring.dart';
import 'package:fiberapp/screens/homescreen.dart';
import 'package:flutter/material.dart';

class Maptypes extends StatefulWidget {
  const Maptypes({Key? key}) : super(key: key);

  @override
  _MaptypesState createState() => _MaptypesState();
}

class _MaptypesState extends State<Maptypes> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: MediaQuery.of(context).size.height * .3,
        width: MediaQuery.of(context).size.width * .4,
        child: Column(
          children: [
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Radio(
                    value: 1,
                    groupValue: switchscreen!.mapnumber,
                    onChanged: homescreenvar!.onMapTypeButtonPressed),
                new Text(
                  'Normal',
                  style: new TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Radio(
                    value: 2,
                    groupValue: switchscreen!.mapnumber,
                    onChanged: homescreenvar!.onMapTypeButtonPressed),
                new Text(
                  'Satellite',
                  style: new TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Radio(
                    value: 3,
                    groupValue: switchscreen!.mapnumber,
                    onChanged: homescreenvar!.onMapTypeButtonPressed),
                new Text(
                  'Hybrid',
                  style: new TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Radio(
                    value: 4,
                    groupValue: switchscreen!.mapnumber,
                    onChanged: homescreenvar!.onMapTypeButtonPressed),
                new Text(
                  'Terrain',
                  style: new TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: new Text("Close"),
        ),
      ],
    );
  }
}
