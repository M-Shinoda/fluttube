import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import '../states/download_list.dart';
import '../utils/file_manage.dart';

enum ThumbnailsRes {
  def,
  medium,
  high,
  standard,
  maxres,
}

final Map<ThumbnailsRes, String> thumbnailsResName = {
  ThumbnailsRes.def: 'default',
  ThumbnailsRes.medium: 'medium',
  ThumbnailsRes.high: 'high',
  ThumbnailsRes.maxres: 'maxres',
};

class MyPlaylist {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;

  MyPlaylist(this.id, this.title, this.description, this.thumbnailUrl);

  MyPlaylist.fromJson(Map<String, dynamic> json)
      : this(
            json['id'] ?? '',
            json['snippet']['localized']['title'] ?? '',
            json['snippet']['localized']['description'] ?? '',
            _choseThumbnailsRes(json, ThumbnailsRes.maxres));
}

_choseThumbnailsRes(Map<String, dynamic> json, ThumbnailsRes res) {
  final choseRes = json['snippet']['thumbnails'][thumbnailsResName[res]];
  if (choseRes == null) {
    return _choseThumbnailsRes(json, ThumbnailsRes.values[res.index - 1]);
  }
  return choseRes['url'];
}

class PlaylistItem {
  final String id;
  final String title;

  PlaylistItem(this.id, this.title);

  PlaylistItem.fromJson(Map<String, dynamic> json)
      : id = json['contentDetails']['videoId'] ?? '',
        title =
            FileManager().composeFileNameAndExt(json['snippet']['title'] ?? '');

  PlaylistItem.fromStrageJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        title = json['title'] ?? '';

  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}

class YoutubeMyPlaylist extends HookConsumerWidget {
  const YoutubeMyPlaylist({Key? key}) : super(key: key);

  @override
  build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);
    final playlists = useState<List<MyPlaylist>>([]);
    final playlistItems = useState<List<PlaylistItem>>([]);
    useEffect(() {
      Future.delayed(Duration.zero, () async {
        final res = await http.get(Uri.parse(
            'https://www.googleapis.com/youtube/v3/playlists?channelId=UCOJraEHfsaUal04U63Zewng&key=AIzaSyCnIYbi-SOIJfaX4bm2JFJtC21dpCu_10Q&part=snippet,id,status&maxResults=100'));

        if (res.statusCode == 200) {
          try {
            final json = jsonDecode(utf8.decode(res.bodyBytes));
            inspect(json['items']);

            playlists.value = (json['items'] as List<dynamic>)
                .map((playlist) => MyPlaylist.fromJson(playlist))
                .toList();

            inspect(playlists.value);
          } catch (e) {
            print(e);
          }
        } else {
          throw Exception('Failed to Load');
        }
      });
      return null;
    }, []);

    final onTapCard = useCallback(
        (MyPlaylist playlist,
                ValueNotifier<List<PlaylistItem>> playlistItems) async =>
            dListNotifier.setPlaylist(playlist, playlistItems),
        const []);

    return SafeArea(
        child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
                children: playlists.value
                    .map((playlist) => InkWell(
                        onTap: () => onTapCard(playlist, playlistItems),
                        child: Card(
                            child: Container(
                                height: 50,
                                width: double.maxFinite,
                                alignment: Alignment.centerLeft,
                                child: Text(playlist.title)))))
                    .toList())));
  }
}
