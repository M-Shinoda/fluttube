import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../main.dart';
import '../youtube/youtube_my_playlist.dart';

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

  void setId(String id) async {
    var yt = YoutubeExplode();
    print(id);
    var video = await yt.videos.get(id);
    setUrl(video.url);
  }

  void setPlaylist(
      MyPlaylist playlist, ValueNotifier<List<PlaylistItem>> playlistItems,
      {bool isWriteCache = true}) async {
    final res = await http.get(Uri.parse(
        'https://www.googleapis.com/youtube/v3/playlistItems?key=AIzaSyCnIYbi-SOIJfaX4bm2JFJtC21dpCu_10Q&part=snippet,contentDetails,status,id&playlistId=${playlist.id}&maxResults=100'));

    final json = jsonDecode(utf8.decode(res.bodyBytes));

    playlistItems.value = (json['items'] as List<dynamic>)
        .map((item) => PlaylistItem.fromJson(item))
        .toList();
    inspect(playlistItems.value);
    inspect(json);
    var removeIndexlist = [];
    playlistItems.value.asMap().forEach((index, item) {
      print(item.id);
      print(item.title);
      if (item.title != 'Deleted video.mp3') {
        setId(item.id);
      } else {
        removeIndexlist.add(index);
      }
    });
    for (var index in removeIndexlist) {
      playlistItems.value.removeAt(index);
    }
    if (isWriteCache) _writePlaylist(playlist.id, playlistItems.value);
  }

  void createPlayList(MyPlaylist playlist) {}

  void downloadProc(int index, List<UrlState> status) async {
    var yt = YoutubeExplode();
    var id = VideoId(status[index].url);
    var video = await yt.videos.get(id);
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var audio = manifest.audioOnly.firstWhere((item) => item.tag == 140);
    var bytes = audio.size.totalBytes;
    var fileName = composeFileName(video.title);
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

  Future<void> _writeCache(int id, String url, String name, DateTime date,
      String thumbnailUrl) async {
    final cacheList = await readCache();
    cacheList.add(DownloadCache(id, url, name, date, thumbnailUrl));
    cacheFile.writeAsString(json.encode(cacheList));
  }

  Future<void> _writePlaylist(
      String playlistId, List<PlaylistItem> playlistItems) async {
    final playlistItemList = await readPlaylist(playlistId);
    for (var item in playlistItems) {
      playlistItemList.add(item);
    }
    final playlistFile = await getPlaylistFile(playlistId);
    playlistFile.writeAsString(json.encode(playlistItemList));
  }
}

Future<List<DownloadCache>> readCache() async {
  var cacheString = await cacheFile.readAsString();
  if (cacheString == '') cacheString = '[]';
  try {
    final cacheJson = json.decode(cacheString);
    print(cacheJson);
    return [
      ...(cacheJson as List<dynamic>)
          .map((data) => DownloadCache.fromJson(data))
    ];
  } catch (e) {
    print(e);
    return [];
  }
}

Future<File> getPlaylistFile(String playlistId) async {
  return await File(Directory(dirP.uri.toFilePath()).path + '/$playlistId.txt')
      .create(recursive: true);
}

Future<List<PlaylistItem>> readPlaylist(String playlistId) async {
  final playlistFile = await getPlaylistFile(playlistId);

  var playlistString = await playlistFile.readAsString();
  if (playlistString == '') playlistString = '[]';
  final playlistJson = json.decode(playlistString);
  return [
    ...(playlistJson as List<dynamic>)
        .map((data) => PlaylistItem.fromStrageJson(data))
  ];
}

// Compose the file name removing the unallowed characters in windows.
String composeFileName(String title) {
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
