class DownloadCache {
  int id;
  String url;
  String name;
  DateTime date;
  String thumbnailUrl;
  DownloadCache(this.id, this.url, this.name, this.date, this.thumbnailUrl);

  DownloadCache.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        url = json['url'],
        name = json['name'] as String,
        date = DateTime.parse(json['date']),
        thumbnailUrl = json['thumbnailUrl'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'url': url, 'name': name, 'date': date.toIso8601String()};
}
