import 'package:fluttube/main.dart';
import 'package:path/path.dart';

abstract class PlaylistRepository {
  Future<List<Map<String, String>>> fetchInitialPlaylist();
  Future<Map<String, String>> fetchAnotherSong();
}

class DemoPlaylist extends PlaylistRepository {
  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist(
      {int length = 1}) async {
    return List.generate(length, (index) => _nextSong());
  }

  @override
  Future<Map<String, String>> fetchAnotherSong() async {
    return _nextSong();
  }

  var _songIndex = 0;
  var list = dirM.listSync();

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
    };
  }
}
