import 'package:curved_nav_bar/curved_bar/curved_action_bar.dart';
import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'package:curved_nav_bar/flutter_curved_bottom_nav_bar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'recordings/new_recording_page.dart';
import '../config/theme.dart';
import 'profile/profile_page.dart';
import 'recordings/recordings_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CurvedNavBar(
      navBarBackgroundColor: white,
      activeColor: kcPrimaryColor,
      inActiveColor: inActiveBottomBarColor,
      actionButton: CurvedActionBar(
        onTab: (value) {},
        activeIcon: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(color: white, shape: BoxShape.circle),
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(color: kcPrimaryColor, shape: BoxShape.circle),
            child: Image.asset('assets/icons/mic.png', height: 30),
          ),
        ),
        inActiveIcon: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(color: white, shape: BoxShape.circle),
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(color: inActiveBottomBarColor, shape: BoxShape.circle),
            child: Image.asset('assets/icons/mic.png', height: 30),
          ),
        ),
      ),
      appBarItems: [
        FABBottomAppBarItem(
          activeIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/icons/recordings.png',
              height: 20,
              color: kcPrimaryColor,
            ),
          ),
          inActiveIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/icons/recordings.png',
              height: 20,
            ),
          ),
          text: 'Recordings',
        ),
        FABBottomAppBarItem(
          activeIcon: Icon(
            LineIcons.user,
            color: kcPrimaryColor,
          ),
          inActiveIcon: Icon(
            LineIcons.user,
            color: inActiveBottomBarColor,
          ),
          text: 'Profile',
        ),
      ],
      bodyItems: [
        RecordingsPage(),
        ProfilePage(),
      ],
      actionBarView: NewRecordingPage(),
    );
  }
}
