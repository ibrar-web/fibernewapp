import 'package:fiberapp/MapFunctions/markercrud.dart';
import 'package:fiberapp/menu/iconscategory.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

IconsCategory iconscategory = IconsCategory();

class UpdateMarker extends StatefulWidget {
  final LatLng? markerposition;
  final int? id;
  final MarkerId? markerid;
  const UpdateMarker({Key? key, this.markerposition, this.id, this.markerid})
      : super(key: key);

  @override
  _UpdateMarkerState createState() =>
      _UpdateMarkerState(markerposition, id, markerid);
}

class _UpdateMarkerState extends State<UpdateMarker> {
  _UpdateMarkerState(this.markerposition, this.id, this.markerid);
  LatLng? markerposition;
  int? id;
  MarkerId? markerid;
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
          mode: Mode.BOTTOM_SHEET,
          items: iconscategory.categories,
          label: "Selected Icon Type",
          onChanged: onMarkerType,
          selectedItem: switchscreen?.markercurrenttype,
          showSearchBox: true,
          showClearButton: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
              labelText: "Search Icon Type",
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
          mode: Mode.BOTTOM_SHEET,
          items: switchscreen?.currentmarkerslist,
          label: "Selected Marker",
          onChanged: selectmarker,
          selectedItem: switchscreen!.currentmarker,
          showSearchBox: true,
          showClearButton: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
              labelText: "Search Icon",
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
                showDialog(
                  context: context,
                  builder: (context) => new AlertDialog(
                    actions: <Widget>[
                      Column(
                        children: [
                          TextField(
                            controller: switchscreen?.icondetails,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter Icon Details'),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                MarkerCrud markerCrud = MarkerCrud();

                                for (int i = 0;
                                    i < switchscreen!.markerposition!.length;
                                    i++) {
                                  if (switchscreen!.markerposition![i]['id'] ==
                                      id) {
                                    switchscreen!.markerposition!.removeAt(i);
                                  }
                                }
                                setState(() =>
                                    switchscreen!.markers.remove(markerid));
                                markerCrud.replacemarker(
                                    LatLng(markerposition!.latitude,
                                        markerposition!.longitude),
                                    switchscreen?.icondetails.text,
                                    id!,
                                    context);
                                Navigator.of(context).pop();
                              },
                              child: Text('Update'))
                        ],
                      )
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
