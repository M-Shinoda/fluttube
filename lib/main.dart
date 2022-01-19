import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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
  late StreamSubscription _intentDataStreamSubscription;
  String? _sharedText;
  final myController = TextEditingController();

  List<Map<String, dynamic>> items = [];

  int _counter = 0;

  void _addItem(String title) {
    setState(() {
      _counter++;
      items.add({"id": _counter, "title": title});
    });
  }

  @override
  void initState() {
    super.initState();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) async {
      setState(() {
        _sharedText = value;
        print("Shared: $_sharedText");
      });
      await download(_sharedText);
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) async {
      if (value == null) return;
      setState(() {
        _sharedText = value;
        print("Shared: $_sharedText");
      });
      await download(_sharedText);
    });
  }

  // widgetの破棄時にコントローラも破棄する
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () => download(),
            icon: const Icon(CupertinoIcons.cloud_download),
          )
        ],
      ),
      body: Container(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // リストビュー
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index];

                  return new Card(
                    child: ListTile(
                      leading: Icon(Icons.people),
                      title: Text(
                        item["id"].toString() + " : " + item["title"],
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
            FloatingActionButton(
              // onPressedでボタンが押されたらテキストフィールドの内容を取得して、アイテムに追加
              onPressed: () async {
                final title = await download();
                _addItem(title);
                // テキストフィールドの内容をクリア
                myController.clear();
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> download([String? url]) async {
    var yt = YoutubeExplode();
    if (url == null) {
      url =
          'https://www.youtube.com/watch?v=x0aoBUeCcC8&list=PLwJaZiXeTyFx4RNld3IciTHae59jlxVRS&index=55';
    }
    var id = VideoId(url);
    var video = await yt.videos.get(id);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Title: ${video.title}, Duration: ${video.duration}'),
        );
      },
    );
    await Permission.storage.request();

    // Get the streams manifest and the audio track.
    var manifest = await yt.videos.streamsClient.getManifest(id);
    var audio = manifest.audioOnly.firstWhere((item) => item.tag == 140);

    // Build the directory.
    var dir = await DownloadsPathProvider.downloadsDirectory;
    var dirM = await Directory(dir.uri.toFilePath() + 'Music/')
        .create(recursive: true);
    // Compose the file name removing the unallowed characters in windows.
    var fileName = '${video.title}.mp3'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');
    return fileName;
    var filePath =
        // path.join(dirM.path, '${video.id}.${audio.container.name}');
        path.join(dirM.path, fileName);

    // Open the file to write.
    var file = File(filePath);
    var fileStream = file.openWrite();

    // Pipe all the content of the stream into our file.
    await yt.videos.streamsClient.get(audio).pipe(fileStream);
    /*
                  If you want to show a % of download, you should listen
                  to the stream instead of using `pipe` and compare
                  the current downloaded streams to the totalBytes,
                  see an example ii example/video_download.dart
                   */

    // Close the file.
    await fileStream.flush();
    await fileStream.close();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Download completed and saved to: ${filePath}'),
        );
      },
    );
  }
}
