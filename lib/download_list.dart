import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path/path.dart' as path;
// ignore: import_of_legacy_library_into_null_safe
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class UrlState {
  String url;
  bool completed;
  double progress;
  UrlState(this.url, this.completed, this.progress);
}

class UrlStates {
  // List<UrlState> incompList;
  // List<UrlState> compList;
  List<UrlState> displayList;
  bool condition;
  // UrlStates(this.incompList, this.compList, this.displayList);
  UrlStates(this.displayList, this.condition);
}

final downloadListProvider =
    StateNotifierProvider<DownloadListStateNotifier, UrlStates>((_) {
  return DownloadListStateNotifier();
});

List<UrlState> incompList = [];
List<UrlState> compList = [];
bool condition = false;

class DownloadListStateNotifier extends StateNotifier<UrlStates> {
  DownloadListStateNotifier() : super(UrlStates(incompList, condition));
  void setUrl(String url) {
    incompList.add(UrlState(url, false, 0.0));
    state = UrlStates(incompList, false);
    downloadProc(url, incompList);
  }

  void setDisplayList(bool nextCondition) {
    condition = nextCondition;
    if (condition) {
      state = UrlStates(compList, condition);
    } else {
      state = UrlStates(incompList, condition);
    }
  }

  void downloadProc(String url, List<UrlState> status) async {
    var yt = YoutubeExplode();
    var id = VideoId(url);
    var video = await yt.videos.get(id);
    print("Title: ${video.title}");
    print("Title: ${video.duration}");
    await Permission.storage.request();
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var audio = manifest.audioOnly.firstWhere((item) => item.tag == 140);
    var bytes = audio.size.totalBytes;
    var dir = await DownloadsPathProvider.downloadsDirectory;
    var dirM = await Directory(dir.uri.toFilePath() + 'Music/')
        .create(recursive: true);
    // Compose the file name removing the unallowed characters in windows.
    var fileName = '${video.title}.mp3'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');
    print(fileName);
    var filePath =
        // path.join(dirM.path, '${video.id}.${audio.container.name}');
        path.join(dirM.path, fileName);
    var file = File(filePath);
    print(file);
    var fileStream = file.openWrite();

    // Pipe all the content of the stream into our file.
    // await yt.videos.streamsClient.get(audio).pipe(fileStream);
    /*
                  If you want to show a % of download, you should listen
                  to the stream instead of using `pipe` and compare
                  the current downloaded streams to the totalBytes,
                  see an example ii example/video_download.dart
                   */

    // Close the file.

    var audioStream = yt.videos.streamsClient.get(audio);
    var count = 0;
    await for (final data in audioStream) {
      // Keep track of the current downloaded data.
      count += data.length;

      // Calculate the current progress.
      double progress = count / bytes;
      print(progress);

      // Update the progressbar.
      status[0].progress = progress;
      state = UrlStates(status, false);
      // Write to file.
      fileStream.add(data);
    }
    await fileStream.close();

    await fileStream.flush();
    await fileStream.close();
    print("finish");
  }
}
