import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/recordings_controller.dart';

import '../../config/theme.dart';
import '../../helpers/global_helpers.dart';
import '../../models/recording.dart';
import '../../test/test.dart';

class RecordingPlayer extends StatefulWidget {
  RecordingPlayer({
    super.key,
    required this.recording,
  });

  final Recording recording;

  @override
  State<RecordingPlayer> createState() => _RecordingPlayerState();
}

class _RecordingPlayerState extends State<RecordingPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  RxDouble _progress = 0.0.obs;
  RxString _totalDurationString = ''.obs;
  Duration? _totalDuration = Duration();

  // RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    onInit();
  }

  onInit() async {
    // isLoading(true);
    mPrint("INITIALIZING AUDIO PLAYER");
    await _audioPlayer.setSourceUrl(widget.recording.file);
    // isLoading(false);
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _totalDuration = await _audioPlayer.getDuration();
    _totalDurationString.value = '${_totalDuration?.inMinutes} : ${_totalDuration!.inSeconds % 60}';

    _audioPlayer.onPositionChanged.listen((Duration newDuration) {
      var percentage = (newDuration.inSeconds / _totalDuration!.inSeconds);
      mPrint("UPDATED Percentage :: ${percentage}");
      _progress.value = percentage;
    });

    _audioPlayer.onPlayerComplete.listen((event) async {
      await _audioPlayer.pause();

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Container(
        height: 40,
        decoration: BoxDecoration(
          color: kcPrimaryColor,
          borderRadius: BorderRadius.circular(kdBorderRadius),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                if (_audioPlayer.state == PlayerState.playing) {
                  await _audioPlayer.pause();
                } else {
                  await _audioPlayer.resume();
                }
                setState(() {});
              },
              child: Icon(
                _audioPlayer.state == PlayerState.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Obx(() {
                  return WaveformProgressbar(
                    color: Colors.grey,
                    progressColor: Colors.white,
                    progress: _progress.value,
                    onTap: (progress) {},
                  );
                }),
              ),
            ),
            SizedBox(width: 5),
            Obx(() {
              return _totalDurationString.value.length == 0
                  ? getLoading(color: Colors.white, size: 10)
                  : Text(
                      "${_totalDurationString.value}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    );
            })
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
