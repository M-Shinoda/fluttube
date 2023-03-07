import 'dart:convert';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import '../models/download_cache.dart';
import '../models/youtube_model.dart';

class FileManager {
  static FileManager? _fileManager;
  static late String _musicFolderName;
  static late String _playlistSaveFolderName;
  static late String _cacheFolderName;
  static late String _thumbnailFolderName;

  static late Directory _dir;
  static late Directory _dirM;
  static late File _cacheFile;
  static late Directory _dirP;
  static late Directory _dirT;

  final String _cacheFileName = 'cache.txt';

  factory FileManager() {
    _fileManager ??= FileManager._internal();
    return _fileManager!;
  }

  FileManager._internal();

  Future<void> init(
      {required String musicFolderName,
      required String playlistSaveFolderName,
      required String cacheFolderName,
      required String thumbnailFolderName}) async {
    _musicFolderName = musicFolderName;
    _playlistSaveFolderName = playlistSaveFolderName;
    _cacheFolderName = cacheFolderName;
    _thumbnailFolderName = thumbnailFolderName;

    await Permission.storage.request();
    _dir = await DownloadsPathProvider.downloadsDirectory;
    _dirM = await Directory(_dir.uri.toFilePath() + _musicFolderName)
        .create(recursive: true);
    _dirP = await Directory(_dir.uri.toFilePath() + _playlistSaveFolderName)
        .create(recursive: true);
    //TODO:冗長
    _cacheFile = await File(Directory(_dir.uri.toFilePath() + _cacheFolderName)
                .uri
                .toFilePath() +
            _cacheFileName)
        .create(recursive: true);
    _dirT = await Directory(_dir.uri.toFilePath() + _thumbnailFolderName)
        .create(recursive: true);
  }

  // Compose the file name removing the unallowed characters in windows.
  String composeFileName(String title) {
    return title
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');
  }

  String composeFileNameAndExt(String title) {
    return composeFileName(title) + '.mp3';
  }

  // プレイリスト一覧を読み込む
  Future<List<MyPlaylistItem>> readPlaylist(String playlistId) async {
    final playlistFile = await getPlaylistFile(playlistId);

    var playlistString = await playlistFile.readAsString();
    if (playlistString == '') playlistString = '[]';
    final playlistJson = json.decode(playlistString);
    return [
      ...(playlistJson as List<dynamic>)
          .map((data) => MyPlaylistItem.fromStrageJson(data))
    ];
  }

  // プレイリストのファイルを読み込む
  Future<File> getPlaylistFile(String playlistId) async {
    return await File(
            Directory(_dirP.uri.toFilePath()).path + '/$playlistId.txt')
        .create(recursive: true);
  }

  // プレイリストの書き込み
  Future<void> writePlaylist(
      String playlistId, List<MyPlaylistItem> playlistItems) async {
    final playlistItemList = await readPlaylist(playlistId);
    for (var item in playlistItems) {
      playlistItemList.add(item);
    }
    final playlistFile = await getPlaylistFile(playlistId);
    playlistFile.writeAsString(json.encode(playlistItemList));
  }

  // キャッシュの読み込み
  List<DownloadCache> readCache() {
    var cacheString = _cacheFile.readAsStringSync();
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

  // キャッシュの書き込み
  void writeCache(String id, String name, DateTime date, String thumbnailUrl) {
    final cacheList = readCache();
    cacheList.add(DownloadCache(id, name, date, thumbnailUrl));
    _cacheFile.writeAsString(json.encode(cacheList));
  }

  String dirMJoin(String fileName) {
    return path.join(_dirM.path, fileName);
  }

  List<FileSystemEntity> getDirMFileList() {
    return _dirM.listSync();
  }

  List<FileSystemEntity> getDirPFileList() {
    return _dirP.listSync();
  }

  List<FileSystemEntity> getDirTFileList() {
    return _dirT.listSync();
  }

  Future<void> writeThumbnail(String name, String thumbnailUrl) async {
    final res = await http.get(Uri.parse(thumbnailUrl));
    final file = File(_dirT.path + '/' + name + '.png');
    file.create();
    file.writeAsBytesSync(res.bodyBytes);
  }

  String readThumbnail(String name) {
    final file = File(_dirT.path + '/' + name + '.png');
    return file.path;
  }
}
