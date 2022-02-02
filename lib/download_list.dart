import 'package:flutter_riverpod/flutter_riverpod.dart';

class UrlStateList {
  String url;
  String completed;
  UrlStateList(this.url, this.completed);
}

final downloadListProvider =
    StateNotifierProvider<DownloadListStateNotifier, List<UrlStateList>>((_) {
  return DownloadListStateNotifier();
});

List<UrlStateList> list = [];

class DownloadListStateNotifier extends StateNotifier<List<UrlStateList>> {
  DownloadListStateNotifier() : super(<UrlStateList>[]);
  void setUrl(String url) {
    list.add(UrlStateList(url, 'false'));
    state = list.toList();
  }
}
