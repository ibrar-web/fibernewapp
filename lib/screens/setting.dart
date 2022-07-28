import 'package:fiberapp/screenrendring.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Future markercontrol(int? num) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('markercontrol', num!);
    setState(() {
      switchscreen!.markercontrol = num;
    });
  }

  Future markerinterval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(switchscreen!.markercontroltime.text);
    prefs.setInt('markercontrolinterval',
        int.parse(switchscreen!.markercontroltime.text));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Row(
            children: [
              new Radio(
                  value: 1,
                  groupValue: switchscreen!.markercontrol,
                  onChanged: markercontrol),
              new Text(
                'Manually add marker',
                style: new TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          new Row(
            children: [
              new Radio(
                  value: 2,
                  groupValue: switchscreen!.markercontrol,
                  onChanged: markercontrol),
              new Text(
                'Automatically Add marker',
                style: new TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          if (switchscreen!.markercontrol == 2)
            Padding(
              padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
              child: TextField(
                controller: switchscreen!.markercontroltime,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter time Interval'),
              ),
            ),
          if (switchscreen!.markercontrol == 2)
            ElevatedButton(
                onPressed: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  markerinterval();
                },
                child: Text('save'))
        ],
      ),
    );
  }
}
