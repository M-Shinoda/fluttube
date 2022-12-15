import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'downloader.dart';

class ShareReceiveUrl extends StatefulWidget {
  const ShareReceiveUrl({Key? key}) : super(key: key);

  @override
  State<ShareReceiveUrl> createState() => _ShareReceiveUrl();
}

class _ShareReceiveUrl extends State<ShareReceiveUrl> {
  String? _sharedText;
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 0, height: 0);
  }

  @override
  void initState() {
    super.initState();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) async {
      if (value == null) return;
      setState(() {
        _sharedText = value;
        // ignore: avoid_print
        print("Shared: $_sharedText");
      });
      // ignore: avoid_print
      print('########');

      await download(context, _sharedText);
    });
  }
}
