import 'package:android_content_provider/android_content_provider.dart';
import 'package:fluttube/models/song.dart';
import 'package:permission_handler/permission_handler.dart';

class ContentManager {
  /// 自分のインスタンス保持
  static ContentManager? _contentManager;

  /// パーミッション管理
  static PermissionStatus? _permissionStatus;

  /// ストレージの曲を保持するURi
  /// MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
  static String songUri = 'content://media/external/audio/media';

  /// コンストラクタ
  factory ContentManager() {
    _contentManager ??= ContentManager._internal();
    return _contentManager!;
  }

  /// 内部コンストラクタ
  ContentManager._internal();

  /// 初期化
  Future<void> init() async {
    _permissionStatus = await Permission.storage.request();
  }

  /// パーミッションチェック
  Future<bool> checkPermission() async {
    if (_permissionStatus == PermissionStatus.granted) return true;
    await init();
    return _permissionStatus == PermissionStatus.granted;
  }

  /// 曲情報を取得するためのカーソル
  Future<NativeCursor?> _getFetchSongCursor() =>
      AndroidContentResolver.instance.query(
        uri: songUri,
        projection: Song.mediaStoreProjection,
        selection: 'is_music != 0',
        selectionArgs: null,
        sortOrder: null,
      );

  /// カーソルから取得したデータの総数を取得
  Future<int> _getCursorCount(NativeCursor cursor) async =>
      (await cursor.batchedGet().getCount().commit()).first as int;

  /// 曲の総数を取得（外部呼び出しのみの使用）
  Future<int> getSongCount() async {
    final cursor = await _getFetchSongCursor();
    return await _getCursorCount(cursor!);
  }

  /// 曲情報取得
  /// Andoroidのバージョンに関係ない
  Future<List<Song>?> fetchSongs() async {
    NativeCursor? cursor;
    List<Song>? result;
    try {
      cursor = await _getFetchSongCursor();
      final songCount = await _getCursorCount(cursor!);
      final batch = Song.createBatch(cursor);
      final songsData = await batch.commitRange(0, songCount);
      result =
          songsData.map((songData) => Song.fromMediaStore(songData)).toList();
    } catch (e) {
      print(e);
    }
    cursor?.close();
    return result;
  }

  /// アルバムアート取得
  /// Android 10よりも低いバージョンでは使用
  Future<Map<int, String>?> fetchArtPaths() async => null;
}
