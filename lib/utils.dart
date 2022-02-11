import 'dart:async';
import 'package:fluttube/download_list.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void sharingUrlProc(DownloadListStateNotifier notifier) {
  late StreamSubscription _intentDataStreamSubscription;

  print('sharing URL proc useEffect');

  // 起動中
  _intentDataStreamSubscription =
      ReceiveSharingIntent.getTextStream().listen((String value) async {
    print("Shared: $value");
    notifier.setUrl(value);
  }, onError: (err) {
    print("getLinkStream error: $err");
  });

  // 停止中
  ReceiveSharingIntent.getInitialText().then((String? value) async {
    if (value == null) return;
    notifier.setUrl(value);
    print("Shared Backgraund: $value");
  });
}
