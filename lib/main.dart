import 'dart:convert';

import 'package:fiberapp/login/login.dart';
import 'package:fiberapp/navigation.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:fiberapp/screens/media.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_background_service/flutter_background_service.dart';
List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  // FlutterBackgroundService.initialize(onStart);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color.fromRGBO(32, 33, 36, 1.0),
          appBarTheme: AppBarTheme(),
          primarySwatch: Colors.blue,
          primaryColor: Color.fromRGBO(48, 49, 52, 1.0),
          iconTheme: IconThemeData(color: Colors.white)),
      home: MainScreen()));
}

_MainScreenState? mainaccess;

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() {
    mainaccess = _MainScreenState();
    return mainaccess!;
  }
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  double borderRadius = 0.0;
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  String baseurl = 'joynsoftware.com';
  String baseurl2 = 'https://joynsoftware.com/backend/public';
  bool loginstate = false;
  //customer id
  int? userid;
  //worker id
  int? workerid;
  void loginstatecheck() {
    setState(() {
      loginstate = true;
    });
  }

  void logout() async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    setState(() {
      loginstate = false;
    });
    if (prefs.getString('usercredentials') != null) {
      List<dynamic> usercredentials = [];
      prefs.setString('usercredentials', jsonEncode(usercredentials));
    }
  }

  Future<bool> showExitPopup(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Do you want to logout?"),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            logout();
                            Navigator.of(context).pop();
                          },
                          child: Text("Yes"),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red.shade800),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child:
                            Text("No", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      connectionStatus = result;
      print(connectionStatus);
      print('connectionStatus');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: loginstate ? dashboard(context) : LoginPage(),
    );
  }

  Widget menu(context) {
    return Navigationpage();
  }

  Widget dashboard(context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: SafeArea(
          child: Material(
        child: Scaffold(
            key: key,
            appBar: AppBar(
              // ignore: unrelated_type_equality_checks
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    'asset/images/logo.png',
                    fit: BoxFit.contain,
                    height: 25,
                  ),
                  Text('J-Survey'),
                  Icon(
                    Icons.wifi,
                    color: connectionStatus == ConnectivityResult.none
                        ? Colors.red
                        : Colors.white,
                  ),
                ],
              ),
              leading: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    key.currentState!.openDrawer();
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  }),
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics(),
              child: Screenrendring(),
            ),
            drawer: Drawer(child: menu(context))),
      )),
    );
  }
}
