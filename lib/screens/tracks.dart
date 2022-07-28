import 'package:fiberapp/database/trackdatabase.dart';
import 'package:fiberapp/main.dart';
import 'package:fiberapp/menu/viewtrack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';

_TrackspageState? trackpage;

class Trackspage extends StatefulWidget {
  const Trackspage({Key? key}) : super(key: key);

  @override
  _TrackspageState createState() {
    trackpage = _TrackspageState();
    return trackpage!;
  }
}

class _TrackspageState extends State<Trackspage> {
  int? selectedId;
  final SlidableController slidableController = SlidableController();
  bool uploading = false;
  int? medianumber;
  void trackupload() {
    setState(() {
      uploading = false;
    });
  }

  void updatemedianumber(number) {
    setState(() {
      medianumber = number;
    });
  }

  Future uploadtrackdata(int trackid) async {
    Navigator.of(context).pop();
    if (mainaccess!.connectionStatus == ConnectivityResult.none) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.white,
        title: 'No Internet',
        titleColor: Colors.red,
        message: 'Please make sure to have stable internet',
        duration: Duration(seconds: 3),
        messageColor: Colors.black,
      ).show(context);
      trackupload();
      return;
    }
    try {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.white,
        title: 'Uploading',
        titleColor: Colors.red,
        message: 'Please wait',
        duration: Duration(seconds: 4),
        messageColor: Colors.black,
      ).show(context);
      var status = await DatabaseHelper.instance.uploadtrack(trackid);
      if (status == 200) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: Colors.white,
          title: 'Data Uploaded',
          titleColor: Colors.red,
          message: 'Your all data uploaded to server successfully',
          duration: Duration(seconds: 3),
          messageColor: Colors.black,
        ).show(context);
        trackupload();
      } else if (status == 500) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: Colors.white,
          title: 'Error occured',
          titleColor: Colors.red,
          message: 'some thing went wrong',
          duration: Duration(seconds: 3),
          messageColor: Colors.black,
        ).show(context);
        trackupload();
      }
    } catch (e) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.white,
        title: 'Error occured',
        titleColor: Colors.red,
        message: 'some thing went wrong',
        duration: Duration(seconds: 3),
        messageColor: Colors.black,
      ).show(context);
      trackupload();
      return;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * .9,
          child: Center(
            child: FutureBuilder<List<Data>>(
                future: DatabaseHelper.instance.gettrack(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Data>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text('Loading...'));
                  }
                  return snapshot.data!.isEmpty
                      ? Center(child: Text('No Track in List.'))
                      : ListView(
                          children: snapshot.data!.map((data) {
                            return Center(
                                child: Slidable(
                              controller: slidableController,
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              child: Container(
                                color: selectedId == data.id
                                    ? Colors.white70
                                    : Colors.black,
                                child: ListTile(
                                  title: Text(
                                      'name:${data.name}-time:${data.time}-${data.status} '),
                                  subtitle: Text('Slide right for action'),
                                ),
                              ),
                              actions: <Widget>[
                                IconSlideAction(
                                  caption: 'View',
                                  color: Colors.blue,
                                  icon: Icons.watch,
                                  onTap: () {
                                    {
                                      setState(() {
                                        selectedId = data.id;
                                      });
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              insetPadding: EdgeInsets.zero,
                                              contentPadding: EdgeInsets.zero,
                                              content: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .7,
                                                width: double.infinity,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      ViewTrack(
                                                          track: data.track,
                                                          markerposition: data
                                                              .markerposition),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('Hide'))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    }
                                  },
                                ),
                                IconSlideAction(
                                  caption: 'Upload',
                                  color: Colors.indigo,
                                  icon: Icons.cloud,
                                  onTap: () {
                                    upload(context, data.id!);
                                  },
                                ),
                                IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () {
                                    setState(() {
                                      selectedId = data.id;
                                    });
                                    delete(context, data.id!);
                                  },
                                ),
                              ],
                            ));
                          }).toList(),
                        );
                }),
          ),
        ),
        uploading
            ? Container(
                height: 200.0,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        child: new CircularProgressIndicator(
                          strokeWidth: 5,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius:
                                BorderRadius.all(Radius.circular(60))),
                        width: 120,
                        height: 120,
                        child: Center(
                          child: Text(
                            '''Please Wait Uploading
                            Total Media : $medianumber ''',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
      ],
    );
  }

  Future<String?> upload(BuildContext context, int id) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 30,
              child: Text("Uploading to server"),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      uploading = true;
                    });
                    uploadtrackdata(id);
                  },
                  //onPressed: null,
                  child: Text('Upload')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'))
            ],
          );
        });
  }

  Future<String?> download(BuildContext context, int id) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 30,
              child: Text("Select file format"),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    KmlDownload.instance.writeCounter(10);
                    Navigator.of(context).pop();
                  },
                  //onPressed: null,
                  child: Text('KML')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'))
            ],
          );
        });
  }

  Future<String?> delete(BuildContext context, int id) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Container(
                height: 70,
                child: Text(
                    '''Are you sure you want to delete? Deleting track will also delete track media'''),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        DatabaseHelper.instance.removetrack(id);
                      });

                      Navigator.of(context).pop();
                    },
                    child: Text('Delete')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'))
              ]);
        });
  }
}

class KmlDownload {
  KmlDownload._privateConstructor();
  static final KmlDownload instance = KmlDownload._privateConstructor();
  Future<String> get _localPath async {
    final externalDirectory = Directory(
        '/storage/emulated/0/Android/data/com.ibrar62.surveyapp/files');
    // if ((await externalDirectory.exists())) {
    //   print("exist");
    // } else {
    //   print("not exist");
    //   // await externalDirectory.create();
    // }
    final location = await getExternalStorageDirectories();
    print(location);
    return externalDirectory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString('$counter');
  }
}
