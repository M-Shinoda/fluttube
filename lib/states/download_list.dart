import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttube/main.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/url_state.dart';
import '../models/youtube_model.dart';
import '../utils/file_manage.dart';

final downloadListProvider =
    StateNotifierProvider<DownloadListStateNotifier, List<DownloadState>>((_) {
  return DownloadListStateNotifier();
});

var downloadQueue = Queue<String>();
var semaphore = false;

class DownloadListStateNotifier extends StateNotifier<List<DownloadState>> {
  DownloadListStateNotifier() : super([]);

  final yt = YoutubeExplode();

  void _changeStateObject(List<DownloadState> newState) {
    state = [...newState];
  }

  void _addState(DownloadState downloadState) {
    state.add(downloadState);
    _changeStateObject(state);
  }

  void _updateProgress(String targetId, double progress) {
    state.firstWhere((id) => id.id == targetId).progress = progress;
    _changeStateObject(state);
  }

  void _updateCompleted(String targetId, bool completed) {
    state.firstWhere((id) => id.id == targetId).completed = completed;
    _changeStateObject(state);
  }

  // 共有機能から来たURLからIDを抽出（基本これは使わない）
  void setUrl(String url) {
    setVideoId(VideoId(url).value);
  }

  void setVideoId(String id) async {
    _addState(DownloadState(id, false, 0.0));
    downloadQueue.add(id);
    _executeQueue();
  }

  void setPlaylist(String playListId, {bool isWriteCache = true}) async {
    var removeIndexlist = [];
    final playlistItemListRes = await ytApi.playlistItems.list(
        part: 'id,snippet,contentDetails,status',
        playlistId: playListId,
        maxResults: 200);

    final myPlaylistItems = playlistItemListRes.items
        .map((playListItem) => MyPlaylistItem.fromPlaylistItem(playListItem))
        .toList();

    myPlaylistItems.asMap().forEach((index, item) {
      print(item.id);
      print(item.title);
      if (item.title != 'Deleted video') {
        setVideoId(item.id);
      } else {
        removeIndexlist.add(index);
      }
    });
    for (var index in removeIndexlist) {
      myPlaylistItems.removeAt(index);
    }
    if (isWriteCache) {
      FileManager().writePlaylist(playListId, myPlaylistItems);
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

  Future<bool> _download(File file, VideoId id) async {
    final fileStream = file.openWrite();
    StreamManifest manifest;
    try {
      manifest = await yt.videos.streamsClient.getManifest(id);
    } catch (e) {
      print(e);
      file.deleteSync();
      return false;
    }
    final audio = manifest.audioOnly.firstWhere((item) => item.tag == 140);
    var bytes = audio.size.totalBytes;
    final audioStream = yt.videos.streamsClient.get(audio);
    var count = 0;
    double progress = 0.0;
    await for (final data in audioStream) {
      count += data.length;

      progress = count / bytes;
      _updateProgress(id.value, progress);
      fileStream.add(data);
    }
    await fileStream.flush();
    await fileStream.close();
    return true;
  }

  Future<void> downloadProc(String stringId, List<DownloadState> status) async {
    final id = VideoId(stringId);
    final video = await yt.videos.get(id);
    final fileName = FileManager().composeFileNameAndExt(video.title);
    var filePath = FileManager().dirMJoin(fileName);
    var file = File(filePath);
    final result = await _download(file, id);
    if (!result) return;
    FileManager().writeThumbnail(fileName, video.thumbnails.maxResUrl);
    _updateCompleted(id.value, true);
    FileManager().writeCache(
        id.value, fileName, DateTime.now(), video.thumbnails.maxResUrl);
  }

  Future<void> setSearchResult(ExtendsSearchResult item) async {
    if (item.itemKind == ItemKind.playlist) {
      final playlistRes = await ytApi.playlists.list(id: item.id.playlistId);
      // idを指定しているため、1つ以下ののプレイリストが返ってくる
      final playlist = MyPlaylist.fromPlaylist(playlistRes.items.first);
      setPlaylist(playlist.id);
    }
    if (item.itemKind == ItemKind.video) {
      final videoRes = await ytApi.videos.list(id: item.id.videoId);
      inspect(videoRes);
      setVideoId(item.id.videoId!);
    }
  }
}
