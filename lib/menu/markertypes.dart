import 'package:fiberapp/MapFunctions/markercrud.dart';
import 'package:fiberapp/menu/iconscategory.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

IconsCategory iconscategory = IconsCategory();

class Markertypes extends StatefulWidget {
  const Markertypes({Key? key}) : super(key: key);

  @override
  _MarkertypesState createState() => _MarkertypesState();
}

class _MarkertypesState extends State<Markertypes> {
  Location location = new Location();
  void selectmarker(String? marker) {
    setState(() {
      switchscreen!.currentmarker = marker;
    });
  }

  Future<String?> onMarkerType(String? marker) async {
    setState(() {
      switchscreen?.markercurrenttype = marker;
      int i = 0;
      bool condition = true;
      for (var item in iconscategory.categories1) {
        if (marker == item && condition) {
          switchscreen!.currentmarkerslist = iconscategory.categorieslist[i];
          switchscreen!.currentmarker = switchscreen!.currentmarkerslist[0];
          condition = false;
        }
        i = i + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 15,
        ),
        DropdownSearch<String>(
          mode: Mode.DIALOG,
          items: iconscategory.categories,
          label: "Select Category",
          onChanged: onMarkerType,
          selectedItem: switchscreen?.markercurrenttype,
          showSearchBox: true,
          showClearButton: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
              labelText: "Search Category",
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
        SizedBox(height: 10),
        DropdownSearch<String>(
          mode: Mode.DIALOG,
          items: switchscreen?.currentmarkerslist,
          label: "Select Symbol",
          onChanged: selectmarker,
          selectedItem: switchscreen!.currentmarker,
          showSearchBox: true,
          showClearButton: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
              labelText: "Search Sybmol",
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
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: Image(
                image: AssetImage(
                    'asset/images/OFC/${switchscreen!.currentmarker}.png'),
                height: 50,
                width: 70,
              ),
              onTap: () async {
                var locationData = await location.getLocation();
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => new AlertDialog(
                    content: TextField(
                      controller: switchscreen?.icondetails,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Icon Details'),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                          onPressed: () async {
                            MarkerCrud markerCrud = MarkerCrud();
                            markerCrud.addMarker(
                                LatLng(locationData.latitude!,
                                    locationData.longitude!),
                                switchscreen?.icondetails.text,
                                switchscreen!.id,
                                switchscreen!.currentmarker,
                                context);
                            Navigator.of(context).pop();
                            switchscreen?.icondetails.text = '';
                          },
                          child: Text('Insert')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'))
                    ],
                  ),
                );
              },
            ),
          ],
        )
      ],
    );
  }
}
