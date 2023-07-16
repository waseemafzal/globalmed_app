import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voice_recorder_flutter/controllers/recordings_controller.dart';
import 'package:voice_recorder_flutter/pages/widgets/recording_player_file.dart';

import '../../config/theme.dart';
import '../../helpers/global_helpers.dart';
import 'app_button.dart';

class VoiceRecorderWidget extends StatefulWidget {
  VoiceRecorderWidget({
    super.key,
    required this.recorderController,
    required this.clear,
  });

  final RecorderController recorderController;
  final void Function() clear;

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  bool isRecording = false;
  final RecordingsController _recordingsController = Get.find();

  late Duration duration;

  @override
  void initState() {
    super.initState();

    duration = widget.recorderController.elapsedDuration;

    widget.recorderController.addListener(() {
      duration = widget.recorderController.recordedDuration;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: kdPadding, vertical: kdPadding),
      padding: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: kcPrimaryColor,
        borderRadius: BorderRadius.circular(kdBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _recordingsController.recordedParts.length > 0 && widget.recorderController.recorderState != RecorderState.recording
              ? RecordingPlayerFile(files: _recordingsController.recordedParts)
              : AudioWaveforms(
                  size: Size(double.infinity, 70.0),
                  recorderController: widget.recorderController,
                  enableGesture: false,
                  waveStyle: WaveStyle(
                    labelSpacing: 10,
                    scaleFactor: 100,
                    waveColor: Colors.white,
                    durationLinesColor: Colors.white,
                    showBottom: true,
                    extendWaveform: true,
                    showMiddleLine: false,
                    durationStyle: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                    showHourInDuration: false,
                  ),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                text: widget.recorderController.isRecording ? "Pause" : "Record",
                onTap: () async {
                  if (widget.recorderController.isRecording) {
                    String? recordedFilePath = await widget.recorderController.stop();
                    mPrint("Current part path -> ${recordedFilePath} -> totalParts -> ${_recordingsController.recordedParts.length + 1}");
                    _recordingsController.recordedParts.add(recordedFilePath!);
                  } else {
                    final path = await getTemporaryDirectory();
                    final name = DateTime.now().toIso8601String() + '.mp3';
                    await widget.recorderController.record(path: '${path.path}/${name}');

                    isRecording = true;

                    // showMightySnackBar(message: "Recording started.", position: SnackPosition.TOP, color: Colors.green, duration: 2);
                  }
                  setState(() {});
                },
                icon: widget.recorderController.isRecording ? Icons.pause : Icons.mic,
                color1: widget.recorderController.isRecording ? Colors.blue : Colors.green,
                color2: widget.recorderController.isRecording ? Colors.blue : Colors.green,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(
                context: context,
                icon: Icons.change_circle_outlined,
                onTap: () async {
                  if ((await showConfirmationDialogue(context: context, text: "Are you sure you want to replace this file?"))) {
                    widget.recorderController.reset();
                    _recordingsController.recordedParts.value = [];
                    showMightySnackBar(message: "Recorded file removed.");
                    widget.clear();
                  }
                  setState(() {});
                  // mPrint('${widget.recorderController.elapsedDuration.inSeconds.toMMSS()} :: ${widget.recorderController.recorderState}');
                },
                title: "Start over",
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildButton({required BuildContext context, required String title, required void Function() onTap, Color color = Colors.red, required IconData icon, Color textColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(kdBorderRadius),
        ),
        // width: 100,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
      ),
    );
  }
}
