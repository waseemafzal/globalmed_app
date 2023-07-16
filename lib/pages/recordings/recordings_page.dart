import 'dart:io';

// import 'package:background_downloader/background_downloader.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:http/retry.dart';
import 'package:ndialog/ndialog.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/recording.dart';
import '../widgets/app_button.dart';

import '../../config/theme.dart';
import '../../controllers/recordings_controller.dart';
import '../../helpers/global_helpers.dart';
import '../widgets/recording_player.dart';
import 'package:http/http.dart' as http;

class RecordingsPage extends StatefulWidget {
  RecordingsPage({super.key});

  @override
  State<RecordingsPage> createState() => _RecordingsPageState();
}

class _RecordingsPageState extends State<RecordingsPage> {
  final RecordingsController _recordingsController = Get.find();

  @override
  void initState() {
    super.initState();
    _recordingsController.fetchRecordings();
  }

  final EasyRefreshController _refreshController = EasyRefreshController();

  int? _downloadIndex;
  double _currentDownloadProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      backgroundColor: kcScaffoldBG,
      body: Obx(() {
        return _recordingsController.isLoading.value
            ? getLoading()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kdPadding, vertical: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: kdPadding, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(kdBorderRadius), boxShadow: [
                        BoxShadow(
                          color: Colors.grey[200]!,
                          spreadRadius: 2,
                          blurRadius: 2,
                        ),
                      ]),
                      child: Row(
                        children: [
                          Expanded(child: Text("Total Files: ${_recordingsController.recordings.length}")),
                          // Icon(Icons.more_vert_rounded),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: EasyRefresh(
                      controller: _refreshController,
                      onRefresh: () async {
                        await _recordingsController.fetchRecordings();
                      },
                      child: Obx(() {
                        return ListView.separated(
                          padding: EdgeInsets.only(left: kdPadding, right: kdPadding, top: kdPadding, bottom: kdPadding * 8),
                          // physics: const BouncingScrollPhysics(),
                          itemCount: _recordingsController.recordings.length,
                          itemBuilder: (context, index) {
                            Recording recording = _recordingsController.recordings[index];
                            return _buildRecordingItem(context: context, recording: recording, index: index);
                          },
                          separatorBuilder: (context, index) => SizedBox(height: kdPadding),
                        );
                      }),
                    ),
                  )
                ],
              );
      }),
    );
  }

  _handlePrescriptionDownload({required int index}) async {
    setState(() {
      _downloadIndex = index;
    });
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(_recordingsController.recordings[index].file));
      final response = await request.close();

      final contentLength = response.contentLength;
      final downloadsDirectory = await getExternalStorageDirectory();

      final file = File('/storage/emulated/0/Download/${_recordingsController.recordings[index].name}');
      final sink = file.openWrite();

      var bytesReceived = 0;
      final buffer = List<int>.filled(1024 * 1024, 0);

      await response.listen(
        (chunk) {
          bytesReceived += chunk.length;
          final progress = ((bytesReceived / contentLength) * 100).toStringAsFixed(2);
          print('Download progress: $progress%');
          setState(() {
            _currentDownloadProgress = bytesReceived / contentLength;
          });
          sink.add(buffer);
        },
        onDone: () {
          sink.close();
          print('Download complete: ${file.path}');
          showMightySnackBar(message: "Prescription downloaded successfully.");
        },
        onError: (error) {
          sink.close();
          print('Download failed: $error');
          showMightySnackBar(message: "Prescription failed.");
        },
        cancelOnError: true,
      );
    } catch (e) {
    } finally {
      setState(() {
        _downloadIndex = null;
      });
    }
  }
  // _handlePrescriptionDownload({required int index}) async {
  //   setState(() {
  //     _downloadIndex = index;
  //   });
  //   try {
  //     /// define the download task (subset of parameters shown)
  //     final task = DownloadTask(
  //       url: _recordingsController.recordings[index].file,
  //       updates: Updates.statusAndProgress, // request status and progress updates
  //       retries: 3,
  //       allowPause: false,
  //     );

  //     final TaskStatusUpdate result = await FileDownloader().download(
  //       task,
  //       onProgress: (progress) => setState(() => _currentDownloadProgress = progress),
  //       onStatus: (status) => print('Status: $status'),
  //     );

  //     if (result.status == TaskStatus.complete) {
  //       showMightySnackBar(message: "Prescription downloaded successfully.");
  //     } else {
  //       showMightySnackBar(message: "Prescription download failed.");
  //     }
  //   } catch (e) {
  //   } finally {
  //     setState(() {
  //       _downloadIndex = null;
  //     });
  //   }
  // }

  Widget _buildRecordingItem({required BuildContext context, required Recording recording, required int index}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: kcPrimaryColor,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _downloadIndex == null || _downloadIndex != index
                  ? GestureDetector(
                      child: Image.asset('assets/icons/download.png', width: 60),
                      onTap: () async {
                        if (_downloadIndex != null) return;

                        if ((await showConfirmationDialogue(context: context, text: "Do you want to download this prescription?"))) {
                          _handlePrescriptionDownload(index: index);
                        }
                      },
                    )
                  : CircularProgressIndicator(
                      value: _currentDownloadProgress,
                      color: kcPrimaryColor,
                    ),
              SizedBox(width: kdPadding),
              Expanded(
                child: RecordingPlayer(recording: recording),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  FlutterShare.share(title: "GlobalMed Transcriptions", linkUrl: recording.shareme);
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: kcPrimaryColor,
                  child: Icon(
                    Icons.share_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  if (!(await showConfirmationDialogue(context: context, text: "Are you sure you want to delete this recording?"))) return;

                  _recordingsController.deleteRecording(id: recording.id);
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: kcPrimaryColor,
                  child: Icon(
                    Icons.delete_outline_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: kdPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${recording.patientName}",
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "${recording.mrnNumber}",
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${formatDate(recording.createdOn)}",
                                // style: Theme.of(context).textTheme.bodySmall,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w300),
                              ),
                              Text(
                                "${recording.name}",
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (TapDownDetails details) async {
                            await showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    // height: 120,
                                    child: ListTile(
                                      onTap: () async {
                                        Navigator.pop(context);
                                        showEditRecordingDialogue(context: context, recording: recording);
                                      },
                                      leading: Icon(
                                        Icons.edit,
                                      ),
                                      title: Text("Edit Recording"),
                                    ),
                                  );
                                });
                          },
                          child: Icon(
                            Icons.more_vert_rounded,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              // Icon(Icons.more_vert_sharp),
            ],
          ),
        ],
      ),
    );
  }
}
