import 'package:flutter_riverpod/flutter_riverpod.dart';

class UrlState {
  String url;
  bool completed;
  UrlState(this.url, this.completed);
}

class UrlStates {
  // List<UrlState> incompList;
  // List<UrlState> compList;
  List<UrlState> displayList;
  bool condition;
  // UrlStates(this.incompList, this.compList, this.displayList);
  UrlStates(this.displayList, this.condition);
}

final downloadListProvider =
    StateNotifierProvider<DownloadListStateNotifier, UrlStates>((_) {
  return DownloadListStateNotifier();
});

List<UrlState> incompList = [];
List<UrlState> compList = [];
bool condition = false;

class DownloadListStateNotifier extends StateNotifier<UrlStates> {
  DownloadListStateNotifier() : super(UrlStates(incompList, condition));
  void setUrl(String url) {
    incompList.add(UrlState(url, false));
    state = UrlStates(incompList, condition);
  }

  void setDisplayList(bool nextCondition) {
    condition = nextCondition;
    if (condition) {
      state = UrlStates(compList, condition);
    } else {
      state = UrlStates(incompList, condition);
    }
  }
}
