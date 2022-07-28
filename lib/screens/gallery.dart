import 'dart:io';
import 'package:fiberapp/database/trackdatabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

_GalleryPageState? gallerypage;

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() {
    gallerypage = _GalleryPageState();
    return gallerypage!;
  }
}

class _GalleryPageState extends State<GalleryPage> {
  int? selectedId;
  int? trackid;
  bool uploading = false;
  final SlidableController slidableController = SlidableController();
  VideoPlayerController? _controller;
  void statecheck() {
    setState(() {
      uploading = false;
    });
    print(uploading);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * .9,
          child: Center(
            child: FutureBuilder<List<Medias>>(
                future: DatabaseHelper.instance.getmedia(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Medias>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text('Loading...'));
                  }
                  return snapshot.data!.isEmpty
                      ? Center(child: Text('No Image Found'))
                      : ListView(
                          children: snapshot.data!.map((data) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(6.0, 2, 6, 2),
                              child: Slidable(
                                controller: slidableController,
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedId == data.id
                                        ? Colors.amber
                                        : Colors.white70,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      '${data.name}  Captured time: ${data.time}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    subtitle: Text(
                                      'Slide right for action',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                                actions: <Widget>[
                                  IconSlideAction(
                                    caption: 'View',
                                    color: Colors.blue,
                                    icon: Icons.watch,
                                    onTap: () async {
                                      final Directory path =
                                          await getApplicationDocumentsDirectory();
                                      {
                                        if (data.type == 'video') {
                                          _controller =
                                              VideoPlayerController.network(
                                                  '${path.path}/videos/temporary-1-1/${data.name}')
                                                ..initialize().then((_) {
                                                  // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                                                  setState(() {
                                                    _controller!.play();
                                                  });
                                                });
                                        }

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
                                                      .6,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      if (data.type == 'image')
                                                        Container(
                                                          height: 400,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .95,
                                                          child: PinchZoom(
                                                            child: Image.file(
                                                              File(
                                                                  '${path.path}/images/temporary-1-1/${data.name}'),
                                                              fit: BoxFit.fill,
                                                            ),
                                                            resetDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        100),
                                                            maxScale: 2.5,
                                                            onZoomStart: () {
                                                              print(
                                                                  'Start zooming');
                                                            },
                                                            onZoomEnd: () {
                                                              print(
                                                                  'Stop zooming');
                                                            },
                                                          ),
                                                        ),
                                                      if (data.type == 'video')
                                                        Container(
                                                          height: 400,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .95,
                                                          child: PinchZoom(
                                                            child: AspectRatio(
                                                              aspectRatio:
                                                                  _controller!
                                                                      .value
                                                                      .aspectRatio,
                                                              child: Stack(
                                                                alignment: Alignment
                                                                    .bottomCenter,
                                                                children: <
                                                                    Widget>[
                                                                  VideoPlayer(
                                                                      _controller!),
                                                                  ControlsOverlay(
                                                                      controller:
                                                                          _controller!),
                                                                  VideoProgressIndicator(
                                                                      _controller!,
                                                                      allowScrubbing:
                                                                          true),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        if (data.type ==
                                                            'video') {
                                                          _controller!.value
                                                                  .isPlaying
                                                              ? _controller!
                                                                  .pause()
                                                              // ignore: unnecessary_statements
                                                              : null;
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('cancel')),
                                                ],
                                              );
                                            });
                                      }
                                    },
                                  ),
                                  // IconSlideAction(
                                  //   caption: 'Upload',
                                  //   color: Colors.indigo,
                                  //   icon: Icons.cloud,
                                  //   onTap: () {
                                  //     showDialog(
                                  //         context: context,
                                  //         builder:
                                  //             (BuildContext context) {
                                  //           return AlertDialog(
                                  //             content: Container(
                                  //               height: 130,
                                  //               child: Column(
                                  //                 children: [
                                  //                   Text(
                                  //                       "Uploading to server will delete from App"),
                                  //                   SizedBox(
                                  //                     height: 20,
                                  //                   ),
                                  //                   Row(
                                  //                     children: [
                                  //                       ElevatedButton(
                                  //                           onPressed:
                                  //                               () {
                                  //                             setState(
                                  //                                 () {
                                  //                               DatabaseHelper.instance.uploadmedia(
                                  //                                   data
                                  //                                       .id!,
                                  //                                   data.trackmedia[i]
                                  //                                       [
                                  //                                       'type'],
                                  //                                   data.trackmedia[i]
                                  //                                       [
                                  //                                       'id']);

                                  //                               ///data.id is track id and second is media id
                                  //                             });
                                  //                             Navigator.of(
                                  //                                     context)
                                  //                                 .pop();
                                  //                           },
                                  //                           //onPressed: null,
                                  //                           child: Text(
                                  //                               'Upload')),
                                  //                       ElevatedButton(
                                  //                           onPressed:
                                  //                               () {
                                  //                             Navigator.of(
                                  //                                     context)
                                  //                                 .pop();
                                  //                           },
                                  //                           child: Text(
                                  //                               'Cancel'))
                                  //                     ],
                                  //                   )
                                  //                 ],
                                  //               ),
                                  //             ),
                                  //           );
                                  //         });
                                  //   },
                                  // ),
                                  IconSlideAction(
                                    caption: 'Delete',
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    onTap: () {
                                      setState(() {
                                        selectedId = data.id;
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: Container(
                                                height: 130,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                        "Are you sure you want to delete Delete"),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                DatabaseHelper
                                                                    .instance
                                                                    .removemedia(
                                                                        data.id!);

                                                                ///data.id is track id and second is media id
                                                              });

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            //onPressed: null,
                                                            child:
                                                                Text('Delete')),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child:
                                                                Text('Cancel'))
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                  ),
                                ],
                              ),
                            );
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
                        width: 120,
                        height: 120,
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
                                BorderRadius.all(Radius.circular(50))),
                        width: 110,
                        height: 110,
                        child: Center(
                          child: Text(
                            " Please Wait Uploading",
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
}

class ControlsOverlay extends StatefulWidget {
  const ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  State<ControlsOverlay> createState() => ControlsOverlayState();
}

class ControlsOverlayState extends State<ControlsOverlay> {
  @override
  void initState() {
    widget.controller.play();
    print(widget.controller.value.isPlaying);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                )
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
            });
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: widget.controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              widget.controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in ControlsOverlay._examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${widget.controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
