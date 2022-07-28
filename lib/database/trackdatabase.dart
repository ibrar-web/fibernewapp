// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:fiberapp/main.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:fiberapp/screens/tracksgallery.dart';
import 'package:fiberapp/screens/tracks.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:location/location.dart';

class Data {
  final int? id;
  final String name;
  var track;
  var markerposition;
  var time;
  var status;

  Data(
      {this.id,
      required this.name,
      this.track,
      this.markerposition,
      this.time,
      this.status});

  factory Data.fromMap(Map<String, dynamic> json) => new Data(
      id: json['id'],
      name: json['name'],
      track: json['track'],
      markerposition: json['markerposition'],
      time: json['time'],
      status: json['status']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'track': track,
      'markerposition': markerposition,
      'time': time,
      'status': status
    };
  }
}

// ignore: camel_case_types
class trackmedias {
  final int? id;
  final String name;
  var time;
  var type;
  var trackmedia;

  trackmedias(
      {this.id, required this.name, this.time, this.type, this.trackmedia});

  factory trackmedias.fromMap(Map<String, dynamic> json) => new trackmedias(
      id: json['id'],
      name: json['name'],
      time: json['time'],
      type: json['type'],
      trackmedia: json['trackmedia']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'type': type,
      'trackmedia': trackmedia
    };
  }
}

class Medias {
  final int? id;
  final String name;
  var time;
  var type;
  var trackmedia;

  Medias({this.id, required this.name, this.time, this.type, this.trackmedia});

  factory Medias.fromMap(Map<String, dynamic> json) => new Medias(
      id: json['id'],
      name: json['name'],
      time: json['time'],
      type: json['type'],
      trackmedia: json['trackmedia']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'type': type,
      'trackmedia': trackmedia
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async => _database ??= await initDatabase();

  Future<int?> addtrack() async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    DateTime time = DateTime.now();
    final SharedPreferences prefs = await pref;
    if (prefs.getString('trackslist') == null) {
      List<dynamic> trackslist = [];
      prefs.setString('trackslist', jsonEncode(trackslist));
    }
    List trackslist = [];
    String? vol = prefs.getString('trackslist');
    if (vol != null) {
      trackslist = jsonDecode(vol);
    }
    int? id = trackslist.length;
    final Directory path = await getApplicationDocumentsDirectory();
    //CHECKING IF TRACK ALREADY EXIST or not if exist then update it
    if (id > 0) {
      if (trackslist[id - 1]['name'] == switchscreen!.trackname) {
        int idold = trackslist[id - 1]['id']!;
        trackslist.removeAt(id - 1);
        trackslist.add({
          "name": switchscreen!.trackname,
          "tracktype": "fiber",
          "track": switchscreen!.uploadtrack,
          "markerposition": switchscreen!.markerposition,
          "allmarkerstrack": switchscreen!.allmarkerstrack,
          "id": idold,
          "time": '$time',
          "trackmedia": switchscreen!.trackmedia,
          "region": switchscreen!.selectregion,
          "city": switchscreen!.selectcity,
          'section': switchscreen!.sectionname.text,
          'segment': switchscreen!.segmentname.text,
          'status': 'local',
        });
        // print(
        //   switchscreen!.trackname,
        // );
        prefs.setString('trackslist', jsonEncode(trackslist));
        return 1;
      }
    }
    if (id > 0) {
      id = trackslist[id - 1]['id']!;
      id = (id! + 1);
    } else {
      id = 1;
    }

    trackslist.add({
      "name": switchscreen!.trackname,
      "tracktype": "fiber",
      "track": switchscreen!.uploadtrack,
      "markerposition": switchscreen!.markerposition,
      "allmarkerstrack": switchscreen!.allmarkerstrack,
      "id": id,
      "time": '$time',
      "trackmedia": switchscreen!.trackmedia,
      "region": switchscreen!.selectregion,
      "city": switchscreen!.selectcity,
      'section': switchscreen!.sectionname.text,
      'segment': switchscreen!.segmentname.text,
      'status': 'local',
    });
    // print(
    //   switchscreen!.trackname,
    // );
    prefs.setString('trackslist', jsonEncode(trackslist));
    return 1;
  }

