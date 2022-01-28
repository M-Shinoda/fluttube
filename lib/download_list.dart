import 'dart:ffi';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class UrlListState {
  String url;
  String completed;
  UrlListState(this.url, this.completed);
}

final downloadListProvider =
    StateNotifierProvider<DownloadListStateNotifier, List<UrlListState>>((_) {
  return DownloadListStateNotifier();
});

List<UrlListState> list = [];

class DownloadListStateNotifier extends StateNotifier<List<UrlListState>> {
  DownloadListStateNotifier() : super(<UrlListState>[]);
  void setUrl(String url) {
    list.add(UrlListState(url, 'false'));
    state = list;
  }
}
