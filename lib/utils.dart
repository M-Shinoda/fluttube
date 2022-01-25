import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void sharingUrlProc() {
  late StreamSubscription _intentDataStreamSubscription;

  print('sharing URL proc useEffect');

  // 起動中
  _intentDataStreamSubscription =
      ReceiveSharingIntent.getTextStream().listen((String value) async {
    print("Shared: $value");
  }, onError: (err) {
    print("getLinkStream error: $err");
  });

  // 停止中
  ReceiveSharingIntent.getInitialText().then((String? value) async {
    if (value == null) return;
    print("Shared Backgraund: $value");
  });
}
