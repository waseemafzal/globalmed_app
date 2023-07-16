import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import '../helpers/api_helper.dart';
import '../models/recording.dart';
import 'package:http/http.dart' as http;
import 'package:async/src/delegate/stream.dart';

import '../config/constants.dart';
import '../helpers/global_helpers.dart';

class RecordingsController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isUpdatingPrescription = false.obs;

  RxList<Recording> recordings = RxList();

  RxList<String> recordedParts = RxList();

  fetchRecordings() async {
    isLoading(true);
    try {
      recordings.value = [];
      var response = await ApiHelper().get('getRecordings', isProtected: true);
      recordings.value = Recording.listFromMap(response['data']);

      mPrint("mPrint :: ${recordings.value.length}");
    } catch (e) {
    } finally {
      isLoading(false);
    }
  }

  updateRecording({
    required String patientName,
    required String mrn,
    required String id,
  }) async {
    isUpdatingPrescription(true);
    try {
      var response = await ApiHelper().post('updateRecording', isProtected: true, data: {
        'id': id,
        'mrn_number': mrn,
        'patient_name': patientName,
      });

      Get.back();

      this.fetchRecordings();
      showMightySnackBar(message: "Prescription updated successfully.");
    } catch (e) {
    } finally {
      isUpdatingPrescription(false);
    }
  }

  Future<bool> uploadRecording({
    required String patient_name,
    required String mrn_number,
    required String date,
    required File file,
    required String send_type,
    required String to,
  }) async {
    try {
      isLoading(true);

      mPrint("new file path :: ${file.path}");
      var uri = Uri.parse("${kcBaseAPIUrl}saveRecording");
      var request = new http.MultipartRequest("POST", uri);

      var stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
      // get file length
      var length = await file.length();
      var multipartFile = new http.MultipartFile('file', stream, length, filename: file.path);

      request.files.add(multipartFile);

      mPrint("UPLOADING FILE AS WELL");

      request.headers["accesstoken"] = Get.find<AuthController>().user.value!.accessToken;
      request.headers["enctype"] = "multipart/formdata";

      request.fields['patient_name'] = patient_name;
      request.fields['mrn_number'] = mrn_number;
      request.fields['date'] = date;
      request.fields['send_type'] = send_type;
      request.fields['to'] = to;

      var response = await request.send();
      mPrint(response.statusCode.toString());

      response.stream.transform(utf8.decoder).listen((value) {
        mPrint("API RESPONSE :: ${value}");
        showMightySnackBar(message: '${jsonDecode(value)['message']}');

        mPrint("Sending MP3 File Response :: ${value}");
      });

      return true;
    } catch (e) {
      printError(info: e.toString());
      showMightySnackBar(message: e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }

  deleteRecording({required String id}) async {
    isLoading(true);
    try {
      var response = await ApiHelper().post(
        'deleteRecording',
        isProtected: true,
        data: {'id': id},
      );

      await this.fetchRecordings();
      showMightySnackBar(message: response['message']);
    } catch (e) {
      mPrint(e.toString());
      showMightySnackBar(message: "Something went wrong.");
    } finally {
      isLoading(false);
    }
  }
}
