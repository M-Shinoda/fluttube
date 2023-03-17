import 'package:audio_service/audio_service.dart';
import 'package:fluttube/models/content_manager.dart';
import 'package:fluttube/utils/file_manage.dart';

abstract class PlaylistRepository {
  Future<List<MediaItem>> fetchInitialPlaylist();
  Future<MediaItem> fetchAnotherSong();
  Future<List<MediaItem>> fetchAnotherPlaylist(String playlistId);
}

class DemoPlaylist extends PlaylistRepository {
  @override
  Future<List<MediaItem>> fetchInitialPlaylist({int length = 1}) async {
    length = await ContentManager().getSongCount();
    List<MediaItem> songs = [];
    for (int i = 0; i < length; i++) {
      songs.add(await _nextSong());
    }

    return songs;
  }

  @override
  Future<MediaItem> fetchAnotherSong() async {
    return await _nextSong();
  }

  var _songIndex = 0;

  Future<MediaItem> _nextSong() async {
    final songs = await ContentManager().fetchSongs();
    final song = songs![_songIndex];
    _songIndex += 1;
    return song.toMediaItem();
  }

  @override
  Future<List<MediaItem>> fetchAnotherPlaylist(String playlistId) async {
    final playlistItem = await FileManager().readPlaylist(playlistId);
    List<MediaItem> items = [];
    playlistItem.asMap().forEach((index, item) {
      items.add(MediaItem(
          id: index.toString().padLeft(3, '0'),
          album: 'SoundHelix',
          title: item.title,
          extras: {'url': FileManager().dirMJoin(item.title)},
          artUri:
              Uri.parse('https://i.ytimg.com/vi/e1xCOsgWG0M/mqdefault.jpg')));
    });
    return items;
  }
}
