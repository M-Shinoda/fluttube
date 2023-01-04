import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/url_state.dart';
import '../models/youtube_model.dart';
import '../utils/file_manage.dart';

final downloadListProvider =
    StateNotifierProvider<DownloadListStateNotifier, List<UrlState>>((_) {
  return DownloadListStateNotifier();
});

var downloadQueue = Queue<int>();
var semaphore = false;

class DownloadListStateNotifier extends StateNotifier<List<UrlState>> {
  DownloadListStateNotifier() : super([]);

  int _id = 0;
  final yt = YoutubeExplode();

  void _changeStateObject(List<UrlState> newState) {
    state = [...newState];
  }

  void _addState(UrlState urlState) {
    state.add(urlState);
    _changeStateObject(state);
  }

  void _updateProgress(int index, double progress) {
    state[index].progress = progress;
    _changeStateObject(state);
  }

  void _updateCompleted(int index, bool completed) {
    state[index].completed = completed;
    _changeStateObject(state);
  }

  void setUrl(String url) {
    _addState(UrlState(_id, url, false, 0.0));
    downloadQueue.add(_id);
    _executeQueue();
    _id++;
  }

  void setId(String id) async {
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

  void _executeQueue() async {
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
        _executeQueue();
      }
    }
  }

  Future<void> _download(File file, VideoId id, int index) async {
    final fileStream = file.openWrite();
    final manifest = await yt.videos.streamsClient.getManifest(id);
    final audio = manifest.audioOnly.firstWhere((item) => item.tag == 140);
    var bytes = audio.size.totalBytes;
    final audioStream = yt.videos.streamsClient.get(audio);
    var count = 0;
    double progress = 0.0;
    await for (final data in audioStream) {
      count += data.length;

      progress = count / bytes;
      _updateProgress(index, progress);
      fileStream.add(data);
    }
    await fileStream.flush();
    await fileStream.close();
  }

  Future<void> downloadProc(int index, List<UrlState> status) async {
    final id = VideoId(status[index].url);
    final video = await yt.videos.get(id);
    final fileName = FileManager().composeFileNameAndExt(video.title);
    var filePath = FileManager().dirMJoin(fileName);
    var file = File(filePath);
    await _download(file, id, index);

    _updateCompleted(index, true);
    await FileManager().writeCache(index, status[index].url, fileName,
        DateTime.now(), video.thumbnails.maxResUrl);
  }
}
