import 'package:fiberapp/menu/updatemarker.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:location/location.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:math' show cos, sqrt, asin;
//adding new marker deleting and updating makers and distance markers in map

class MarkerCrud {
  ScreenshotController screenshotController = ScreenshotController();
  Location location = new Location();
  Future addlinemarker(
      LatLng position, int positionid, BuildContext context) async {
    ByteData data = await rootBundle.load('asset/images/plus.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 90);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIcon =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    MarkerId markerId = MarkerId(positionid.toString());
    Marker marker = Marker(
        markerId: markerId,
        onTap: () {
          //positionedid is incremental number of marker and position is latlng if we want to update marker
        },
        draggable: true,
        onDragEnd: (newposition) {
          //updating line
          switchscreen!.updatelinepoint(newposition, position, positionid);
        },
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position);
    switchscreen!.markers[markerId] = marker;
    switchscreen!.updatedatalinemarker();
  }

  ///adding ppoint info marker
  Future addInfoMarker(
      LatLng position, var detail, int positionid, BuildContext context) async {
    switchscreen!.currentmarkertrackid = positionid;
    switchscreen!.markerposition!.add({
      'OFC/message': position,
      'id': positionid,
      "detail": detail,
      "subtrack": switchscreen?.trackcurrenttype,
    });
    ByteData data = await rootBundle.load('asset/images/OFC/message.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 90);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIcon =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    MarkerId markerId = MarkerId(positionid.toString());
    Marker marker = Marker(
        markerId: markerId,
        onTap: () {
          //positionedid is incremental number of marker and position is latlng if we want to update marker
          switchscreen!.infoUpdate2(markerId, positionid, position);
        },
        draggable: true,
        onDragEnd: (newposition) {
          //updating marker position
          switchscreen!.updatemessageposition(
              markerId, positionid, newposition, 'OFC/message', detail);
        },
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position);

    switchscreen!.id = switchscreen!.id + 1;
    switchscreen!.markers[markerId] = marker;
    switchscreen!.updatedata();
  }

  Future addMarker(LatLng position, String? detail, int positionid,
      String? markername, BuildContext context) async {
    //checking marker level tracks we need to add distance marker or not
    if (switchscreen!.markerposition!.length > 0 && !switchscreen!.lastmarker) {
      switchscreen!.allmarkerstrack!.add({
        "${switchscreen!.currentmarkertrackid}":
            switchscreen!.currentmarkertrack
      });
      distancemarkerwidget(context, switchscreen!.currentmarkertrack);
      switchscreen!.currentmarkertrack = [];
    } else if (switchscreen!.markerposition!.length > 0 &&
        switchscreen!.lastmarker &&
        switchscreen!.allmarkerstrack!.length > 0) {
      switchscreen!.lastmarker = false;
      var length = switchscreen!.allmarkerstrack!.length - 1;

      for (var item in switchscreen!.currentmarkertrack!) {
        //find previous track and add track data
        switchscreen!.allmarkerstrack![length]
                [switchscreen!.allmarkerstrack![length].keys.first]
            .add(item);
      }
      switchscreen!.currentmarkertrack = [];
      distancemarkerwidget(
          context,
          switchscreen!.allmarkerstrack![length]
              [switchscreen!.allmarkerstrack![length].keys.first]);
    }
    switchscreen!.currentmarkertrackid = positionid;
    switchscreen!.markerposition!.add({
      'OFC/$markername': position,
      'id': positionid,
      "detail": [
        {"name": detail}
      ],
      "subtrack": switchscreen?.trackcurrenttype
    });
    ByteData data = await rootBundle.load('asset/images/OFC/$markername.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 90);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIcon =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    if (switchscreen!.markerdistancetrack!.length > 0) {
      switchscreen!.markerdistancetrack!.add({'$positionid': []});
    } else {
      switchscreen!.markerdistancetrack!.add({'$positionid': []});
    }
    MarkerId markerId = MarkerId(positionid.toString());
    Marker marker = Marker(
        markerId: markerId,
        onTap: () {
          //positionedid is incremental number of marker and position is latlng if we want to update marker
          switchscreen!.onMarkerTapped(markerId, positionid, position);
        },
        draggable: true,
        onDragEnd: (newposition) {
          switchscreen!.updatesymbolposition(
              markerId, positionid, newposition, markername!, detail!);
        },
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position);

    switchscreen!.id = switchscreen!.id + 1;
    switchscreen!.icondetails = TextEditingController(text: '');
    switchscreen!.markers[markerId] = marker;
    switchscreen!.updatedata();
  }

  Future newsubtrack() async {
    //start new subtrack of track
    // if (switchscreen!.markerposition!.length > 0 && !switchscreen!.lastmarker) {
    //   switchscreen!.allmarkerstrack!.add({
    //     "${switchscreen!.currentmarkertrackid}":
    //         switchscreen!.currentmarkertrack
    //   });
    //   switchscreen!.currentmarkertrack = [];
    // }
    switchscreen!.currentmarkertrack = [];
    switchscreen!.updatedata();
  }

  Future replacemarker(LatLng position, String? detail, int positionid,
      BuildContext context) async {
    switchscreen!.markerposition?.add({
      'OFC/${switchscreen!.currentmarker}': position,
      'id': positionid,
      "detail": [
        {"name": detail}
      ]
    });
    ByteData data = await rootBundle
        .load('asset/images/OFC/${switchscreen!.currentmarker}.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 90);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIcon =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();

    MarkerId markerId = MarkerId(positionid.toString());
    Marker marker = Marker(
        markerId: markerId,
        onTap: () {
          switchscreen!.onMarkerTapped(markerId, positionid, position);
        },
        draggable: true,
        onDragEnd: (newposition) {
          switchscreen!.updatesymbolposition(markerId, positionid, newposition,
              switchscreen!.currentmarker!, detail!);
        },
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position);

    switchscreen!.icondetails = TextEditingController(text: '');
    switchscreen!.markers[markerId] = marker;
    switchscreen!.updatedata();
  }

//use on adding marker to calculate distance between markers
  void distancemarkerwidget(BuildContext context, track) {
    return null;
    var lat;
    var lng;
    double distance = 0.0;
    double halfdistance = 0;
    double completedistance = 0.0;
    double calculateComplDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return (12742 * asin(sqrt(a)));
    }

    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return (12742 * asin(sqrt(a)));
    }

    var i = 0;
    if (track.length > 1) {
      for (var j = 0; j < track.length - 1; j++) {
        completedistance = completedistance +
            calculateComplDistance(
              track[j]['lat'],
              track[j]['lng'],
              track[j + 1]['lat'],
              track[j + 1]['lng'],
            );
      }
      halfdistance = (completedistance / 2);
      for (var j = 0; j < track.length - 1; j++) {
        distance = distance +
            calculateDistance(
              track[j]['lat'],
              track[j]['lng'],
              track[j + 1]['lat'],
              track[j + 1]['lng'],
            );
        if (distance > halfdistance) {
          break;
        }
        i++;
      }
      print(halfdistance);
      print(distance);
      print('distance');
      lat = track[i]['lat'];
      lng = track[i]['lng'];
    }
    var container = Container(
      height: 50,
      width: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 1.0),
        color: Colors.redAccent,
      ),
      child: Text(
        distance.toString(),
        style: TextStyle(fontSize: 15),
      ),
    );
    screenshotController
        .captureFromWidget(
            InheritedTheme.captureAll(context, Material(child: container)),
            delay: Duration(seconds: 1))
        .then((capturedImage) {
      if (switchscreen!.markerposition!.length > 1) {
        //distancecalc(capturedImage, lat, lng, switchscreen!.id);
      }
    });
  }

  Future distancecalc(Uint8List capturedImage, lat, lng, positonid) async {
    if (lat == null && lng == null) {
      return;
    }
    Uint8List data = capturedImage;
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 80);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIcon =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    MarkerId markerId = MarkerId('d_$positonid');

    Marker marker = Marker(
        markerId: markerId,
        onTap: () {},
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: LatLng(lat, lng));
    switchscreen!.markers[markerId] = marker;
    switchscreen!.id++;
    switchscreen!.updatedata();
    var dataa = switchscreen!
        .markerdistancetrack![switchscreen!.markerdistancetrack!.length - 1];
    var dataa2 = switchscreen!
        .markerdistancetrack![switchscreen!.markerdistancetrack!.length - 2];
    var name = dataa.keys.first;
    var name2 = dataa2.keys.first;
    switchscreen!
        .markerdistancetrack![switchscreen!.markerdistancetrack!.length - 1]
            [name]
        .add(positonid);
    switchscreen!
        .markerdistancetrack![switchscreen!.markerdistancetrack!.length - 2]
            [name2]
        .add(positonid);
    print(switchscreen!.markerdistancetrack);
    switchscreen!.updatedata();
  }

