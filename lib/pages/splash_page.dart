import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../controllers/auth_controller.dart';
import '../helpers/global_helpers.dart';
import 'auth/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  final AuthController _authController = Get.find();

  init() async {
    try {
      Map<String, dynamic> authData = await getAuthDataFromLocalStorage();

      if (await _authController.attemptLogin(email: authData['email'], password: authData['password'])) {
        // Get.offAll(() => MainPage());
      } else {
        Get.offAll(() => LoginPage());
      }
    } catch (e) {
      mPrint("Login failed :: ${e.toString()}");
      Get.offAll(() => LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(gradient: kcGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/app_logo.png',
                height: 130,
              ),
              SizedBox(height: 10),
              // Text(
              //   "GlobalMed Transcriptions",
              //   style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, shadows: [
              //     Shadow(
              //       color: Colors.black,
              //       blurRadius: 10,
              //     ),
              //   ]),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
