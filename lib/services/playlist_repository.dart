import 'package:audio_service/audio_service.dart';
import 'package:fluttube/utils/file_manage.dart';
import 'package:path/path.dart';

abstract class PlaylistRepository {
  Future<List<Map<String, String>>> fetchInitialPlaylist();
  Future<Map<String, String>> fetchAnotherSong();
  Future<List<MediaItem>> fetchAnotherPlaylist(String playlistId);
}

class DemoPlaylist extends PlaylistRepository {
  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist(
      {int length = 1}) async {
    length = FileManager().getDirMFileList().length;

    return List.generate(length, (index) => _nextSong());
  }

  @override
  Future<Map<String, String>> fetchAnotherSong() async {
    return _nextSong();
  }

  var _songIndex = 0;
  var list = FileManager().getDirMFileList();

  Map<String, String> _nextSong() {
    print(list.toString());
    final path = list[_songIndex].path;
    final title = basename(path);
    _songIndex = (_songIndex % list.length) + 1;
    return {
      'id': _songIndex.toString().padLeft(3, '0'),
      'title': title,
      'album': 'SoundHelix',
      'url': path,
      'thumbnailUrl': 'https://i.ytimg.com/vi/e1xCOsgWG0M/mqdefault.jpg'
    };
  }

  @override
  Future<List<MediaItem>> fetchAnotherPlaylist(String playlistId) async {
    // final list = dirM.listSync();
    final playlistItem = await FileManager().readPlaylist(playlistId);
    List<MediaItem> items = [];
    playlistItem.asMap().forEach((index, item) {
      // final playlistFile =
      //     list.firstWhere((file) => basename(file.path) == item.title + '.mp3');
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
