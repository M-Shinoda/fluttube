import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/youtube_model.dart';

const myChannelId = 'UCOJraEHfsaUal04U63Zewng';
const baseUrl = 'https://www.googleapis.com/youtube/v3/';
const key = 'AIzaSyCnIYbi-SOIJfaX4bm2JFJtC21dpCu_10Q';

Future<List<MyPlaylist>?> getMyChannelPlaylistOnlyPublic() async {
  try {
    final res = await http.get(Uri.parse(
        '${baseUrl}playlists?channelId=$myChannelId&key=$key&part=snippet,id,status&maxResults=100'));
    if (res.statusCode == 200) {
      final json = jsonDecode(utf8.decode(res.bodyBytes));
      return (json['items'] as List<dynamic>)
          .map((playlist) => MyPlaylist.fromJson(playlist))
          .toList();
    }
  } catch (e) {
    print(e);
  }
  return null;
}
