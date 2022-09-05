import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path/path.dart' as path;
// ignore: import_of_legacy_library_into_null_safe
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class UrlState {
  int id;
  String url;
  bool completed;
  double progress;
  UrlState(this.id, this.url, this.completed, this.progress);
}

final downloadListProvider =
    StateNotifierProvider<DownloadListStateNotifier, List<UrlState>>((_) {
  return DownloadListStateNotifier();
});

List<UrlState> list = [];
int id = 0;

class DownloadListStateNotifier extends StateNotifier<List<UrlState>> {
  DownloadListStateNotifier() : super(list);
  void setUrl(String url) {
    list.add(UrlState(id, url, false, 0.0));
    state = [...list];
    downloadProc(id, list);
    id++;
  }

  void downloadProc(int index, List<UrlState> status) async {
    var yt = YoutubeExplode();
    var id = VideoId(status[index].url);
    var video = await yt.videos.get(id);
    // ignore: avoid_print
    print("Title: ${video.title}");
    // ignore: avoid_print
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
    // ignore: avoid_print
    print(fileName);
    var filePath =
        // path.join(dirM.path, '${video.id}.${audio.container.name}');
        path.join(dirM.path, fileName);
    var file = File(filePath);
    // ignore: avoid_print
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
    double progress = 0.0;
    await for (final data in audioStream) {
      // Keep track of the current downloaded data.
      count += data.length;

      // Calculate the current progress.
      progress = count / bytes;
      // ignore: avoid_print
      print(progress);

      // Update the progressbar.
      status[index].progress = progress;
      state = [...list];
      // Write to file.
      fileStream.add(data);
    }
    status[index].completed = true;
    state = [...list];
    await fileStream.close();

    await fileStream.flush();
    await fileStream.close();
    // ignore: avoid_print
    print("finish");
  }
}
