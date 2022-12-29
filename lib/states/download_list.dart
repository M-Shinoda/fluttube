import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../utils/file_manage.dart';
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
var downloadQueue = Queue<int>();
var semaphore = false;

class DownloadListStateNotifier extends StateNotifier<List<UrlState>> {
  DownloadListStateNotifier() : super(_list);
  void setUrl(String url) {
    _list.add(UrlState(_id, url, false, 0.0));
    state = [..._list];
    downloadQueue.add(_id);
    executeQueue();
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
    if (isWriteCache) {
      FileManager().writePlaylist(playlist.id, playlistItems.value);
    }
  }

  void createPlayList(MyPlaylist playlist) {}

  void executeQueue() async {
    if (downloadQueue.isNotEmpty && !semaphore) {
      semaphore = true;
      try {
        await downloadProc(downloadQueue.first, state);
      } catch (e) {
        print(e);
      }
      downloadQueue.removeFirst();
      semaphore = false;
      if (downloadQueue.isNotEmpty) {
        executeQueue();
      }
    }
  }

  Future<void> downloadProc(int index, List<UrlState> status) async {
    var yt = YoutubeExplode();
    var id = VideoId(status[index].url);
    var video = await yt.videos.get(id);
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var audio = manifest.audioOnly.firstWhere((item) => item.tag == 140);
    var bytes = audio.size.totalBytes;
    var fileName = FileManager().composeFileNameAndExt(video.title);
    print(fileName);
    var filePath = FileManager().dirMJoin(fileName);
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
    await FileManager().writeCache(index, status[index].url, fileName,
        DateTime.now(), video.thumbnails.maxResUrl);
    await fileStream.flush();
    await fileStream.close();
  }
}
