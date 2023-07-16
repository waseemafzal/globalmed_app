import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../pages/main_page.dart';

import '../config/constants.dart';
import '../exceptions/mighty_exception.dart';
import '../helpers/api_helper.dart';
import '../helpers/global_helpers.dart';
import '../models/user.dart';
import '../pages/auth/login_page.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<User?> user = Rx(null);

  register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String country,
  }) async {
    try {
      isLoading(true);
      // final fcmToken = await FirebaseMessaging.instance.getToken();

      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();

      var response = await ApiHelper().post('signup', data: {
        'name': name,
        'email': email,
        'password': password,
        'devicetype': 'android',
        // TODO: REMOVE
        'device_id': 'fcmToken',
        'phone': phone,
        'country': country,
        'timezone': currentTimeZone,
      });

      Get.to(() => LoginPage());
      showMightySnackBar(message: response['message']);
    } on MightyException catch (e) {
      showMightySnackBar(message: e.toString());
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  forgotPassword({required String email}) async {
    try {
      isLoading(true);
      var response = await ApiHelper().post('forgotPassword', data: {
        'email': email,
      });
      Get.to(() => LoginPage());
      showMightySnackBar(message: response['message']);
    } on MightyException catch (e) {
      showMightySnackBar(message: e.toString());
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  contactUs({required String email}) async {
    try {
      isLoading(true);
      var response = await ApiHelper().post(
        'helpcenter',
        data: {
          'message': email,
        },
        isProtected: true,
      );
      showMightySnackBar(message: response['message']);
    } on MightyException catch (e) {
      showMightySnackBar(message: e.toString());
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  login({required String email, required String password}) async {
    try {
      isLoading(true);

      // final fcmToken = await FirebaseMessaging.instance.getToken();
      var response = await ApiHelper().post('login', data: {
        'email': email,
        'password': password,
        'devicetype': 'android',
        // TODO: Remove
        'device_id': 'postaman',
        'social_type': 'normal',
      });
      user.value = User.fromMap(response['user']);
      user.value!.password = password;

      await storeAuthData(user.value!.toMap());

      Get.offAll(() => MainPage());

      // showMightySnackBar(message: response['message']);
    } on MightyException catch (e) {
      showMightySnackBar(message: e.toString());
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<bool> attemptLogin({required String email, required String password}) async {
    await this.login(email: email, password: password);

    if (user.value == null) return false;
    return true;
  }

  logOut() async {
    var box = GetStorage();
    await box.erase();
    this.user.value = null;
    Get.offAll(() => LoginPage());
    showMightySnackBar(message: "Logged out successfully.");
  }

  updateProfile({
    required String name,
    required String phone,
    required String address,
    required String clinic_name,
    required String specialty,
    XFile? image,
  }) async {
    try {
      isLoading(true);
      var uri = Uri.parse("${kcBaseAPIUrl}updateProfile");
      var request = new http.MultipartRequest("POST", uri);
      if (image != null) {
        var stream = new http.ByteStream(DelegatingStream.typed(image.openRead()));
        // get file length
        var length = await image.length();
        var multipartFile = new http.MultipartFile('image', stream, length, filename: image.path);

        request.files.add(multipartFile);

        mPrint("UPLOADING FILE AS WELL");
      }

      request.headers["accesstoken"] = this.user.value!.accessToken;
      request.headers["enctype"] = "multipart/formdata";

      request.fields['name'] = name;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['clinic_name'] = clinic_name;
      request.fields['speciality'] = specialty;

      // if (password.length > 0) {
      //   request.fields['password'] = password;
      //   user.value!.password = password;
      //   await storeAuthData(user.value!.toMap());
      // }

      var response = await request.send();
      print(response.statusCode);

      response.stream.transform(utf8.decoder).listen((value) {
        // user.value!.password = password;
        showMightySnackBar(message: '${jsonDecode(value)['message']}');

        user.value!.name = name;
        user.value!.address = address;
        user.value!.clinic_name = clinic_name;
        user.value!.phone = phone;
        user.value!.specialty = specialty;

        mPrint("UPDATE PROFILE RESPONSE :: ${value}");
      });
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Future<Map<String, dynamic>> fetchProfile() async {
  //   try {
  //     isLoading(true);
  //     Map<String, dynamic> response = await ApiHelper().postDataAuthenticated('profile', {});
  //     return response;
  //   } catch (e) {
  //     printError(info: e.toString());
  //     showMightySnackBar(message: e.toString());
  //     rethrow;
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  // deleteMyAccount() async {
  //   try {
  //     isLoading(true);
  //     Map<String, dynamic> response = await ApiHelper().postDataAuthenticated('deleteAccount', {});
  //     showMightySnackBar(message: response['message']);
  //     this.logOut();
  //   } catch (e) {
  //     printError(info: e.toString());
  //     showMightySnackBar(message: e.toString());
  //     rethrow;
  //   } finally {
  //     isLoading(false);
  //   }
  // }
}
