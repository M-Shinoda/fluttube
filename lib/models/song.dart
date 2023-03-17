import 'package:android_content_provider/android_content_provider.dart';
import 'package:audio_service/audio_service.dart';

class Song {
  /// Android Content Resolver id
  final int id;

  /// song title
  final String title;

  // /// other
  // final String? album;
  // final int albumId;
  // final String artist;

  /// The content URI of the song for playback.
  /// extras"loadThumbnailUri"での使用目的がわからない
  String get uri => 'content://media/external/audio/media/$id';

  /// The content URI of the art.
  /// アルバムアートのURI
  String get artUri => 'content://media/external/audio/media/$id/albumart';

  /// 拡張情報
  Map<String, dynamic> get extras => {
        'loadThumbnailUri': uri, // 意味があるかわからず
        'url': uri, // 現状の曲ファイル指定用URI
      };

  /// コンストラクタ
  const Song({
    required this.id,
    required this.title,
    // this.album,
    // this.albumId,
    // this.artist,
  });

  /// MediaItem変換
  MediaItem toMediaItem() => MediaItem(
        id: id.toString(),
        title: title,
        artUri: Uri.parse(artUri),
        album: '',
        extras: extras,
      );

  /// データベースでたとえるとselect句の要素配列
  static const mediaStoreProjection = [
    '_id',
    'album',
    'album_id',
    'artist',
    'title',
  ];

  /// Returns a markup of what data to get from the cursor.
  /// カーソルからバッチを作成
  static NativeCursorGetBatch createBatch(NativeCursor cursor) =>
      cursor.batchedGet()
        ..getInt(0)
        ..getString(1)
        ..getInt(2)
        ..getString(3)
        ..getString(4);

  /// Creates a song from data retrieved from the MediaStore.
  /// mediaStoreから取ってきた曲情報からSongを作成するコンストラクタ
  factory Song.fromMediaStore(List<Object?> data) => Song(
        id: data[0] as int,
        // album: data[1] as String?,
        // albumId: data[2] as int,
        // artist: data[3] as String,
        title: data[4] as String,
      );
}
