// ignore_for_file: unnecessary_statements

import 'package:fiberapp/MapFunctions/drawpolyline.dart';
import 'package:fiberapp/MapFunctions/markercrud.dart';
import 'package:fiberapp/menu/iconscategory.dart';
import 'package:fiberapp/menu/tracktype.dart';
import 'package:fiberapp/screens/gallery.dart';
import 'package:fiberapp/screens/tracksgallery.dart';
import 'package:fiberapp/screens/homescreen.dart';
import 'package:fiberapp/screens/media.dart';
import 'package:fiberapp/screens/setting.dart';
import 'package:fiberapp/screens/tracks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carp_background_location/carp_background_location.dart';
import 'package:location/location.dart';

Drawpolyline drawpolyline = Drawpolyline();
_ScreenrendringState? switchscreen;
IconsCategory iconscategory = IconsCategory();

class Screenrendring extends StatefulWidget {
  const Screenrendring({Key? key}) : super(key: key);

  @override
  _ScreenrendringState createState() {
    switchscreen = _ScreenrendringState();
    return switchscreen!;
  }
}

class _ScreenrendringState extends State<Screenrendring> {
  MarkerCrud markerCrud = MarkerCrud();
  TextEditingController icondetails = TextEditingController(text: '');
  TextEditingController markercontroltime = TextEditingController(text: '');
  Location location = new Location();
  //use for setting time interval for adding marker
  int? time;
  String? trackname = '';
  String selectcity = 'Select City';
  String selectregion = 'Select Region';
  TextEditingController segmentname = TextEditingController();
  TextEditingController sectionname = TextEditingController();
  //use for check how to add marker
  int? markercontrol;
  String? screenname;
  bool startstop = false;
  MapType currentMapType = MapType.normal;
  int? mapnumber = 1;
  String? markercurrenttype = "Aerial";
  List<String> trackcurrenttype = ['2F CLT Aerial'];
  String? currentmarker = '';
  List<String> currentmarkerslist = [];
  Map<PolylineId, Polyline> mapPolylines = {};
  int polylineIdCounter = 1;
  List<LatLng> linepoints = <LatLng>[];
  List? uploadtrack = [];
  List? uploadtrackpre = [];
  List? markerposition = [];
  List? markerpositionpre = [];
  List? trackmedia = [];
  //use for marker inner distance calculations and contains markerid of previous and next distance marker
  List? markerdistancetrack = [];
  //used to keep all marker tracks
  List? allmarkerstrack = [];
  //use to keep currently added marker track
  List? currentmarkertrack = [];
  //use to keep currently added marker track
  int currentmarkertrackid = 0;
  double lat = 0;
  double long = 0;
  //use for checking in track if marker is last or not
  bool lastmarker = false;
  Map<MarkerId, Marker> markers = {};
  int id = 0;
  List previouseditableid = [];
  BitmapDescriptor? myIcon;
  Stream<LocationDto>? locationStream;
  // ignore: cancel_subscriptions
  StreamSubscription<LocationDto>? locationSubscription;
  int trackcolor = 0;
  int trackshape = 0;
  int trackwidth = 0;
  List patternsParam = [
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(5)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(5)],
    [PatternItem.dash(10), PatternItem.gap(5)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(5)],
    [PatternItem.dash(10), PatternItem.gap(5)],
    [PatternItem.dash(10), PatternItem.gap(5)],
    [PatternItem.dash(10), PatternItem.gap(5)],
    [PatternItem.dash(10), PatternItem.gap(5)],
    [PatternItem.dash(10), PatternItem.gap(5)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
    [PatternItem.dash(10), PatternItem.gap(0)],
  ];
  List linewidth = [
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7
  ];
  List<Color> colors = <Color>[
    Colors.grey.shade800,
    Colors.grey,
    Colors.blueGrey,
    Colors.grey.shade800,
    Colors.blue,
    Colors.grey,
    Colors.blueGrey,
    Colors.amber,
    Colors.brown,
    Colors.yellow,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.yellow.shade800,
    Colors.amber,
    Colors.brown,
    Colors.yellow,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.yellow.shade800,
    Colors.black,
    Colors.pink,
    Colors.pink.shade300,
    Colors.black,
  ];

  List<dynamic> detailsmarker = [
    'Comment1',
    'Comment2',
    'Comment3',
    'Comment4',
    'Comment5',
  ];
  var pointinfo = [];
  var dropdownval = '';
  void updatedata() {
    setState(() {
      markers = markers;
      icondetails = icondetails;
      id = id + 1;
      markerdistancetrack = markerdistancetrack;
      markerposition = markerposition;
    });
    return null;
  }

