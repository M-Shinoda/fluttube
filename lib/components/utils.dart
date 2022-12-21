import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../states/download_list.dart';

void sharingUrlProc(DownloadListStateNotifier notifier) {
  // ignore: unused_local_variable
  late StreamSubscription _intentDataStreamSubscription;

  // ignore: avoid_print
  print('sharing URL proc useEffect');

  // 起動中
  _intentDataStreamSubscription =
      ReceiveSharingIntent.getTextStream().listen((String value) async {
    // ignore: avoid_print
    print("Shared: $value");
    notifier.setUrl(value);
  }, onError: (err) {
    // ignore: avoid_print
    print("getLinkStream error: $err");
  });

  // 停止中
  ReceiveSharingIntent.getInitialText().then((String? value) async {
    if (value == null) return;
    notifier.setUrl(value);
    // ignore: avoid_print
    print("Shared Backgraund: $value");
  });
}
