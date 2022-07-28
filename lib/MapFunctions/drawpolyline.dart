import 'package:fiberapp/screenrendring.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Drawpolyline {
  void drawpolyline(first, second) {
    switchscreen!.linepoints.add(LatLng(first, second));
    final String polylineIdVal =
        'polyline_id_${switchscreen!.polylineIdCounter}';
    final PolylineId polylineId = PolylineId(polylineIdVal);
    final Polyline polyline = Polyline(
      patterns: switchscreen!.patternsParam[switchscreen!.trackshape],
      polylineId: polylineId,
      consumeTapEvents: false,
      color: switchscreen!.colors[switchscreen!.trackcolor],
      width: switchscreen!.linewidth[switchscreen!.trackwidth],
      points: switchscreen!.linepoints,
    );
    switchscreen!.mapPolylines[polylineId] = polyline;
    switchscreen!.updatetrackline();
    return null;
  }

  void updatepolyline() {
    final String polylineIdVal =
        'polyline_id_${switchscreen!.polylineIdCounter}';
    final PolylineId polylineId = PolylineId(polylineIdVal);
    final Polyline polyline = Polyline(
      patterns: switchscreen!.patternsParam[switchscreen!.trackshape],
      polylineId: polylineId,
      consumeTapEvents: false,
      color: switchscreen!.colors[switchscreen!.trackcolor],
      width: switchscreen!.linewidth[switchscreen!.trackwidth],
      points: switchscreen!.linepoints,
    );
    switchscreen!.mapPolylines[polylineId] = polyline;
    print(switchscreen!.mapPolylines.length);
    switchscreen!.updatetrackline();
    return null;
  }
}
