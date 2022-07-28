// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:fiberapp/database/trackdatabase.dart';
import 'package:fiberapp/main.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:fiberapp/screens/homescreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:screenshot/screenshot.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:tapioca/tapioca.dart';

class TrackMedia extends StatefulWidget {
  @override
  _TrackMediaState createState() {
    return _TrackMediaState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
    default:
      throw ArgumentError('Unknown lens direction');
  }
}

void logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

class _TrackMediaState extends State<TrackMedia>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  ScreenshotController screenshotController = ScreenshotController();
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  TextStyle textstyle = TextStyle(color: Colors.indigo[600]!.withOpacity(0.9));
  late AnimationController _flashModeControlRowAnimationController;
  late Animation<double> _flashModeControlRowAnimation;
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;
  late AnimationController _focusModeControlRowAnimationController;
  late Animation<double> _focusModeControlRowAnimation;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  TextEditingController textcontroller = TextEditingController();
  TextEditingController trackname = TextEditingController();
  var loader = false;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  bool cond = false;
  LocationData? location;
  Location locationnew = new Location();
  int camerasid = 0;
  // ignore: cancel_subscriptions

  // ignore: unused_field
  bool _hasPermissions = false;
  bool processing = false;
  // ignore: unused_field
  CompassEvent? _lastRead;
  double? direction;
  void start() async {
    location = await locationnew.getLocation();

    Future.delayed(Duration(seconds: 1), () {
      if (cond) {
        setState(() {
          location = location;
        });
        print('calling');
        start();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
    cond = true;
    start();
    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
    if (cameras.isNotEmpty) {
      onNewCameraSelected(cameras[0]);
      print(cameras[0]);
    }
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    cond = false;

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Center(
              child: cameraPreviewWidget(),
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: controller != null && controller!.value.isRecordingVideo
                  ? Colors.redAccent
                  : Colors.grey,
              width: 3.0,
            ),
          ),
        ),
        _captureControlRowWidget(),
        _modeControlRowWidget(),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _cameraTogglesRowWidget(),
              // _thumbnailWidget(),
            ],
          ),
        ),
      ],
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
          onPointerDown: (_) => _pointers++,
          onPointerUp: (_) => _pointers--,
          child: Stack(
            children: [
              if (!processing)
                RotatedBox(
                    quarterTurns: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 3
                        : 0,
                    child: AspectRatio(
                      aspectRatio: controller!.value.aspectRatio / 1.6,
                      child: CameraPreview(
                        controller!,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onScaleStart: _handleScaleStart,
                            onScaleUpdate: _handleScaleUpdate,
                            onTapDown: (details) =>
                                onViewFinderTap(details, constraints),
                          );
                        }),
                      ),
                    )),
              Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      if (location != null)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Latitude:${location!.latitude},Longitude:${location!.longitude}',
                            style: textstyle,
                          ),
                        ),
                      if (location != null)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Accuracy:${location!.latitude}',
                            style: textstyle,
                          ),
                        ),
                      if (location != null)
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Time:${DateTime.fromMillisecondsSinceEpoch(location!.time! ~/ 1)}',
                              style: textstyle,
                            )),
                      if (direction != null) directionvale(),
                      if (location == null)
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Location is not available',
                              style: textstyle,
                            )),
                      loader
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50))),
                                      width: 110,
                                      height: 110,
                                      child: Center(
                                        child: Text(
                                          " Please Wait Creating Video",
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
                  )),
              Align(alignment: Alignment.topRight, child: buildCompass()),
            ],
          ));
    }
  }

  Widget directionvale() {
    double val;

    if (direction! > 0) {
      val = direction!;
    } else {
      val = 360 + (direction!);
    }
    return Row(
      children: [
        if (val == 0)
          Text(
            'N',
            style: textstyle,
          ),
        if (val > 0 && val < 90)
          Text(
            'NE',
            style: textstyle,
          ),
        if (val == 90)
          Text(
            'E',
            style: textstyle,
          ),
        if (val > 90 && val < 180)
          Text(
            'ES',
            style: textstyle,
          ),
        if (val == 180)
          Text(
            'S',
            style: textstyle,
          ),
        if (val > 180 && val < 270)
          Text(
            'SW',
            style: textstyle,
          ),
        if (val == 270)
          Text(
            'W',
            style: textstyle,
          ),
        if (val > 270 && val < 360)
          Text(
            'WN',
            style: textstyle,
          ),
        SizedBox(
          width: 20,
        ),
        Text(
          val.toStringAsFixed(0),
          style: textstyle,
        ),
      ],
    );
  }

  Widget directionvale2(double direction) {
    double val;

    if (direction > 0) {
      val = direction;
    } else {
      val = 360 + (direction);
    }
    return Row(
      children: [
        if (val == 0)
          Text(
            'N',
            style: textstyle,
          ),
        if (val > 0 && val < 90)
          Text(
            'NE',
            style: textstyle,
          ),
        if (val == 90)
          Text(
            'E',
            style: textstyle,
          ),
        if (val > 90 && val < 180)
          Text(
            'ES',
            style: textstyle,
          ),
        if (val == 180)
          Text(
            'S',
            style: textstyle,
          ),
        if (val > 180 && val < 270)
          Text(
            'SW',
            style: textstyle,
          ),
        if (val == 270)
          Text(
            'W',
            style: textstyle,
          ),
        if (val > 270 && val < 360)
          Text(
            'WN',
            style: textstyle,
          ),
        SizedBox(
          width: 20,
        ),
        Text(
          val.toStringAsFixed(0),
          style: textstyle,
        ),
      ],
    );
  }

  Widget buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        direction = snapshot.data!.heading;
        // var isPortrait = MediaQuery.of(context).orientation;
        // print(isPortrait);
        if (camerasid == 1) {
          print('front camera');
          if (direction! < 0) {
            direction = 360 + direction!;
          }

          direction = direction! + 180;
          if (direction! > 360) {
            direction = direction! - 360;
          }
        }

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 30, 0),
            child: CustomPaint(
                foregroundPainter: CompassPainter(angle: direction),
                child: Text(
                    '${direction! > 0 ? direction!.toStringAsFixed(0) : (360 + direction!).toStringAsFixed(0)} °',
                    style: textstyle)));
      },
    );
  }

  Widget buildCompass2(double direction) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 50, 30, 0),
        child: CustomPaint(
            foregroundPainter: CompassPainter(angle: direction),
            child: Text(
                '${direction > 0 ? direction.toStringAsFixed(0) : (360 + direction).toStringAsFixed(0)} °',
                style: textstyle)));
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  /// Display a bar with buttons to change the flash and exposure modes
  Widget _modeControlRowWidget() {
    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   mainAxisSize: MainAxisSize.max,
        //   children: <Widget>[
        //     IconButton(
        //       icon: Icon(Icons.flash_on),
        //       color: Colors.blue,
        //       onPressed: controller != null ? onFlashModeButtonPressed : null,
        //     ),
        //     // The exposure and focus mode are currently not supported on the web.
        //     ...(!kIsWeb
        //         ? [
        //             IconButton(
        //               icon: Icon(Icons.exposure),
        //               color: Colors.blue,
        //               onPressed: controller != null
        //                   ? onExposureModeButtonPressed
        //                   : null,
        //             ),
        //             IconButton(
        //               icon: Icon(Icons.filter_center_focus),
        //               color: Colors.blue,
        //               onPressed:
        //                   controller != null ? onFocusModeButtonPressed : null,
        //             )
        //           ]
        //         : []),
        //     // IconButton(
        //     //   icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute),
        //     //   color: Colors.blue,
        //     //   onPressed: controller != null ? onAudioModeButtonPressed : null,
        //     // ),
        //     IconButton(
        //       icon: Icon(controller?.value.isCaptureOrientationLocked ?? false
        //           ? Icons.screen_lock_rotation
        //           : Icons.screen_rotation),
        //       color: Colors.blue,
        //       onPressed: controller != null
        //           ? onCaptureOrientationLockButtonPressed
        //           : null,
        //     ),
        //   ],
        // ),
        _flashModeControlRowWidget(),
        _exposureModeControlRowWidget(),
        _focusModeControlRowWidget(),
      ],
    );
  }

  Widget _flashModeControlRowWidget() {
    return SizeTransition(
      sizeFactor: _flashModeControlRowAnimation,
      child: ClipRect(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              icon: Icon(Icons.flash_off),
              color: controller?.value.flashMode == FlashMode.off
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.off)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.flash_auto),
              color: controller?.value.flashMode == FlashMode.auto
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.auto)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.flash_on),
              color: controller?.value.flashMode == FlashMode.always
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.always)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.highlight),
              color: controller?.value.flashMode == FlashMode.torch
                  ? Colors.orange
                  : Colors.blue,
              onPressed: controller != null
                  ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _exposureModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: controller?.value.exposureMode == ExposureMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: controller?.value.exposureMode == ExposureMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Center(
                child: Text("Exposure Mode"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    child: Text('AUTO'),
                    style: styleAuto,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) {
                        controller!.setExposurePoint(null);
                        showInSnackBar('Resetting exposure point');
                      }
                    },
                  ),
                  TextButton(
                    child: Text('LOCKED'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () =>
                            onSetExposureModeButtonPressed(ExposureMode.locked)
                        : null,
                  ),
                  TextButton(
                    child: Text('RESET OFFSET'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => controller!.setExposureOffset(0.0)
                        : null,
                  ),
                ],
              ),
              Center(
                child: Text("Exposure Offset"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(_minAvailableExposureOffset.toString()),
                  Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    label: _currentExposureOffset.toString(),
                    onChanged: _minAvailableExposureOffset ==
                            _maxAvailableExposureOffset
                        ? null
                        : setExposureOffset,
                  ),
                  Text(_maxAvailableExposureOffset.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _focusModeControlRowWidget() {
    final ButtonStyle styleAuto = TextButton.styleFrom(
      primary: controller?.value.focusMode == FocusMode.auto
          ? Colors.orange
          : Colors.blue,
    );
    final ButtonStyle styleLocked = TextButton.styleFrom(
      primary: controller?.value.focusMode == FocusMode.locked
          ? Colors.orange
          : Colors.blue,
    );

    return SizeTransition(
      sizeFactor: _focusModeControlRowAnimation,
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade50,
          child: Column(
            children: [
              Center(
                child: Text("Focus Mode"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    child: Text('AUTO'),
                    style: styleAuto,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.auto)
                        : null,
                    onLongPress: () {
                      if (controller != null) controller!.setFocusPoint(null);
                      showInSnackBar('Resetting focus point');
                    },
                  ),
                  TextButton(
                    child: Text('LOCKED'),
                    style: styleLocked,
                    onPressed: controller != null
                        ? () => onSetFocusModeButtonPressed(FocusMode.locked)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  !cameraController.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
        ),
        // IconButton(
        //   icon: const Icon(Icons.videocam),
        //   color: Colors.blue,
        //   onPressed: cameraController != null &&
        //           cameraController.value.isInitialized &&
        //           !cameraController.value.isRecordingVideo
        //       ? onVideoRecordButtonPressed
        //       : null,
        // ),
        // IconButton(
        //   icon: cameraController != null &&
        //           cameraController.value.isRecordingPaused
        //       ? Icon(Icons.play_arrow)
        //       : Icon(Icons.pause),
        //   color: Colors.blue,
        //   onPressed: cameraController != null &&
        //           cameraController.value.isInitialized &&
        //           cameraController.value.isRecordingVideo
        //       ? (cameraController.value.isRecordingPaused)
        //           ? onResumeButtonPressed
        //           : onPauseButtonPressed
        //       : null,
        // ),
        // IconButton(
        //   icon: const Icon(Icons.stop),
        //   color: Colors.red,
        //   onPressed: cameraController != null &&
        //           cameraController.value.isInitialized &&
        //           cameraController.value.isRecordingVideo
        //       ? onStopButtonPressed
        //       : null,
        // ),
        // IconButton(
        //   icon: const Icon(Icons.pause_presentation),
        //   color:
        //       cameraController != null && cameraController.value.isPreviewPaused
        //           ? Colors.red
        //           : Colors.blue,
        //   onPressed:
        //       cameraController == null ? null : onPausePreviewButtonPressed,
        // ),
        IconButton(
          icon: Icon(Icons.flash_on),
          color: Colors.blue,
          onPressed: controller != null ? onFlashModeButtonPressed : null,
        ),
        // The exposure and focus mode are currently not supported on the web.
        ...(!kIsWeb
            ? [
                IconButton(
                  icon: Icon(Icons.exposure),
                  color: Colors.blue,
                  onPressed:
                      controller != null ? onExposureModeButtonPressed : null,
                ),
                IconButton(
                  icon: Icon(Icons.filter_center_focus),
                  color: Colors.blue,
                  onPressed:
                      controller != null ? onFocusModeButtonPressed : null,
                )
              ]
            : []),
        // IconButton(
        //   icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute),
        //   color: Colors.blue,
        //   onPressed: controller != null ? onAudioModeButtonPressed : null,
        // ),
        IconButton(
          icon: Icon(controller?.value.isCaptureOrientationLocked ?? false
              ? Icons.screen_lock_rotation
              : Icons.screen_rotation),
          color: Colors.blue,
          onPressed:
              controller != null ? onCaptureOrientationLockButtonPressed : null,
        ),
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    final onChanged = (CameraDescription? description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
    };

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged:
                  controller != null && controller!.value.isRecordingVideo
                      ? null
                      : onChanged,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    setState(() {
      camerasid = int.parse(cameraDescription.name);
    });
    if (controller != null) {
      await controller!.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        // The exposure mode is currently not supported on the web.
        ...(!kIsWeb
            ? [
                cameraController
                    .getMinExposureOffset()
                    .then((value) => _minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((value) => _maxAvailableExposureOffset = value)
              ]
            : []),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() async {
    double directionval = direction!;
    final Directory path = await getApplicationDocumentsDirectory();
    final pathcheck = Directory("${path.path}/images");
    final pathcheck2 =
        Directory("${path.path}/images/${switchscreen!.trackname}");
    if ((await pathcheck.exists())) {
      print("exist");
    } else {
      print("not exist");
      pathcheck.create();
    }
    if ((await pathcheck2.exists())) {
      print("exist");
    } else {
      print("not exist");
      pathcheck2.create();
    }
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController?.dispose();
          videoController = null;
        });
        if (file != null) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Container(
                    height: 100,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: TextField(
                            controller: textcontroller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Save Image',
                              hintText: 'Add Image Name',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          textcontroller.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel')),
                    ElevatedButton(
                        onPressed: () {
                          homescreenvar!.updatesavestatus();
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          switchscreen!.savetrack();
                          saveimage(
                              file, textcontroller.text, path, directionval);
                        },
                        child: Text('Save'))
                  ],
                );
              });
        }
      }
    });
  }

  void saveimage(
    XFile file,
    String name,
    Directory path,
    directionval,
  ) async {
    homescreenvar!.alert(Colors.white, 'Creating GEOTAG', Colors.red,
        'Please wait creating geotagged image', Colors.black, 4);
    var screenshot = Container(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: Image.file(File(file.path), fit: BoxFit.fill),
            ),
            Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    if (location != null)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Latitude:${location!.latitude},Longitude:${location!.longitude}',
                          style: textstyle,
                        ),
                      ),
                    if (location != null)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Accuracy:${location!.latitude}',
                          style: textstyle,
                        ),
                      ),
                    if (location != null)
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Time:${DateTime.fromMillisecondsSinceEpoch(location!.time! ~/ 1)}',
                            style: textstyle,
                          )),
                    if (direction != null) directionvale2(directionval),
                    if (location == null)
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Location is not available',
                            style: textstyle,
                          )),
                  ],
                )),
            Align(
                alignment: Alignment.topRight,
                child: buildCompass2(directionval)),
          ],
        ));
    screenshotController
        .captureFromWidget(
            InheritedTheme.captureAll(context, Material(child: screenshot)),
            delay: Duration(seconds: 1))
        .then((capturedImage) async {
      final imagePath = File(
          '${path.path}/images/${switchscreen!.trackname}/${textcontroller.text}.png');
      bool fileExists = await imagePath.exists();
      if (fileExists) {
        //backgroundcolor,title,titlecolor,message,messagecolor,duration
        homescreenvar!.alert(
            Colors.white,
            'Media Exist',
            Colors.red,
            'Please Change name image with same name already exist',
            Colors.black,
            3);
        homescreenvar!.updatesavestatus();
        return;
      }
      try {
        await imagePath.writeAsBytes(capturedImage);
        if (await DatabaseHelper.instance.addtrackmedia(
                '${textcontroller.text}.png',
                'image',
                location!,
                'track_media_') ==
            1) {
          if (mounted) {
            Navigator.pop(context, true);
          }
          homescreenvar!.alert(Colors.white, 'Media Saved', Colors.green,
              'Media Saved in track gallery', Colors.black, 3);
          homescreenvar!.updatesavestatus();
        }
      } catch (e) {
        homescreenvar!.alert(Colors.white, 'Error occured', Colors.red,
            'Something went wrong please try again', Colors.black, 3);
        if (mounted) {
          Navigator.pop(context, true);
        }
        homescreenvar!.updatesavestatus();
        return;
      }
      textcontroller.clear();
      return;
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller!.description);
    }
  }

  void onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  void onStopButtonPressed() async {
    final Directory path = await getApplicationDocumentsDirectory();
    final pathcheck = Directory("${path.path}/videos");
    if ((await pathcheck.exists())) {
      print("exist");
    } else {
      print("not exist");
      pathcheck.create();
    }
    await stopVideoRecording().then((file) {
      if (file != null) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                  height: 100,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: TextField(
                          controller: textcontroller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Save Video',
                            hintText: 'Add Video Name',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () async {
                        textcontroller.clear();
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel')),
                  ElevatedButton(
                      onPressed: () async {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        setState(() {
                          loader = true;
                          processing = true;
                        });
                        Navigator.of(context).pop();
                        processvideo(file, path, textcontroller.text);
                      },
                      child: Text('Save'))
                ],
              );
            });
        videoFile = file;
        // _startVideoPlayer();
      }
    });
  }

  Future processvideo(XFile file, Directory path, String name) async {
    try {
      final tapiocaBalls = [
        TapiocaBall.textOverlay(
            "${location!.latitude!.toStringAsFixed(5)}_${location!.longitude!.toStringAsFixed(5)} ${DateTime.fromMillisecondsSinceEpoch(location!.time! ~/ 1)}",
            1,
            10,
            12,
            Color(0xff000000)),
      ];
      final cup = Cup(Content(file.path), tapiocaBalls);
      setState(() {
        loader = true;
      });
      Timer(Duration(seconds: 2), () {
        cup.suckUp('${path.path}/videos/$name.mp4').then((_) {
          DatabaseHelper.instance.addtrackmedia(
              '${textcontroller.text}.mp4', 'video', location!, 'track_media_');
          textcontroller.clear();
          setState(() {
            loader = false;
            processing = false;
          });
        });
      });
    } on PlatformException {
      setState(() {
        loader = false;
      });
      print("error!!!!");
    }
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isPreviewPaused) {
      await cameraController.resumePreview();
    } else {
      await cameraController.pausePreview();
    }

    if (mounted) setState(() {});
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? camera = controller;

    if (camera == null || !camera.value.isRecordingVideo) {
      return null;
    }

    try {
      return camera.stopVideoRecording();
      // ignore: unused_catch_clause
    } on CameraException catch (e) {
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.

T? _ambiguate<T>(T? value) => value;

class CompassPainter extends CustomPainter {
  CompassPainter({required this.angle}) : super();
  final double? angle;
  double get rotation => -2 * math.pi * (angle! / 360);

  Paint get _brush => new Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;
  @override
  void paint(Canvas canvas, Size size) {
    Paint circle = _brush..color = Colors.indigo[400]!.withOpacity(0.6);

    Paint needle = _brush..color = Colors.red[600]!;

    double radius = min(35, 35);
    Offset center = Offset(size.width / 2, size.height / 2);
    Offset? start = Offset.lerp(Offset(center.dx, radius + 14), center, .4);
    Offset? end = Offset.lerp(Offset(center.dx, radius + 17), center, 0.1);

    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawLine(start!, end!, needle);
    canvas.drawCircle(center, radius, circle);
  }

  @override
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
