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
