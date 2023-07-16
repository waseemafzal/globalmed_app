// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/auth_controller.dart';
import 'controllers/recordings_controller.dart';
import 'pages/splash_page.dart';
import 'pages/widgets/voice_recorder_widget.dart';

void main() async {
  await GetStorage.init();
  // await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    Get.put(RecordingsController());

    return GetMaterialApp(
      title: 'GlobalMed Transcriptions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
          displaySmall: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      home: SplashPage(),
    );
  }
}
