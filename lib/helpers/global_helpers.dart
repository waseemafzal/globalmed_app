import 'dart:async';

import 'package:country_flags/country_flags.dart';
import 'package:country_ip/country_ip.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ndialog/ndialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone_to_country/timezone_to_country.dart';
import '../controllers/recordings_controller.dart';
import '../models/recording.dart';
import '../pages/widgets/app_text_field.dart';
import '../config/theme.dart';
import '../pages/widgets/app_button.dart';

navigateTo({required Widget page, required BuildContext context}) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

navigateReplacement({required Widget page, required BuildContext context}) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
}

showMightySnackBar({required String message, Color color = kcPrimaryColor, SnackPosition position = SnackPosition.BOTTOM, int duration = 5}) {
  Get.showSnackbar(GetSnackBar(
    snackPosition: position,
    message: "${message}",
    duration: Duration(seconds: duration),
    leftBarIndicatorColor: color,

    // margin: const EdgeInsets.all(kdPadding),
  ));
}

getLoading({Color color = kcPrimaryColor, double size = 30}) {
  return Center(
    child: LoadingAnimationWidget.stretchedDots(color: color, size: size),
  );
}

void mPrint(String text) {
  print('\x1B[33m$text\x1B[0m');
}

const stEmailKey = 'EmailKey';
const stPasswordKey = "PasswordKey";
const stMobileKey = "MobileKey";
const stUserData = "MobileKey";
storeAuthData(Map<String, dynamic> user) async {
  final box = GetStorage();
  await box.write(stUserData, jsonEncode(user));
}

Future<Map<String, dynamic>> getAuthDataFromLocalStorage() async {
  final box = GetStorage();
  // final fcmToken = await FirebaseMessaging.instance.getToken();

  mPrint("Local user :: ${box.read(stUserData)}");

  return jsonDecode(box.read(stUserData));
}

String formatDate(DateTime value) {
  String _format = DateFormat('${DateFormat.ABBR_WEEKDAY}, ${DateFormat.DAY} ${DateFormat.MONTH}, ${DateFormat.YEAR}').format(value);

  return _format;
}

Future<bool> showConfirmationDialogue({required BuildContext context, required String text}) async {
  bool answer = false;

  await AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kdBorderRadius - 10)),
    actionsPadding: const EdgeInsets.only(left: kdPadding, right: kdPadding, bottom: kdPadding),
    actionsAlignment: MainAxisAlignment.center,
    insetPadding: const EdgeInsets.all(kdPadding),
    actions: [
      Row(
        children: [
          Expanded(
            child: AppButton(
              text: "Yes",
              color1: Colors.red,
              color2: Colors.red,
              onTap: () {
                answer = true;
                Get.back();
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: AppButton(
              text: "No",
              color1: kcPrimaryColor,
              color2: kcPrimaryColor,
              onTap: () {
                answer = false;
                Get.back();
              },
            ),
          ),
        ],
      ),
    ],
    title: Text(
      text,
      textAlign: TextAlign.center,
    ),
    alignment: Alignment.center,
  ).show(context, dialogTransitionType: DialogTransitionType.Bubble);

  return answer;
}

enum DialogType { Email, ContactUs }

Future<String> showEmailDialog({required BuildContext context, DialogType type = DialogType.Email}) async {
  final TextEditingController _emailEditingController = TextEditingController();

  await AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kdBorderRadius - 10)),
    titlePadding: EdgeInsets.only(top: 10),
    actionsAlignment: MainAxisAlignment.center,
    // insetPadding: const EdgeInsets.symmetric(vertical: kdPadding),
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: kdPadding),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          placeHolder: "Enter ${type == DialogType.Email ? 'email' : 'message'}",
          controller: _emailEditingController,
          textColor: Colors.black,
          borderColor: kcPrimaryColor,
          withBottomPadding: false,
          hPadding: 0,
        ),
        SizedBox(height: 10),
        AppButton(
          text: "Submit",
          color1: kcPrimaryColor,
          color2: kcPrimaryColor,
          onTap: () {
            if (_emailEditingController.text.trim().length == 0) return showMightySnackBar(message: "Please enter something.");
            if (!GetUtils.isEmail(_emailEditingController.text) && type == DialogType.Email) {
              showMightySnackBar(message: "Please enter a valid email address");
            } else {
              Get.back();
            }
          },
        ),
      ],
    ),
    title: Text(
      "Enter ${type == DialogType.Email ? 'email address' : 'message'}",
      textAlign: TextAlign.center,
    ),
    // alignment: Alignment.center,
  ).show(
    context,
    dialogTransitionType: DialogTransitionType.Bubble,
    useSafeArea: true,
  );

  return _emailEditingController.text;
}

Future<String> showEditRecordingDialogue({required BuildContext context, required Recording recording}) async {
  final TextEditingController _patientNameEditingController = TextEditingController(text: recording.patientName);
  final TextEditingController _mrnEditingController = TextEditingController(text: recording.mrnNumber);
  final RecordingsController _recordingsController = Get.find();

  final GlobalKey<FormState> _form = GlobalKey();

  await AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kdBorderRadius - 10)),
    titlePadding: EdgeInsets.only(top: 10),
    actionsAlignment: MainAxisAlignment.center,
    // insetPadding: const EdgeInsets.symmetric(vertical: kdPadding),
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: kdPadding),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: _form,
          child: AppTextField(
            placeHolder: "Patient Name",
            controller: _patientNameEditingController,
            textColor: Colors.black,
            borderColor: kcPrimaryColor,
            withBottomPadding: false,
            validator: (value) => value == null || value.length == 0 ? 'Please enter patient name.' : null,
            hPadding: 0,
          ),
        ),
        SizedBox(height: 10),
        AppTextField(
          placeHolder: "MRN",
          controller: _mrnEditingController,
          textColor: Colors.black,
          borderColor: kcPrimaryColor,
          withBottomPadding: false,
          hPadding: 0,
        ),
        SizedBox(height: 10),
        Obx(() {
          return _recordingsController.isUpdatingPrescription.value
              ? getLoading()
              : AppButton(
                  text: "Submit",
                  color1: kcPrimaryColor,
                  color2: kcPrimaryColor,
                  onTap: () async {
                    if (_form.currentState!.validate()) {
                      await _recordingsController.updateRecording(
                        patientName: _patientNameEditingController.text,
                        mrn: _mrnEditingController.text,
                        id: recording.id,
                      );
                    }
                  },
                );
        }),
      ],
    ),
    title: Text(
      "Edit Recording",
      textAlign: TextAlign.center,
    ),
    // alignment: Alignment.center,
  ).show(
    context,
    dialogTransitionType: DialogTransitionType.Bubble,
    useSafeArea: true,
  );

  return _patientNameEditingController.text;
}

Future<Map<String, dynamic>> getUsersCountry() async {
  final CountryResponse? countryIpResponse = await CountryIp.find();

  String? code;

  if (countryIpResponse == null) {
    code = await TimeZoneToCountry.getLocalCountryCode();
  } else {
    code = countryIpResponse.countryCode;
  }

  return {
    'image': CountryFlag.fromCountryCode(
      code,
      height: 28,
      width: 28,
    ),
    'name': countryIpResponse!.country,
  };
}