  Future<int?> addtracksaveas(
      String trackname, String? previoustrackname) async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    DateTime time = DateTime.now();
    final SharedPreferences prefs = await pref;
    if (prefs.getString('trackslist') == null) {
      List<dynamic> trackslist = [];
      prefs.setString('trackslist', jsonEncode(trackslist));
    }
    List trackslist = [];
    String? vol = prefs.getString('trackslist');
    if (vol != null) {
      trackslist = jsonDecode(vol);
    }

    int? id = trackslist.length;
    final Directory path = await getApplicationDocumentsDirectory();
    if (id > 0) {
      id = trackslist[id - 1]['id']!;
      id = (id! + 1);
    } else {
      id = 1;
    }
    final pathcheck = Directory("${path.path}/images/$trackname");
    if ((await pathcheck.exists())) {
      print("exist");
    } else {
      print("not exist");
      await pathcheck.create();
    }
    trackslist.add({
      "name": switchscreen!.trackname,
      "tracktype": "fiber",
      "track": switchscreen!.uploadtrack,
      "markerposition": switchscreen!.markerposition,
      "allmarkerstrack": switchscreen!.allmarkerstrack,
      "id": id,
      "time": '$time',
      "trackmedia": switchscreen!.trackmedia,
      "region": switchscreen!.selectregion,
      "city": switchscreen!.selectcity,
      'section': switchscreen!.sectionname.text,
      'segment': switchscreen!.segmentname.text,
    });
    for (var i = 0; i < trackslist.length; i++) {
      if (trackslist[i]['name'] == previoustrackname) {
        for (var j = 0; j < trackslist[i]['trackmedia'].length; j++) {
          print(trackslist[i]['trackmedia'][j]);
          File image = File(
              '${path.path}/images/$previoustrackname/${trackslist[i]['trackmedia'][j]['name']}');
          await image.copy(
              '${path.path}/images/$trackname/${trackslist[i]['trackmedia'][j]['name']}');
        }
      }
    }
    prefs.setString('trackslist', jsonEncode(trackslist));
  }

  Future<List<Data>> gettrack() async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    List trackslist = [];
    String? vol = prefs.getString('trackslist');
    if (vol != null) {
      trackslist = jsonDecode(vol);
    }
    trackslist = trackslist.reversed.toList();
    List<Data> dataList = trackslist.isNotEmpty
        ? trackslist.map((c) => Data.fromMap(c)).toList()
        : [];
    return dataList;
  }

  Future<int?> removetrack(int id) async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    List trackslist = [];
    String? vol = prefs.getString('trackslist');
    if (vol != null) {
      trackslist = jsonDecode(vol);
    }
    for (int i = 0; i < trackslist.length; i++) {
      if (trackslist[i]['id'] == id) {
        await removetrackmedia(trackslist[i]['name']);
        trackslist.removeAt(i);
      }
    }
    prefs.setString('trackslist', jsonEncode(trackslist));
  }

  Future<List?> removetrackmedia(String trackname) async {
    final Directory path = await getApplicationDocumentsDirectory();
    final pathcheck = Directory("${path.path}/images/$trackname");
    if ((await pathcheck.exists())) {
      print(Directory("${path.path}/images").listSync());
      pathcheck.deleteSync(recursive: true);
    }
  }

  Future<int?> uploadtrack(int id) async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    List trackslist = [];
    String? vol = prefs.getString('trackslist');
    if (vol != null) {
      trackslist = jsonDecode(vol);
    }
    // 'status': 'local',
    var data;
    int trackid = 0;
    for (int i = 0; i < trackslist.length; i++) {
      if (trackslist[i]['id'] == id) {
        data = trackslist[i];
        trackid = i;
        break;
        // trackslist.removeAt(i);
      }
    }
    if (data != null) {
      trackpage!.medianumber = data['trackmedia'].length;
      for (var i = 0; i < data['trackmedia'].length; i++) {
        //type is category video or image, data[name] is track name use as folder name, and second name is file name
        await uploadtrackmedia(data['trackmedia'][i]['name'],
            data['trackmedia'][i]['type'], data['name']);
        trackpage!.updatemedianumber(trackpage!.medianumber! - 1);
      }
      data = convert.jsonEncode(data);
      var url = Uri.parse(
        '${mainaccess!.baseurl2}/api/trackdata',
      );
      var request = new http.MultipartRequest("POST", url);
      request.fields['data'] = data;
      request.fields['userid'] = mainaccess!.userid.toString();
      request.fields['workerid'] = '${mainaccess!.workerid}';
      var response = await request.send();
      if (response.statusCode == 200) {
        trackslist[trackid]['status'] = 'upload';
        prefs.setString('trackslist', jsonEncode(trackslist));
        var jsonResponse = response;
        //print('Number of books about http: $jsonResponse.');
        return response.statusCode;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        // return response.statusCode;
      }
    }
    trackpage!.trackupload();
  }

  Future<int?> uploadtrackmedia(
      String filename, String mediatype, String trackname) async {
    final Directory path = await getApplicationDocumentsDirectory();
    var url = Uri.parse(
      '${mainaccess!.baseurl2}/api/fiber/trackmedia',
    );
    String folder;
    if (mediatype == 'image') {
      folder = 'images';
    } else {
      folder = 'videos';
    }
    if (!File("${path.path}/$folder/$trackname/$filename").existsSync()) {
      return null;
    }
    var file = await http.MultipartFile.fromPath(
        "file", "${path.path}/$folder/$trackname/$filename");
    var request = new http.MultipartRequest("POST", url)
      ..files.add(file)
      ..fields['type'] = mediatype
      ..fields['track'] = trackname
      ..fields['userid'] = mainaccess!.userid.toString();
    var response = await request.send();
    if (response.statusCode == 200) {
      return null;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<int?> addtrackmedia(
      String data, String type, LocationData location, String tracknam) async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    DateTime time = DateTime.now();
    final SharedPreferences prefs = await pref;
    if (prefs.getString('imageslist') == null) {
      List<dynamic> imageslist = [];
      prefs.setString('imageslist', jsonEncode(imageslist));
    }
    List imageslist = [];
    String? vol = prefs.getString('imageslist');
    if (vol != null) {
      imageslist = jsonDecode(vol);
    }
    int? id = imageslist.length;

    if (id > 0) {
      id = imageslist[id - 1]['id']!;
      id = (id! + 1);
    } else {
      id = 1;
    }
    if (tracknam == 'track_media_') {
      switchscreen!.trackmedia!.add({
        "name": data,
        "tracktype": "fiber",
        "id": id,
        "time": '$time',
        "type": type,
        "latitude": location.latitude,
        "longitude": location.longitude,
      });
    }
    print(switchscreen!.trackmedia!);
    imageslist.add({
      "name": data,
      "tracktype": "fiber",
      "id": id,
      "time": '$time',
      "type": type,
      "latitude": location.latitude,
      "longitude": location.longitude,
    });
    prefs.setString('imageslist', jsonEncode(imageslist));
    //print(prefs.getString('imageslist'));
    return addtrack();
  }

  Future<List<trackmedias>> gettrackmedia() async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    List imageslist = [];
    String? vol = prefs.getString('trackslist');
    if (vol != null) {
      imageslist = jsonDecode(vol);
    }
    imageslist = imageslist.reversed.toList();
    List<trackmedias> dataList = imageslist.isNotEmpty
        ? imageslist.map((c) => trackmedias.fromMap(c)).toList()
        : [];
    print(imageslist);
    return dataList;
  }

  Future<List<Medias>> getmedia() async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    List imageslist = [];
    String? vol = prefs.getString('imageslist');
    if (vol != null) {
      imageslist = jsonDecode(vol);
    }
    imageslist = imageslist.reversed.toList();
    List<Medias> dataList = imageslist.isNotEmpty
        ? imageslist.map((c) => Medias.fromMap(c)).toList()
        : [];
    print(imageslist);
    return dataList;
  }

  Future<int?> removetracksinglemedia(int trackid, int mediaid) async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final Directory path = await getApplicationDocumentsDirectory();
    final SharedPreferences prefs = await pref;
    List trackslist = [];
    String? vol = prefs.getString('trackslist');
    if (vol != null) {
      trackslist = jsonDecode(vol);
    }
    for (int i = 0; i < switchscreen!.trackmedia!.length; i++) {
      if (mediaid == switchscreen!.trackmedia![i]['id']) {
        switchscreen!.trackmedia!.removeAt(i);
      }
    }
    for (int i = 0; i < trackslist.length; i++) {
      if (trackslist[i]['id'] == trackid) {
        for (int j = 0; j < trackslist[i]['trackmedia'].length; j++) {
          if (trackslist[i]['trackmedia'][j]['id'] == mediaid) {
            String foldername = trackslist[i]['name'];
            String filename = trackslist[i]['trackmedia'][j]['name'];
            if (trackslist[i]['trackmedia'][j]['type'] == 'image') {
              final File pathcheck =
                  File("${path.path}/images/$foldername/$filename");
              pathcheck.delete();
            } else if (trackslist[i]['trackmedia'][j]['type'] == 'video') {
              final File pathcheck =
                  File("${path.path}/videos/$foldername/$filename");
              pathcheck.delete();
            }
            trackslist[i]['trackmedia'].removeAt(j);
            prefs.setString('trackslist', jsonEncode(trackslist));
          }
        }
      }
    }
  }

  Future<int?> removemedia(int mediaid) async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final Directory path = await getApplicationDocumentsDirectory();
    final SharedPreferences prefs = await pref;
    List imageslist = [];
    String? vol = prefs.getString('imageslist');
    if (vol != null) {
      imageslist = jsonDecode(vol);
    }
    int mediaid = 1;
    for (int i = 0; i < imageslist.length; i++) {
      if (imageslist[i]['id'] == mediaid) {
        if (imageslist[i]['type'] == 'image') {
          final File pathcheck = File(
              "${path.path}/images/temporary-1-1/${imageslist[i]['name']}");
          pathcheck.delete();
        } else if (imageslist[i]['type'] == 'video') {
          final File pathcheck = File(
              "${path.path}/videos/temporary-1-1/${imageslist[i]['name']}");
          pathcheck.delete();
        }
        imageslist.removeAt(i);
        prefs.setString('imageslist', jsonEncode(imageslist));
      }
    }
  }

  Future<int?> uploadmedia(int id, String type) async {
    final Directory path = await getApplicationDocumentsDirectory();
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    List imageslist = [];
    String? vol = prefs.getString('imageslist');
    if (vol != null) {
      imageslist = jsonDecode(vol);
    }
    var data;
    for (int i = 0; i < imageslist.length; i++) {
      if (imageslist[i]['id'] == id) {
        data = imageslist[i];
        imageslist.removeAt(i);
      }
    }
    if (data != null) {
      String filename = data['name'];
      data = convert.jsonEncode(data);
      var url = Uri.parse(
        '${mainaccess!.baseurl2}/api/fiber/trackmedia',
      );
      String folder;
      if (type == 'image') {
        folder = 'images';
      } else {
        folder = 'videos';
      }
      var file = await http.MultipartFile.fromPath(
          "file", "${path.path}/$folder/$filename");
      var request = new http.MultipartRequest("POST", url)
        ..fields['data'] = data
        ..fields['userid'] = mainaccess!.userid.toString()
        ..files.add(file);
      var response = await request.send();

      if (response.statusCode == 200) {
        if (type == 'image') {
          final file = File("${path.path}/images/$filename");
          final isExists = await file.exists();
          if (isExists) {
            await file.delete(recursive: true);
          }
        } else if (type == 'video') {
          final file = File("${path.path}/videos/$filename");
          final isExists = await file.exists();
          if (isExists) {
            await file.delete(recursive: true);
          }
        }
        prefs.setString('imageslist', jsonEncode(imageslist));
        var jsonResponse = response;
        print('Number of books about http: $jsonResponse.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
    trakcsGalleryPage!.statecheck();
  }

  Future<Database> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'tracks.db');
    await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: onCreate,
    );
  }

  Future onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tracks(
          id INTEGER PRIMARY KEY,
          name TEXT,
          track TEXT,
          markerposition TEXT,
          mapPolylines Text
      )
      ''');
  }
}
