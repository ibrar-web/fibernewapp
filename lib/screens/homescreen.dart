import 'package:fiberapp/MapFunctions/markercrud.dart';
import 'package:fiberapp/menu/maptypes.dart';
import 'package:fiberapp/menu/markertypes.dart';
import 'package:fiberapp/database/trackdatabase.dart';
import 'package:fiberapp/menu/trackmedia.dart';
import 'package:fiberapp/menu/tracktype.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:another_flushbar/flushbar.dart';

_MapHomeScreenState? homescreenvar;

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({Key? key}) : super(key: key);

  @override
  _MapHomeScreenState createState() {
    homescreenvar = _MapHomeScreenState();
    return homescreenvar!;
  }
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  bool savestatus = false;
  updatesavestatus() {
    setState(() {
      savestatus = !savestatus;
    });
  }

  List<dynamic> detailsmarker = [
    'Comment1',
    'Comment2',
    'Comment3',
    'Comment4',
    'Comment5',
  ];
  var pointinfo = {
    'Comment1': '',
    'Comment2': '',
    'Comment3': '',
    'Comment4': '',
    'Comment5': '',
  };

  Location location = new Location();
  ButtonStyle buttonstyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.grey),
      padding: MaterialStateProperty.all(EdgeInsets.all(10)),
      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 15)));
  TextEditingController textcontroller = TextEditingController();

  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  Completer<GoogleMapController> controller1 = Completer();
  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(33.42796133580664, 73.085749655962),
    zoom: 14.4746,
  );
  String dropDownValue = 'select';

  Future<void> getCurrentPosition() async {
    final GoogleMapController controller = await controller1.future;
    final position = await geolocatorPlatform.getCurrentPosition();
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 15),
      ),
    );
  }

  Future<int?> onMapTypeButtonPressed(int? num) async {
    setState(() {
      Navigator.of(context).pop();
      switch (num) {
        case 1:
          switchscreen!.currentMapType = MapType.normal;
          switchscreen!.mapnumber = 1;
          break;
        case 2:
          switchscreen!.currentMapType = MapType.satellite;
          switchscreen!.mapnumber = 2;
          break;
        case 3:
          switchscreen!.currentMapType = MapType.hybrid;
          switchscreen!.mapnumber = 3;
          break;
        case 4:
          switchscreen!.currentMapType = MapType.terrain;
          switchscreen!.mapnumber = 4;
          break;
        case 4:
          switchscreen!.currentMapType = MapType.none;
          break;
        default:
      }
    });
  }

  void alert(Color backcolor, String title, Color titlecolor, String message,
      Color messagecolor, int time) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: backcolor,
      title: title,
      titleColor: titlecolor,
      message: message,
      duration: Duration(seconds: time),
      messageColor: messagecolor,
    ).show(context);
  }

  @override
  void initState() {
    getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .8,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                mapType: switchscreen!.currentMapType,
                zoomControlsEnabled: true,
                scrollGesturesEnabled: true,
                myLocationEnabled: true,
                markers: Set<Marker>.of(switchscreen!.markers.values),
                polylines: Set<Polyline>.of(switchscreen!.mapPolylines.values),
                initialCameraPosition: kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  controller1.complete(controller);
                },
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: 80,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: PopupMenuButton(
                    color: Color.fromRGBO(0, 0, 20, .9),
                    padding: EdgeInsets.fromLTRB(100, 20, 20, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    icon: Icon(
                      Icons.menu,
                      color: Colors.black,
                      size: 40,
                    ),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              details(context);
                            },
                            style: buttonstyle,
                            child: Text(
                              'Detail',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Maptypes();
                                });
                          },
                          style: buttonstyle,
                          child: Text(
                            'Map',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )),
                      PopupMenuItem(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: buttonstyle,
                          onPressed: () async {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      return SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Region'),
                                                    DropdownButton<String>(
                                                      hint: Text(
                                                        switchscreen!
                                                            .selectregion,
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      ),
                                                      items: <String>[
                                                        'north',
                                                        'central',
                                                        'south'
                                                      ].map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged: (val) {
                                                        setState(() {
                                                          switchscreen!
                                                                  .selectregion =
                                                              val!;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                )),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('City'),
                                                    DropdownButton<String>(
                                                      hint: Text(
                                                        switchscreen!
                                                            .selectcity,
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      ),
                                                      items: <String>[
                                                        'Islamabad',
                                                        'Peshawar',
                                                        'Rawalpindi',
                                                        'Gujranwala',
                                                        'Multan',
                                                        'Faislabad',
                                                        'Sialkot'
                                                      ].map((String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged: (val) {
                                                        setState(() {
                                                          switchscreen!
                                                                  .selectcity =
                                                              val!;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                )),
                                            Padding(
                                              padding: EdgeInsets.all(8),
                                              child: TextField(
                                                controller: textcontroller,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Enter Area',
                                                  hintText: 'Enter Name Here',
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8),
                                              child: TextField(
                                                controller:
                                                    switchscreen!.segmentname,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Enter Segment',
                                                  hintText: 'Enter Name Here',
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8),
                                              child: TextField(
                                                controller:
                                                    switchscreen!.sectionname,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Enter Section',
                                                  hintText: 'Enter Name Here',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            if (switchscreen!
                                                    .uploadtrackpre!.length >
                                                0) {
                                              switchscreen!.savetrack();
                                            }
                                            String trackname =
                                                "${switchscreen!.selectregion}_${switchscreen!.selectcity}_${textcontroller.text.replaceAll(' ', '_')}_${switchscreen!.segmentname.text}_${switchscreen!.sectionname.text}";
                                            DatabaseHelper.instance
                                                .addtracksaveas(trackname,
                                                    switchscreen!.trackname);
                                            setState(() {
                                              switchscreen!.trackname =
                                                  trackname;
                                              textcontroller.text = '';
                                              //switchscreen!.uploadtrackpre = [];
                                            });
                                            //switchscreen!.stop();
                                          },
                                          child: Text('Save')),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel')),
                                    ],
                                  );
                                });
                          },
                          child: Text(
                            'Save As',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )),
                      PopupMenuItem(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (switchscreen!.trackname == '') {
                              Navigator.pop(context);
                              alert(
                                  Colors.white,
                                  'Create Track',
                                  Colors.red,
                                  'Please add track name first.',
                                  Colors.black,
                                  3);
                              return;
                            }
                            Navigator.pop(context);
                            createmedia(context);
                          },
                          style: buttonstyle,
                          child: Text(
                            'Media',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )),
                      PopupMenuItem(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title:
                                        Text('This will remove all track data'),
                                    content: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            switchscreen?.clearmap();
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Clear")),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Cancel")),
                                    ],
                                  );
                                });
                          },
                          style: buttonstyle,
                          child: Text(
                            'Clear',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: switchscreen!.startstop == true
                              ? MaterialStateProperty.all(Colors.green)
                              : MaterialStateProperty.all(Colors.black),
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                          textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 15))),
                      onPressed: () async {
                        if (switchscreen!.trackname == '') {
                          await tracknam(context);
                        }
                        if (!switchscreen!.startstop &&
                            switchscreen!.trackname != '') {
                          setState(() {
                            switchscreen!.startstop = true;
                          });
                          switchscreen!.start();
                        } else {
                          setState(() {
                            switchscreen!.startstop = false;
                          });

                          switchscreen!.stop();
                        }
                      },
                      child: Text(
                        switchscreen!.startstop == true ? 'Stop' : 'Start',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                          textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 15))),
                      onPressed: () async {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Container(
                                  height: 5,
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        if (switchscreen!
                                                .uploadtrackpre!.length >
                                            0) {
                                          switchscreen!.savetrack();
                                        }
                                        DatabaseHelper.instance.addtrack();
                                      },
                                      child: Text('Save')),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel')),
                                ],
                              );
                            });
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                          textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 15))),
                      onPressed: () async {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Container(
                                  height: 50,
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Text(
                                        'Ending Track will mark complete track'),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        if (switchscreen!
                                                .uploadtrackpre!.length >
                                            0) {
                                          switchscreen!.savetrack();
                                        }
                                        switchscreen!.stop();
                                        await DatabaseHelper.instance
                                            .addtrack();
                                        switchscreen?.clearmap();
                                      },
                                      child: Text('End')),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel')),
                                ],
                              );
                            });
                      },
                      child: Text(
                        'Finish',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
              ],
            ),
            Positioned(
                bottom: 140,
                right: 1,
                child: Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                        onPressed: () {
                          switchscreen!.start();
                        },
                        child: Text('Add Point'))))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () async {
                  showModalBottomSheet<void>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                            builder: (BuildContext context, StateSetter state) {
                          return Container(
                            height: 210,
                            child: SingleChildScrollView(
                              child: Markertypes(),
                            ),
                          );
                        });
                      });
                },
                child: Text('Symbols')),
            ElevatedButton(
                onPressed: () async {
                  showModalBottomSheet<void>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                            builder: (BuildContext context, StateSetter state) {
                          return Container(
                            height: 600,
                            child: SingleChildScrollView(
                              child: Tracktype(),
                            ),
                          );
                        });
                      });
                },
                child: Text('Track Type')),
          ],
        ),
      ],
    );
  }

  Future<dynamic> tracknam(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Region'),
                            DropdownButton<String>(
                              hint: Text(
                                switchscreen!.selectregion,
                                style: TextStyle(color: Colors.blue),
                              ),
                              items: <String>['north', 'central', 'south']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  switchscreen!.selectregion = val!;
                                });
                              },
                            ),
                          ],
                        )),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('City'),
                            DropdownButton<String>(
                              hint: Text(
                                switchscreen!.selectcity,
                                style: TextStyle(color: Colors.blue),
                              ),
                              items: <String>[
                                'Islamabad',
                                'Peshawar',
                                'Rawalpindi',
                                'Gujranwala',
                                'Multan',
                                'Faislabad',
                                'Sialkot'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  switchscreen!.selectcity = val!;
                                });
                              },
                            ),
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        controller: textcontroller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter Area',
                          hintText: 'Enter Name Here',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        controller: switchscreen!.segmentname,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter Segment',
                          hintText: 'Enter Name Here',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        controller: switchscreen!.sectionname,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter Section',
                          hintText: 'Enter Name Here',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    if (textcontroller.text == '') {
                      alert(Colors.white, 'Enter Name', Colors.red,
                          'Please Enter Proper Name ', Colors.black, 3);
                      return null;
                    }
                    Navigator.of(context).pop();
                    setState(() {
                      switchscreen!.trackname =
                          "${switchscreen!.selectregion}_${switchscreen!.selectcity}_${textcontroller.text.replaceAll(' ', '_')}_${switchscreen!.segmentname.text}_${switchscreen!.sectionname.text}";
                      textcontroller.text = '';
                    });
                  },
                  child: Text('Start')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
            ],
          );
        });
  }

  Future<dynamic> details(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Details"),
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
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    var locationData = await location.getLocation();
                    MarkerCrud markerCrud = MarkerCrud();
                    List detailval = [{}];
                    pointinfo.forEach((key, value) {
                      detailval[0][key] = value;
                    });
                    markerCrud.addInfoMarker(
                        LatLng(locationData.latitude!, locationData.longitude!),
                        detailval,
                        switchscreen!.id,
                        context);
                    Navigator.of(context).pop();
                  },
                  child: Text('Insert')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
            ],
          );
        });
  }

  Widget textfields(BuildContext context, String name) {
    TextEditingController textcontroller = TextEditingController();
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
                  pointinfo[name] = val;
                  print(switchscreen!.markerposition!);
                });
              })
        ],
      ),
    );
  }

  Future createmedia(BuildContext context) async {
    return showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
            return Wrap(children: <Widget>[
              Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(color: Colors.green),
                  child: ElevatedButton(
                      onPressed: () {
                        if (savestatus) {
                          //backgroundcolor,title,titlecolor,message,messagecolor,duration
                          alert(Colors.white, 'Media saving', Colors.red,
                              'Please wait saving media', Colors.black, 3);
                          if (!savestatus) {
                            updatesavestatus();
                          }
                          return;
                        }
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text(
                        'Click to Close',
                        style: TextStyle(),
                      ))),
              Container(
                height: MediaQuery.of(context).size.height * .9,
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        topRight: const Radius.circular(25.0))),
                child: SingleChildScrollView(child: TrackMedia()),
              ),
            ]);
          });
        });
  }
}
