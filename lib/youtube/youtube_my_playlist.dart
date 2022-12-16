import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/youtube/youtube_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../states/download_list.dart';

class Playlist {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;

  Playlist(this.id, this.title, this.description, this.thumbnailUrl);

  Playlist.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        title = json['snippet']['localized']['title'] ?? '',
        description = json['snippet']['localized']['description'] ?? '',
        thumbnailUrl = json['snippet']['thumbnails']['maxres']['url'] ?? '';
}

class PlaylistItem {
  final String id;
  final String title;

  PlaylistItem(this.id, this.title);

  PlaylistItem.fromJson(Map<String, dynamic> json)
      : id = json['contentDetails']['videoId'] ?? '',
        title = json['title'] ?? '';
}

class YoutubeMyPlaylist extends HookConsumerWidget {
  const YoutubeMyPlaylist({Key? key}) : super(key: key);

  @override
  build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);
    final playlists = useState<List<Playlist>>([]);
    final playlistItems = useState<List<PlaylistItem>>([]);
    useEffect(() {
      Future.delayed(Duration.zero, () async {
        final res = await http.get(Uri.parse(
            'https://www.googleapis.com/youtube/v3/playlists?channelId=UCOJraEHfsaUal04U63Zewng&key=AIzaSyCnIYbi-SOIJfaX4bm2JFJtC21dpCu_10Q&part=snippet,id,status&maxResults=100'));

        if (res.statusCode == 200) {
          try {
            final json = jsonDecode(utf8.decode(res.bodyBytes));
            print(json['items']);

            playlists.value = (json['items'] as List<dynamic>)
                .map((playlist) => Playlist.fromJson(playlist))
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

    final onTapCard = useCallback((Playlist playlist) async {
      final res = await http.get(Uri.parse(
          'https://www.googleapis.com/youtube/v3/playlistItems?key=AIzaSyCnIYbi-SOIJfaX4bm2JFJtC21dpCu_10Q&part=snippet,contentDetails,status,id&playlistId=${playlist.id}'));

      final json = jsonDecode(utf8.decode(res.bodyBytes));
      print(json['items']);

      playlistItems.value = (json['items'] as List<dynamic>)
          .map((item) => PlaylistItem.fromJson(item))
          .toList();
      inspect(playlistItems.value);
      for (var item in playlistItems.value) {
        dListNotifier.setId(item.id);
      }
    }, const []);

    return SafeArea(
        child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
                children: playlists.value
                    .map((playlist) => InkWell(
                        onTap: () => onTapCard(playlist),
                        child: Card(
                            child: Container(
                                height: 50,
                                width: double.maxFinite,
                                alignment: Alignment.centerLeft,
                                child: Text(playlist.title)))))
                    .toList())));
  }
}
