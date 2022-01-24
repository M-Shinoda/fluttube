import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:fluttube/list_card.dart';
import 'package:fluttube/share_receive_url.dart';
import 'downloader.dart';
// import 'share_receive_url.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Fluttube'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> items = [];

  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () => download(context),
            icon: const Icon(CupertinoIcons.cloud_download),
          )
        ],
      ),
      body: Container(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // リストビュー
            Expanded(child: ListCard(items: items)),
            FloatingActionButton(
              // onPressedでボタンが押されたらテキストフィールドの内容を取得して、アイテムに追加
              onPressed: () async {
                final title = await download(context);
                _addItem(title);
              },
              child: const Icon(Icons.add),
            ),
            ShareReceiveUrl()
          ],
        ),
      ),
    );
  }

  void _addItem(String title) {
    setState(() {
      _counter++;
      items.add({"id": _counter, "title": title});
    });
  }
}
