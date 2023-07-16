import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_audio/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/media_information_session.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voice_recorder_flutter/helpers/global_helpers.dart';

Future<File> concatenateAudioFiles(List<String> audioFilePaths) async {
  MediaInformationSession mediaInfo = await FFprobeKit.getMediaInformation(audioFilePaths.first);
  var lo = await mediaInfo.getAllLogs();
  for (var l in lo) {
    mPrint("""MEDIA INFORMATION :: ${l.getMessage()}""");
  }

  final cacheDirectory = (await getTemporaryDirectory()).path;
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

  // Generate the output file path
  final outputFile = '$cacheDirectory/$timestamp.mp3';

  final command = await generateFFmpegCommand(audioFilePaths, outputFile);
  // Execute the FFmpeg command
  FFmpegSession result = await FFmpegKit.execute(command);
  final code = await result.getReturnCode();

  final logs = await result.getAllLogs();

  for (var l in logs) {
    mPrint("LOGS :: ${l.getMessage()}");
  }

  return File(outputFile);
}

Future<String> generateFFmpegCommand(List<String> audioFiles, String outputFile) async {
  // Generate the FFmpeg command
  final command = [
    '-y', // Overwrite output files without asking
    ...audioFiles.map((file) => '-i $file'), // Add input file arguments
    '-filter_complex',
    'concat=n=${audioFiles.length}:v=0:a=1',
    '-c:a',
    'libmp3lame', // Use the MP3 audio codec
    '-q:a',
    '2', // Adjust the output audio quality as needed (0-9, 0 is highest quality)
    outputFile,
  ];

  // Return the output file path
  return command.join(' ');
}
