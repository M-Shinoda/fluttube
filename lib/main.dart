import 'dart:async';
// import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
// import 'package:fluttube/list_card.dart';
// import 'package:fluttube/share_receive_url.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// import 'downloader.dart';
// import 'share_receive_url.dart';]
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    useEffect(() {
      late StreamSubscription _intentDataStreamSubscription;
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
    });
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: demoPage(),
    );
  }

  Widget demoPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluttube'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              print('touch download icon');
            },
            icon: const Icon(CupertinoIcons.cloud_download),
          )
        ],
      ),
      body: Container(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // リストビュー
            Expanded(child: Container()),
            FloatingActionButton(
              // onPressedでボタンが押されたらテキストフィールドの内容を取得して、アイテムに追加
              onPressed: () {
                print('touch floating button');
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
