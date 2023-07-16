import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/global_helpers.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

import '../../config/theme.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});
  final TextEditingController _emailEditingController = TextEditingController();
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(gradient: kcGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Forgot your password?",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: kdPadding * 3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kdPadding * 2, vertical: 10),
                  child: Text("Enter your email address.", style: Theme.of(context).textTheme.displaySmall),
                ),
                AppTextField(
                  placeHolder: "Email Address",
                  controller: _emailEditingController,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kdPadding),
                  child: Obx(() {
                    return _authController.isLoading.value
                        ? getLoading(color: Colors.white)
                        : AppButton(
                            text: "Submit",
                            onTap: () {
                              if (!GetUtils.isEmail(_emailEditingController.text)) return showMightySnackBar(message: "Please enter a valid email address.");

                              _authController.forgotPassword(email: _emailEditingController.text.trim());
                            });
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
