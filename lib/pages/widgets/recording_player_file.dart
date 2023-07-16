import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/theme.dart';
import '../../helpers/global_helpers.dart';
import '../../test/test.dart';

class RecordingPlayerFile extends StatefulWidget {
  RecordingPlayerFile({
    super.key,
    required this.files,
  });
  final List<String> files;

  @override
  State<RecordingPlayerFile> createState() => _RecordingPlayerFileState();
}

class _RecordingPlayerFileState extends State<RecordingPlayerFile> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  RxDouble _progress = 0.0.obs;
  RxString _totalDurationString = ''.obs;
  Duration? _totalDuration = Duration();

  @override
  void initState() {
    super.initState();
    onInit();
  }

  onInit() async {
    // isLoading(true);
    mPrint("INITIALIZING AUDIO PLAYER");
    await _audioPlayer.setSource(BytesSource(File(widget.files.first).readAsBytesSync()));
    // isLoading(false);
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _totalDuration = await getTotalAudioDuration(widget.files);
    _totalDurationString.value = '${_totalDuration?.inMinutes} : ${_totalDuration!.inSeconds % 60}';

    _audioPlayer.onPositionChanged.listen((Duration newDuration) async {
      newDuration = (await getTotalAudioDuration(widget.files.sublist(0, _currentPlayingFileIndex))) + newDuration;
      var percentage = (newDuration.inSeconds / _totalDuration!.inSeconds);
      mPrint("UPDATED Percentage :: ${percentage}");
      _progress.value = percentage;
    });

    _audioPlayer.onPlayerComplete.listen((event) async {
      _currentPlayingFileIndex++;

      if (_currentPlayingFileIndex >= widget.files.length) {
        _currentPlayingFileIndex = 0;
        await _audioPlayer.setSource(BytesSource(File(widget.files[_currentPlayingFileIndex]).readAsBytesSync()));
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setSource(BytesSource(File(widget.files[_currentPlayingFileIndex]).readAsBytesSync()));
        await _audioPlayer.resume();
      }

      setState(() {});
    });
  }

  int _currentPlayingFileIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Container(
        height: 70,
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
                    onTap: (progress) {
                      skipToPercentage(progress);
                    },
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

  Future<Duration> getTotalAudioDuration(List<String> filePaths) async {
    int totalDurationInMilliseconds = 0;

    for (String filePath in filePaths) {
      final AudioPlayer player = AudioPlayer();
      final duration = await player.setSourceBytes(File(filePath).readAsBytesSync()).then((_) => player.getDuration());
      totalDurationInMilliseconds += duration!.inMilliseconds;
      await player.release();
    }

    final totalDuration = Duration(milliseconds: totalDurationInMilliseconds);
    return totalDuration;
  }

  Future<void> skipToPercentage(double percentage) async {
    final AudioPlayer audioPlayer = AudioPlayer();

    final desiredPosition = _totalDuration!.inSeconds * percentage;

    int targetIndex = 0;
    double accumulatedDuration = 0;

    for (int i = 0; i < widget.files.length; i++) {
      final file = widget.files[i];
      await audioPlayer.setSource(fileToByte(file));
      final duration = await audioPlayer.getDuration();
      accumulatedDuration += duration!.inSeconds.toDouble();
      if (accumulatedDuration >= desiredPosition) {
        targetIndex = i;
        break;
      }
    }

    final targetFile = widget.files[targetIndex];
    await audioPlayer.setSource(fileToByte(targetFile));
    final offset = desiredPosition - (accumulatedDuration - (await audioPlayer.getDuration())!.inSeconds);

    mPrint("Starting FROM :: ${offset}");

    mPrint("STARTING FROM TARGET INDEX :: ${targetIndex}");
    if (_currentPlayingFileIndex == targetIndex) {
      _audioPlayer.seek(Duration(seconds: offset.toInt()));
    } else {
      await _audioPlayer.play(fileToByte(targetFile), position: Duration(seconds: offset.toInt()));
    }

    setState(() {
      _currentPlayingFileIndex = targetIndex;
    });
  }

  BytesSource fileToByte(String filePath) {
    return BytesSource(File(filePath).readAsBytesSync());
  }
}
