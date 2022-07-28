import 'dart:convert';

import 'package:fiberapp/login/fadeanimation.dart';
import 'package:fiberapp/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = TextEditingController();

  TextEditingController password = TextEditingController();
  Future<dynamic> login() async {
    if (mainaccess!.connectionStatus != ConnectivityResult.none) {
      Future<SharedPreferences> pref = SharedPreferences.getInstance();
      final SharedPreferences prefs = await pref;
      var client = http.Client();
      try {
        final snackBar = SnackBar(content: Text('Verifying Credentials'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        var response = await client.post(
            Uri.https('joyndigital.com', 'Latitude/public/api/fiberlogin'),
            body: {'email': username.text, 'pass': password.text});

        if (response.statusCode == 200 && jsonDecode(response.body) != 0) {
          var jsonResponse = jsonDecode(response.body);
          final snackBar = SnackBar(content: Text('Login Success'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          mainaccess!.loginstatecheck();
          if (prefs.getString('usercredentials') == null) {
            List<dynamic> usercredentials = [];
            prefs.setString('usercredentials', jsonEncode(usercredentials));
          }
          setState(() {
            mainaccess!.userid = jsonResponse['id'];
          });
          String? details = prefs.getString('usercredentials');
          List<dynamic> usercredentials = jsonDecode(details!);
          usercredentials.add({'user_id': jsonResponse['id']});
          prefs.setString('usercredentials', jsonEncode(usercredentials));
        } else {
          print('Request failed with status: ${response.statusCode}.');
          final snackBar =
              SnackBar(content: Text('Invalid Credentials Please Try Again'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } finally {
        client.close();
      }
    }
  }

  @override
  void initState() {
    checkcredential();
    super.initState();
  }

  Future<dynamic> checkcredential() async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    if (prefs.getString('usercredentials') != null) {
      String? details = prefs.getString('usercredentials');
      List usercredentials = jsonDecode(details!);
      setState(() {
        print(usercredentials);
        if (usercredentials.length > 0) {
          mainaccess!.userid = usercredentials[0]['user_id'];
          mainaccess!.loginstatecheck();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              // Colors.purple,
              Colors.cyan,
              Colors.red,
            ])),
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 100),
                child: FadeAnimation(
                  2,
                  Image.asset(
                    "asset/images/logo.png",
                    width: 80,
                  ),
                )),
            Expanded(
              child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50))),
                  margin: const EdgeInsets.only(top: 60),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        if (mainaccess!.connectionStatus ==
                            ConnectivityResult.none)
                          Center(
                              // color: Colors.red,

                              child: const FadeAnimation(
                            2,
                            Text(
                              "No Internet Connection",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black87,
                                  letterSpacing: 2,
                                  fontFamily: "Lobster"),
                            ),
                          )),
                        if (mainaccess!.connectionStatus !=
                            ConnectivityResult.none)
                          Center(
                              // color: Colors.red,

                              child: const FadeAnimation(
                            2,
                            Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 35,
                                  color: Colors.black87,
                                  letterSpacing: 2,
                                  fontFamily: "Lobster"),
                            ),
                          )),
                        FadeAnimation(
                          2,
                          Container(
                              width: double.infinity,
                              height: 60,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 1),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white38, width: 1),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black87,
                                        blurRadius: 10,
                                        offset: Offset(1, 1)),
                                  ],
                                  color: Colors.white.withOpacity(.4),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.email_outlined),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.black),
                                        controller: username,
                                        maxLines: 1,
                                        decoration: const InputDecoration(
                                            label: Text(
                                              " E-mail ...",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                            border: InputBorder.none,
                                            fillColor: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        FadeAnimation(
                          2,
                          Container(
                              width: double.infinity,
                              height: 60,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 1),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white38, width: 1),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black87,
                                        blurRadius: 10,
                                        offset: Offset(1, 1)),
                                  ],
                                  color: Colors.white.withOpacity(.4),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.password_rounded),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: TextFormField(
                                        obscureText: true,
                                        style: TextStyle(color: Colors.black),
                                        controller: password,
                                        maxLines: 1,
                                        decoration: const InputDecoration(
                                          label: Text(
                                            " Password ...",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        FadeAnimation(
                          2,
                          ElevatedButton(
                            onPressed: () {
                              login();
                            },
                            style: ElevatedButton.styleFrom(
                                onPrimary: Colors.purpleAccent,
                                elevation: 18,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            child: Ink(
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: [Colors.black26, Colors.black26]),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                width: 200,
                                height: 50,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.black87,
                                      letterSpacing: 1,
                                      fontFamily: "Lobster"),
                                ),
                              ),
                            ),
                          ),
                        ),
                        FadeAnimation(
                          2,
                          Container(
                              width: double.infinity,
                              height: 70,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(top: 10),
                              child: const Text(
                                " Powered By joynDigital ",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 15),
                              )),
                        ),
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
