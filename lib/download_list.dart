import 'package:flutter_riverpod/flutter_riverpod.dart';

class UrlState {
  String url;
  bool completed;
  UrlState(this.url, this.completed);
}

final downloadListProvider =
    StateNotifierProvider<DownloadListStateNotifier, List<UrlState>>((_) {
  return DownloadListStateNotifier();
});

List<UrlState> list = [];

class DownloadListStateNotifier extends StateNotifier<List<UrlState>> {
  DownloadListStateNotifier() : super(<UrlState>[]);
  void setUrl(String url) {
    list.add(UrlState(url, false));
    getConditionList(false);
  }

  void getConditionList(bool completed) {
    List<UrlState> conditionList = [];
    list.forEach((state) {
      if (state.completed == completed) {
        conditionList.add(state);
      }
    });
    state = conditionList.toList();
  }
}
