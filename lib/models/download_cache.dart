class DownloadCache {
  String id;
  String name;
  DateTime date;
  String thumbnailUrl;
  DownloadCache(this.id, this.name, this.date, this.thumbnailUrl);

  DownloadCache.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] as String,
        date = DateTime.parse(json['date']),
        thumbnailUrl = json['thumbnailUrl'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'date': date.toIso8601String()};
}