  void updatedatalinemarker() {
    setState(() {
      for (int i = 0; i < previouseditableid.length; i++) {
        markers.remove(MarkerId(previouseditableid[i]));
        previouseditableid.removeAt(i);
      }
      markers = markers;
      icondetails = icondetails;
      previouseditableid.add(id.toString());
      id = id + 1;
      markerdistancetrack = markerdistancetrack;
      markerposition = markerposition;
    });
    return null;
  }

  void removelinemarker() {
    setState(() {
      for (int i = 0; i < previouseditableid.length; i++) {
        markers.remove(MarkerId(previouseditableid[i]));
        previouseditableid.removeAt(i);
      }
    });
  }

  void updatetrackline() {
    setState(() {
      mapPolylines = mapPolylines;
    });
    return null;
  }

  void onMarkerTapped(
      MarkerId markerId, int positionid, LatLng position) async {
    String info = '';
    for (int i = 0; i < markerposition!.length; i++) {
      if (markerposition![i]['id'] == positionid) {
        setState(() {
          info = markerposition![i]['detail'][0]['name'];
        });
      }
    }

    MarkerCrud markerCrud = MarkerCrud();
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      context: context,
      pageBuilder: (_, __, ___) {
        return markerCrud.markerupdateshowdialogueinner(
            markerId, positionid, position, context, info);
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  void infoUpdate(int id, String info) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Old Info : $info"),
        content: TextField(
          controller: switchscreen?.icondetails,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Enter Icon Details'),
        ),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                for (int i = 0; i < markerposition!.length; i++) {
                  if (markerposition![i]['id'] == id) {
                    setState(() {
                      markerposition![i]['detail'] = [
                        {"name": icondetails.text}
                      ];
                    });
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('Update')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'))
        ],
      ),
    );
  }

