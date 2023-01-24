import 'package:yt/src/model/search/id.dart';
import 'package:yt/yt.dart';

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

class MyPlaylistItem {
  final String id;
  final String title;

  MyPlaylistItem(this.id, this.title);

  MyPlaylistItem.fromJson(Map<String, dynamic> json)
      : id = json['contentDetails']['videoId'] ?? '',
        title =
            FileManager().composeFileNameAndExt(json['snippet']['title'] ?? '');

  MyPlaylistItem.fromStrageJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        title = json['title'] ?? '';

  MyPlaylistItem.fromPlaylistItem(PlaylistItem item)
      : id = item.snippet!.resourceId.videoId,
        title = item.snippet!.title;

  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}

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

  MyPlaylist.fromPlaylist(Playlist p)
      : this(p.id, p.snippet!.title, p.snippet!.description,
            p.snippet!.thumbnails.thumbnailsDefault.url);
}

_choseThumbnailsRes(Map<String, dynamic> json, ThumbnailsRes res) {
  final choseRes = json['snippet']['thumbnails'][thumbnailsResName[res]];
  if (choseRes == null) {
    return _choseThumbnailsRes(json, ThumbnailsRes.values[res.index - 1]);
  }
  return choseRes['url'];
}

enum ItemKind { video, playlist, channel, none }

final Map<String, ItemKind> itemKindMap = {
  'youtube#video': ItemKind.video,
  'youtube#playlist': ItemKind.playlist,
  'youtube#channel': ItemKind.channel,
  '': ItemKind.none,
};

class ExtendsSearchResult extends SearchResult {
  ItemKind _itemKind = ItemKind.none;

  ExtendsSearchResult(SearchResult item)
      : super(
            kind: item.kind,
            etag: item.etag,
            id: item.id,
            snippet: item.snippet) {
    _itemKind = itemKindMap[id.kind] ?? ItemKind.none;
  }

  ItemKind get itemKind => _itemKind;
}
