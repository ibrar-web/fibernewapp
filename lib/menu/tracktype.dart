import 'package:fiberapp/MapFunctions/drawpolyline.dart';
import 'package:fiberapp/MapFunctions/markercrud.dart';
import 'package:fiberapp/menu/iconscategory.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:location/location.dart';

IconsCategory iconscategory = IconsCategory();
Drawpolyline drawpolyline = Drawpolyline();
MarkerCrud markercrud = MarkerCrud();

class Tracktype extends StatefulWidget {
  const Tracktype({Key? key}) : super(key: key);

  @override
  _TracktypeState createState() => _TracktypeState();
}

class _TracktypeState extends State<Tracktype> {
  Location location = new Location();
  void selectmarker(String? marker) {
    setState(() {
      switchscreen!.currentmarker = marker;
    });
  }

  Future<String?> onTrackType(List<String> tracktype) async {
    if (tracktype.isEmpty) {
      return null;
    }
    switchscreen!.removelinemarker();
    setState(() {
      if (switchscreen!.uploadtrackpre!.length > 0) {
        switchscreen!.uploadtrack!.add({
          'data': switchscreen!.uploadtrackpre,
          'shape': switchscreen!.trackshape,
          'color': switchscreen!.trackcolor,
          'width': switchscreen!.trackwidth,
          'name': switchscreen?.trackcurrenttype,
        });
        switchscreen!.uploadtrackpre = [];
      }
      switchscreen?.trackcurrenttype = [];
    });
    for (int i = 0; i < Tracks.instance.categories.length; i++) {
      if (tracktype.contains(Tracks.instance.categories[i])) {
        markercrud.newsubtrack();
        setState(() {
          switchscreen?.trackcurrenttype = tracktype;
          switchscreen!.polylineIdCounter++;
          switchscreen!.linepoints = [];
          switchscreen!.trackcolor = i;
          switchscreen!.trackshape = i;
          switchscreen!.trackwidth = i;
          if (tracktype.length > 1) {
            switchscreen!.trackcolor = 22;
            switchscreen!.trackshape = 22;
            switchscreen!.trackwidth = 22;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: Navigator.of(context).pop,
          child: Text(
            'Close',
          ),
        ),
        SizedBox(
          height: 15,
        ),
        DropdownSearch<String>.multiSelection(
          mode: Mode.BOTTOM_SHEET,
          items: Tracks.instance.categories,
          label: "Selected Track Type",
          onChanged: onTrackType,
          selectedItems: switchscreen!.trackcurrenttype,
          showSearchBox: true,
          showClearButton: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
              labelText: "Search Track Type",
            ),
          ),
          popupTitle: Container(
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          popupShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Track Color : ",
            ),
            Text(
              "----------",
              style: TextStyle(
                  color: switchscreen!.colors[switchscreen!.trackcolor],
                  fontSize: 40),
            ),
          ],
        )
      ],
    );
  }
}