  void infoUpdate2(MarkerId markerId, int positionid, LatLng position) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      for (int i = 0; i < markerposition!.length; i++) {
                        if (markerposition![i]['id'] == positionid) {
                          print(positionid);
                          print(markerposition![i]);
                          setState(() {
                            markerposition!.removeAt(i);
                          });
                        }
                      }
                      setState(() {
                        markers.remove(MarkerId(positionid.toString()));
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('Delete')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      updatemessageinfo(markerId, positionid, position);
                    },
                    child: Text('Update Info')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close')),
              ],
            ),
          );
        }),
      ),
    );
  }

  void updatemessageinfo(
      MarkerId markerId, int positionid, LatLng position) async {
    for (int i = 0; i < markerposition!.length; i++) {
      if (markerposition![i]['id'] == positionid) {
        setState(() {
          pointinfo = markerposition![i]['detail'];
        });
      }
    }
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
              children: [
                for (int i = 0; i < switchscreen!.detailsmarker.length; i++)
                  textfields(context, switchscreen!.detailsmarker[i]),
              ],
            ),
          );
        }),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                for (int i = 0; i < markerposition!.length; i++) {
                  if (markerposition![i]['id'] == id) {
                    print(id);
                    setState(() {
                      markerposition![i]['detail'] = pointinfo;
                    });
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('Update')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'))
        ],
      ),
    );
  }

  Widget textfields(BuildContext context, String name) {
    TextEditingController textcontroller =
        TextEditingController(text: switchscreen!.pointinfo[0][name]);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(name),
          TextField(
              controller: textcontroller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write here',
              ),
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: 10,
              onChanged: (val) {
                setState(() {
                  switchscreen!.pointinfo[0][name] = val;
                  print(switchscreen!.pointinfo[0]);
                });
              })
        ],
      ),
    );
  }

  void updatemessageposition(MarkerId markerId, int positionid, LatLng position,
      String name, String detail) async {
    for (int i = 0; i < markerposition!.length; i++) {
      if (markerposition![i]['id'] == positionid) {
        setState(() {
          print("new information marker addded please check");
          markerposition![i][name] = position;
          markers.remove(MarkerId(positionid.toString()));
          markerCrud.addInfoMarker(position, detail, id, context);
        });
      }
    }
  }

  void updatesymbolposition(MarkerId markerId, int positionid, LatLng position,
      String name, String detail) async {
    for (int i = 0; i < markerposition!.length; i++) {
      if (markerposition![i]['id'] == positionid) {
        setState(() {
          markerposition!.removeAt(i);
          markers.remove(MarkerId(positionid.toString()));
          markerCrud.addMarker(position, detail, id, name, context);
        });
        print(markerposition);
      }
    }
  }

  void updatelinepoint(LatLng newposition, LatLng oldposition, positionid) {
    for (int i = 0; i < linepoints.length; i++) {
      if (linepoints[i] == oldposition) {
        setState(() {
          markers.remove(MarkerId(positionid.toString()));
          linepoints[i] = newposition;
          markercrud.addlinemarker(newposition, id, context);
          lat = newposition.latitude;
          long = newposition.longitude;
        });
      }
    }
    for (int i = 0; i < uploadtrackpre!.length; i++) {
      if (uploadtrackpre![i]['lat'] == oldposition.latitude &&
          uploadtrackpre![i]['lng'] == oldposition.longitude) {
        setState(() {
          uploadtrackpre![i] = {
            'lat': newposition.latitude,
            'lng': newposition.longitude
          };
        });
      }
    }
    drawpolyline.updatepolyline();
  }

  void start() async {
    var locationData = await location.getLocation();
    if (lat == locationData.latitude! && long == locationData.longitude!) {
      return;
    }
    setState(() {
      lat = locationData.latitude!;
      long = locationData.longitude!;
    });

    findlocation(LatLng(locationData.latitude!, locationData.longitude!));
    // if (locationSubscription != null) {
    //   //locationSubscription!.cancel();
    //   await LocationManager().stop();
    // }
    // // locationSubscription = locationStream!.listen(findlocation);
    // // await LocationManager().start();
    // await LocationManager().start();
    // findlocation(await LocationManager().getCurrentLocation());
    // await LocationManager().stop();
  }

  void stop() async {
    // locationSubscription!.cancel();
    //await LocationManager().stop();
  }

  Future<int?> findlocation(LatLng currentLocation) async {
    print('new points');
    print(currentLocation);
    final GoogleMapController controller =
        await homescreenvar!.controller1.future;
    if (markerposition!.length > 0) {
      // currentmarkertrack!.add(
      //     {"lat": currentLocation.latitude, "lng": currentLocation.longitude});
    }
    uploadtrackpre?.add(
        {'lat': currentLocation.latitude, 'lng': currentLocation.longitude});

    drawpolyline.drawpolyline(
        currentLocation.latitude, currentLocation.longitude);
    //using to draw polylines
    markercrud.addlinemarker(
        LatLng(currentLocation.latitude, currentLocation.longitude),
        id,
        context);

    // if (screenname == 'homescreen')
    //   controller.animateCamera(
    //     CameraUpdate.newCameraPosition(
    //       CameraPosition(
    //           target:
    //               LatLng(currentLocation.latitude, currentLocation.longitude),
    //           zoom: 15),
    //     ),
    //   );
  }

  void clearmap() async {
    setState(() {
      lat = 0;
      long = 0;
      previouseditableid = [];
      linepoints = [];
      mapPolylines = {};
      markers = {};
      markerposition = [];
      uploadtrack = [];
      startstop = false;
      markerdistancetrack = [];
      trackname = '';
      //used to keep all marker tracks
      allmarkerstrack = [];
      //use to keep currently added marker track
      currentmarkertrack = [];
      //use to keep currently added marker track
      trackmedia = [];
      currentmarkertrackid = 0;
      polylineIdCounter = 1;
      id = 0;
    });
  }

  void savetrack() {
    uploadtrack!.add({
      'data': uploadtrackpre,
      'shape': trackshape,
      'color': trackcolor,
      'name': trackcurrenttype,
      'width': trackwidth
    });
    setState(() {
      lat = 0;
      long = 0;
      uploadtrackpre = [];
      linepoints = [];
      polylineIdCounter = polylineIdCounter + 1;
    });
  }

  Future<int?> getvalues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var num = prefs.getInt('markercontrol');
    var tim = prefs.getInt('markercontrolinterval');
    setState(() {
      markercontrol = num;
      markercontroltime = TextEditingController(text: tim.toString());
    });
  }

  Widget? screensfunction(String? name) {
    setState(() {
      screenname = name;
    });
    switch (name) {
      case 'homescreen':
        return MapHomeScreen();
        // ignore: dead_code
        break;
      case 'tracks':
        return Trackspage();
        // ignore: dead_code
        break;
      case 'setting':
        return Setting();
        // ignore: dead_code
        break;
      case 'media':
        return CameraExampleHome();
        // ignore: dead_code
        break;
      case 'Trackgallery':
        return TrakcsGalleryPage();
        // ignore: dead_code
        break;
      case 'gallery':
        return GalleryPage();
        // ignore: dead_code
        break;
      default:
        return MapHomeScreen();
    }
  }

  @override
  void initState() {
    currentmarkerslist = iconscategory.categorieslist[0];
    currentmarker = currentmarkerslist[0];
    getvalues();
    // LocationManager().interval = 1;
    // LocationManager().distanceFilter = 0;
    // locationStream = LocationManager().locationStream;
    // locationSubscription = locationStream!.listen(findlocation);
    super.initState();
  }

  String text = "Stop Service";
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        child: screensfunction(screenname),
      ),
    );
  }
}
