import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart' as ap;
// import 'package:just_audio/just_audio.dart';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_recorder_flutter/helpers/ffmpeg.dart';
import '../../config/constants.dart';
import '../../controllers/recordings_controller.dart';
import '../../helpers/global_helpers.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/voice_recorder_widget.dart';

import '../../config/theme.dart';

class NewRecordingPage extends StatefulWidget {
  NewRecordingPage({super.key});

  @override
  State<NewRecordingPage> createState() => _NewRecordingPageState();
}

class _NewRecordingPageState extends State<NewRecordingPage> {
  final RecordingsController _recordingsController = Get.find();

  final TextEditingController _patientNameEditingController = TextEditingController();

  final TextEditingController _mrnNumberEditingController = TextEditingController();

  final TextEditingController _dateEditingController = TextEditingController();

  final GlobalKey<FormState> _form = GlobalKey();

  RecorderController recorderController = RecorderController();

  @override
  Widget build(BuildContext context) {
    if (_dateEditingController.text.trim().length == 0) {
      _dateEditingController.text = formatDate(DateTime.now());
    }

    // if (kDebugMode) {
    //   _mrnNumberEditingController.text = '123456';
    //   _patientNameEditingController.text = 'Test Patient ${Random.secure()}';
    // }

    return Scaffold(
      backgroundColor: kcScaffoldBG,
      appBar: AppBar(
        backgroundColor: kcScaffoldBG,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/app_logo_text_colored.png', width: 250),
          ],
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          children: [
            VoiceRecorderWidget(
              recorderController: recorderController,
              clear: () {
                _mrnNumberEditingController.clear();
                _patientNameEditingController.clear();
              },
            ),
            AppTextField(
              placeHolder: "Enter patient name",
              borderColor: kcPrimaryColor,
              withBottomPadding: false,
              textColor: Colors.black,
              controller: _patientNameEditingController,
              validator: (value) => value == null || value.length == 0 ? 'Please enter patient name.' : null,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kdPadding),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      placeHolder: "MRN",
                      borderColor: kcPrimaryColor,
                      textColor: Colors.black,
                      hPadding: 0,
                      controller: _mrnNumberEditingController,
                      // validator: (value) => value == null || value.length == 0 ? 'Please enter MRN Number.' : null,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              return _recordingsController.isLoading.value
                  ? getLoading()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: kdPadding),
                          child: AppButton(
                            text: "Save to Cloud",
                            icon: Icons.cloud_download_outlined,
                            color1: kcPrimaryColor,
                            color2: kcPrimaryColor,
                            onTap: () async {
                              _uploadRecording('cloud');
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: kdPadding),
                          child: AppButton(
                            text: "Send to FTP",
                            color1: kcPrimaryColor,
                            color2: kcPrimaryColor,
                            icon: Icons.file_download_outlined,
                            onTap: () {
                              _uploadRecording('ftp');
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: kdPadding),
                          child: AppButton(
                            text: "Send to email",
                            color1: kcPrimaryColor,
                            color2: kcPrimaryColor,
                            icon: Icons.email_outlined,
                            onTap: () async {
                              String email = await showEmailDialog(context: context);
                              if (!GetUtils.isEmail(email)) return;

                              _uploadRecording('email', to: email);
                            },
                          ),
                        ),
                      ],
                    );
            }),
          ],
        ),
      ),
    );
  }

  _uploadRecording(String uploadType, {String to = ''}) async {
    if (!_form.currentState!.validate()) return;

    mPrint("Current Recorder State:: ${recorderController.recorderState}");
    if (recorderController.recorderState == RecorderState.recording || _recordingsController.recordedParts.length == 0) {
      return showMightySnackBar(message: "Please stop the recorder or make a new recording to continue.");
    }

    // mPrint("RECORDING FILE :: ${recordedFilePath}");

    File file = await concatenateAudioFiles(_recordingsController.recordedParts);
    // return;

    if (await _recordingsController.uploadRecording(
      patient_name: _patientNameEditingController.text.trim(),
      mrn_number: _mrnNumberEditingController.text.trim(),
      date: _dateEditingController.text.trim(),
      file: file,
      send_type: uploadType,
      to: to,
    )) {
      _mrnNumberEditingController.text = '';
      _patientNameEditingController.text = '';
      _recordingsController.recordedParts.value = [];
      setState(() {});
    }
  }

  Container _buildButton({required BuildContext context, required String title, required void Function() onTap, Color color = Colors.red, required IconData icon, Color textColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(kdBorderRadius),
      ),
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }
}