//used after deleting marker to recalculate
  Future distancemarkerwidgetupdate(
      BuildContext context, markertrack, currentmakerid) async {
    return null;
    var position1;
    var position2;
    double distance = 0.0;
    double halfdistance = 0;
    double completedistance = 0.0;
    double calculateComplDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return (12742 * asin(sqrt(a)));
    }

    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return (12742 * asin(sqrt(a)));
    }

    var tracklength = markertrack.length;
    for (var i = 0; i < tracklength - 1; i++) {
      completedistance = completedistance +
          calculateComplDistance(markertrack[i]['lat'], markertrack[i]['lng'],
              markertrack[i + 1]['lat'], markertrack[i + 1]['lng']);
    }
    halfdistance = completedistance / 2;
    for (var i = 0; i < tracklength - 1; i++) {
      print(distance);
      print(i);

      if (distance > halfdistance) {
        position1 = markertrack[i]['lat'];
        position2 = markertrack[i]['lng'];
        break;
      }
      distance = distance +
          calculateDistance(markertrack[i]['lat'], markertrack[i]['lng'],
              markertrack[i + 1]['lat'], markertrack[i + 1]['lng']);
    }
    print(completedistance);
    print(halfdistance);
    print(distance);

    var container = Container(
      height: 50,
      width: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 1.0),
        color: Colors.redAccent,
      ),
      child: Text(
        distance.toString(),
        style: TextStyle(fontSize: 15),
      ),
    );
    screenshotController
        .captureFromWidget(
            InheritedTheme.captureAll(context, Material(child: container)),
            delay: Duration(seconds: 1))
        .then((capturedImage) {
      print(capturedImage);
      // distancecalc2(capturedImage, position1, position2, switchscreen!.id,currentmakerid);
    });
  }

  ///UPDATE track with new index value after deleting marker
  Future distancecalc2(
      Uint8List capturedImage, lat, lng, positonid, currentmakerid) async {
    Uint8List data = capturedImage;
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 80);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIcon =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    MarkerId markerId = MarkerId('d_$positonid');

    Marker marker = Marker(
        markerId: markerId,
        onTap: () {},
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: LatLng(lat, lng));
    switchscreen!.markers[markerId] = marker;
    switchscreen!.id++;
    switchscreen!.updatedata();

    ///upper track of current deleted
    var dataa = switchscreen!.markerdistancetrack![currentmakerid];

    ///Lover track of current deleted
    var dataa2 = switchscreen!.markerdistancetrack![currentmakerid - 1];
    var name = dataa.keys.first;
    var name2 = dataa2.keys.first;
    switchscreen!.markerdistancetrack![currentmakerid][name].add(positonid);
    switchscreen!.markerdistancetrack![currentmakerid - 1][name2]
        .add(positonid);
    print(switchscreen!.markerdistancetrack);
    switchscreen!.updatedata();
  }

  Widget markerupdateshowdialogueinner(
      markerId, positionid, position, BuildContext context, info) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 250,
        margin: EdgeInsets.only(bottom: 100, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: SizedBox.expand(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black38,
                ),
                height: 50,
                child: Text('Detail:$info',
                    style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        fontSize: 20)),
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          //removing marker track and update new status
                          for (int i = 0;
                              i < switchscreen!.markerposition!.length;
                              i++) {
                            if (switchscreen!.markerposition![i]['id'] ==
                                positionid) {
                              switchscreen!.markerposition!.removeAt(i);
                              break;
                            }
                          }
                          //removing maker from distance track and remove marker id from previous and next values
                          switchscreen!.markers
                              .remove(MarkerId(positionid.toString()));
                          for (var i = 0;
                              i < switchscreen!.markerdistancetrack!.length;
                              i++) {
                            var data = switchscreen!.markerdistancetrack![i];
                            var name = data.keys.first;
                            //checking marker position in marker tracks
                            if (int.parse(name) == positionid) {
                              print(switchscreen!.markerdistancetrack!);
                              //remove distance track marker from map with their refrence ids
                              var tracklength = data[name].length;
                              for (var z = 0; z < tracklength; z++) {
                                //removing marker id from previous and next markertrack. Making condition to remove id of deleted markers
                                switchscreen!.markers
                                    .remove(MarkerId('d_${data[name][0]}'));
                                var item = data[name][0];
                                for (var j = 0;
                                    j <
                                        switchscreen!
                                            .markerdistancetrack!.length;
                                    j++) {
                                  switchscreen!.markerdistancetrack![j][
                                          switchscreen!.markerdistancetrack![j]
                                              .keys.first]
                                      .remove(item);
                                }
                              }
                              await switchscreen!.markerdistancetrack!
                                  .removeAt(i);
                            }
                          }
                          switchscreen!.updatedata();

                          ///checking single marker track from current track and also from all marker tracks
                          if (positionid ==
                              switchscreen!.currentmarkertrackid) {
                            switchscreen!.lastmarker = true;
                            print('track not registered');
                          } else {
                            print(switchscreen!.allmarkerstrack!);
                            if (switchscreen!.allmarkerstrack!.length > 0) {
                              for (int i = 0;
                                  i < switchscreen!.allmarkerstrack!.length;
                                  i++) {
                                //check if marker is first or between first and final if first simply remove track
                                //if in between get track and add in previous find center point add new distance
                                if (int.parse(switchscreen!
                                            .allmarkerstrack![i].keys.first) ==
                                        positionid &&
                                    i == 0) {
                                  //check maker position if need to add updated distance marker
                                  switchscreen!.allmarkerstrack!.removeAt(i);
                                  break;
                                } else if (int.parse(switchscreen!
                                        .allmarkerstrack![i].keys.first) ==
                                    positionid) {
                                  List clickedmarkertrack =
                                      switchscreen!.allmarkerstrack![i][
                                          switchscreen!
                                              .allmarkerstrack![i].keys.first];

                                  for (var item in clickedmarkertrack) {
                                    switchscreen!.allmarkerstrack![i - 1][
                                            switchscreen!
                                                .allmarkerstrack![i - 1]
                                                .keys
                                                .first]
                                        .add(item);
                                  }
                                  //find lat lng of new updated track i is the value of current deleted distance track and use for inserting
                                  //new distance marker
                                  if (switchscreen!
                                          .allmarkerstrack![i - 1][switchscreen!
                                              .allmarkerstrack![i - 1]
                                              .keys
                                              .first]
                                          .length >
                                      0) {
                                    print(
                                      switchscreen!.allmarkerstrack![i - 1][
                                          switchscreen!.allmarkerstrack![i - 1]
                                              .keys.first],
                                    );
                                    print('data sending to update widget');
                                    distancemarkerwidgetupdate(
                                        context,
                                        switchscreen!.allmarkerstrack![i - 1][
                                            switchscreen!
                                                .allmarkerstrack![i - 1]
                                                .keys
                                                .first],
                                        i);
                                    switchscreen!.allmarkerstrack!.removeAt(i);
                                  }
                                }
                              }
                            }
                          }
                          switchscreen!.updatedata();
                          print(switchscreen!.markerdistancetrack!);
                          Navigator.of(context).pop();
                        },
                        child: Text('Delete')),
                    ElevatedButton(
                        onPressed: () {
                          switchscreen?.icondetails.text = '';
                          Navigator.of(context).pop();
                          switchscreen!.infoUpdate(positionid, info);
                        },
                        child: Text('Update Marker Info')),

                    ///update marker using update marker widget passing param for conditio if user update or cancel
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showModalBottomSheet<void>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder:
                                    (BuildContext context, StateSetter state) {
                                  return Container(
                                    height: 220,
                                    child: SingleChildScrollView(
                                      child: UpdateMarker(
                                          markerposition: position,
                                          id: positionid,
                                          markerid: markerId),
                                    ),
                                  );
                                });
                              });
                        },
                        child: Text('Update Marker')),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'))
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
