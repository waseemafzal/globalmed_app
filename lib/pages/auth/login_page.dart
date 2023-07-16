import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/global_helpers.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../main_page.dart';
import '../widgets/app_button.dart';

import '../../config/theme.dart';
import '../widgets/app_text_field.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();
  final AuthController _authController = Get.find();

  final GlobalKey<FormState> _form = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      _emailEditingController.text = 'seyam';
      _passwordEditingController.text = '12345678';
    }
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(gradient: kcGradient),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/app_logo.png',
                    width: MediaQuery.of(context).size.width * 0.6,
                  ),
                  // Image.asset(
                  //   'assets/images/app_text_logo.png',
                  //   width: MediaQuery.of(context).size.width * 0.5,
                  // ),
                  SizedBox(
                    height: 80,
                  ),
                  Text(
                    "Account",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 40),
                  AppTextField(
                    placeHolder: "Email Or Username",
                    controller: _emailEditingController,
                    validator: (value) => value == null || value.trim().length == 0 ? 'Please enter your email or username.' : null,

                    // validator: (value) => GetUtils.isEmail(value ?? '') ? null : "Please enter a valid email address.",
                  ),
                  AppTextField(
                    placeHolder: "Password",
                    controller: _passwordEditingController,
                    validator: (value) => value == null || value.length == 0 ? 'Please enter your password.' : null,
                    obscureText: true,
                    withBottomPadding: false,
                  ),
                  SizedBox(height: kdPadding),
                  FutureBuilder(
                    future: getUsersCountry(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return SizedBox.shrink();

                      if (!snapshot.hasData) return getLoading();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          snapshot.data!['image'],
                          SizedBox(width: 20),
                          Text(snapshot.data!['name'], style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
                          SizedBox(width: 50),
                          Icon(Icons.keyboard_arrow_down, color: Colors.white)
                        ],
                      );
                    },
                  ),
                  SizedBox(height: kdPadding),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kdPadding),
                    child: Obx(() {
                      return _authController.isLoading.value
                          ? getLoading(color: Colors.white)
                          : AppButton(
                              text: "Login",
                              onTap: () {
                                if (_form.currentState!.validate()) {
                                  _authController.login(email: _emailEditingController.text.trim(), password: _passwordEditingController.text.trim());
                                }
                              },
                            );
                    }),
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => Get.to(() => ForgotPasswordPage()),
                    child: Text(
                      "Forgot password?",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 50),
                  // GestureDetector(
                  //   onTap: () {
                  //     navigateTo(page: RegisterPage(), context: context);
                  //   },
                  //   child: Text(
                  //     "Create Account",
                  //     style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Color(0xffACF0F2), decoration: TextDecoration.underline),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
