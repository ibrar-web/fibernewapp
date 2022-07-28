import 'package:fiberapp/main.dart';
import 'package:flutter/material.dart';
import 'package:fiberapp/screenrendring.dart';

class Navigationpage extends StatefulWidget {
  const Navigationpage({Key? key}) : super(key: key);

  @override
  _NavigationpageState createState() => _NavigationpageState();
}

class _NavigationpageState extends State<Navigationpage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 128.0,
                  height: 100.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 30.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                ),
                ListTile(
                  onTap: () {
                    mainaccess!.key.currentState!.openEndDrawer();
                    switchscreen!.screensfunction('homescreen');
                  },
                  leading: Icon(Icons.home),
                  title: Text('Home     '),
                ),
                ListTile(
                  onTap: () {
                    mainaccess!.key.currentState!.openEndDrawer();
                    switchscreen!.screensfunction('tracks');
                  },
                  leading: Icon(Icons.track_changes),
                  title: Text('Trakcs     '),
                ),
                ListTile(
                  onTap: () {
                    mainaccess!.key.currentState!.openEndDrawer();
                    switchscreen!.screensfunction('Trackgallery');
                  },
                  leading: Icon(Icons.track_changes),
                  title: Text('Tracks Gallery'),
                ),
                // ListTile(
                //   onTap: () {
                //     mainaccess!.key.currentState!.openEndDrawer();
                //     switchscreen!.screensfunction('gallery');
                //   },
                //   leading: Icon(Icons.track_changes),
                //   title: Text('Gallery     '),
                // ),
                // ListTile(
                //   onTap: () {
                //     switchscreen!.stop();
                //     mainaccess!.key.currentState!.openEndDrawer();
                //     switchscreen!.screensfunction('media');
                //   },
                //   leading: Icon(Icons.track_changes),
                //   title: Text('Media'),
                // ),

                ListTile(
                  onTap: () {
                    mainaccess!.key.currentState!.openEndDrawer();
                    switchscreen!.screensfunction('setting');
                  },
                  leading: Icon(Icons.track_changes),
                  title: Text('Setting     '),
                ),
                ListTile(
                  onTap: () {
                    mainaccess!.logout();
                  },
                  leading: Icon(Icons.track_changes),
                  title: Text('Logout'),
                ),
                Spacer(),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: Text('Terms of Service | Privacy Policy'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
