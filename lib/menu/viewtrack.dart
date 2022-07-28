import 'package:fiberapp/screenrendring.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'dart:ui' as ui;

class ViewTrack extends StatefulWidget {
  final List? track;
  final List? markerposition;
  const ViewTrack({Key? key, this.track, this.markerposition})
      : super(key: key);

  @override
  _ViewTrackState createState() => _ViewTrackState(track, markerposition);
}

class _ViewTrackState extends State<ViewTrack> {
  _ViewTrackState(this.track, this.markerposition);
  List? track;
  List? markerposition;
  int _polylineIdCounter = 1;
  List<LatLng> linepoints = <LatLng>[];
  Map<PolylineId, Polyline> mapPolylines = {};

  Completer<GoogleMapController> controller1 = Completer();
  int id = 1;
  BitmapDescriptor? myIcon;
  Map<MarkerId, Marker> markers = {};
  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33.42796133580664, 73.085749655962),
    zoom: 14.4746,
  );
  void drawpolyline(trackdata) {
    for (int i = 0; i < trackdata['data'].length; i++) {
      linepoints.add(
          LatLng(trackdata['data'][i]['lat'], trackdata['data'][i]['lng']));
    }
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);
    final Polyline polyline = Polyline(
      patterns: switchscreen!.patternsParam[trackdata['shape']],
      polylineId: polylineId,
      consumeTapEvents: true,
      color: switchscreen!.colors[trackdata['color']],
      width: switchscreen!.linewidth[trackdata['width']],
      points: linepoints,
    );

    setState(() {
      mapPolylines[polylineId] = polyline;
      linepoints = [];
    });
  }

  Future addMarker(LatLng position, String name) async {
    ByteData data = await rootBundle.load('asset/images/$name.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 80);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIcon =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();

    MarkerId markerId = MarkerId(id.toString());
    Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position);

    id = id + 1;
    setState(() {
      markers[markerId] = marker;
    });
  }

  @override
  void initState() {
    setState(() {
      if (track!.length > 0) {
        _kGooglePlex = CameraPosition(
          target:
              LatLng(track![0]['data'][0]['lat'], track![0]['data'][0]['lng']),
          zoom: 14.4746,
        );
      }
    });
    for (int i = 0; i < track!.length; i++) {
      drawpolyline(track![i]);
    }
    for (int i = 0; i < markerposition!.length; i++) {
      var item = markerposition![i];
      var name = item.keys.first;
      var position = markerposition![i][name];
      addMarker(LatLng(position[0], position[1]), name);
      print('markerposition![i]');
      print(position[0]);
      print(name);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .6,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(mapPolylines.values),
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          controller1.complete(controller);
        },
      ),
    );
  }
}
