import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../main.dart';

class UrlState {
  int id;
  String url;
  bool completed;
  double progress;
  UrlState(this.id, this.url, this.completed, this.progress);
}

class DownloadCache {
  int id;
  String url;
  String name;
  DateTime date;
  String thumbnailUrl;
  DownloadCache(this.id, this.url, this.name, this.date, this.thumbnailUrl);

  DownloadCache.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        url = json['url'],
        name = json['name'] as String,
        date = DateTime.parse(json['date']),
        thumbnailUrl = json['thumbnailUrl'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'url': url, 'name': name, 'date': date.toIso8601String()};
}

final downloadListProvider =
    StateNotifierProvider<DownloadListStateNotifier, List<UrlState>>((_) {
  return DownloadListStateNotifier();
});

List<UrlState> _list = [];
int _id = 0;

class DownloadListStateNotifier extends StateNotifier<List<UrlState>> {
  DownloadListStateNotifier() : super(_list);
  void setUrl(String url) {
    _list.add(UrlState(_id, url, false, 0.0));
    state = [..._list];
    downloadProc(_id, _list);
    _id++;
  }

  void downloadProc(int index, List<UrlState> status) async {
    var yt = YoutubeExplode();
    var id = VideoId(status[index].url);
    var video = await yt.videos.get(id);
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var audio = manifest.audioOnly.firstWhere((item) => item.tag == 140);
    var bytes = audio.size.totalBytes;
    var fileName = _composeFileName(video.title);
    print(fileName);
    var filePath = path.join(dirM.path, fileName);
    var file = File(filePath);
    var fileStream = file.openWrite();

    var audioStream = yt.videos.streamsClient.get(audio);
    var count = 0;
    double progress = 0.0;
    await for (final data in audioStream) {
      count += data.length;

      progress = count / bytes;
      print(progress);
      status[index].progress = progress;
      state = [..._list];
      fileStream.add(data);
    }
    status[index].completed = true;
    state = [..._list];
    await _writeCache(index, status[index].url, fileName, DateTime.now(),
        video.thumbnails.maxResUrl);
    await fileStream.flush();
    await fileStream.close();
  }

  // Compose the file name removing the unallowed characters in windows.
  String _composeFileName(String title) {
    return '$title.mp3'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');
  }

  Future<void> _writeCache(int id, String url, String name, DateTime date,
      String thumbnailUrl) async {
    final cacheList = await readCache();
    cacheList.add(DownloadCache(id, url, name, date, thumbnailUrl));
    cacheFile.writeAsString(json.encode(cacheList));
  }
}

Future<List<DownloadCache>> readCache() async {
  var cacheString = await cacheFile.readAsString();
  if (cacheString == '') cacheString = '[]';
  final cacheJson = json.decode(cacheString);
  return [
    ...(cacheJson as List<dynamic>).map((data) => DownloadCache.fromJson(data))
  ];
}
