// ignore_for_file: dead_code

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path/path.dart' as path;
// ignore: import_of_legacy_library_into_null_safe
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<String> download(BuildContext context, [String? url]) async {
  var yt = YoutubeExplode();
  url ??=
      'https://www.youtube.com/watch?v=x0aoBUeCcC8&list=PLwJaZiXeTyFx4RNld3IciTHae59jlxVRS&index=55';
  var id = VideoId(url);
  var video = await yt.videos.get(id);
  // await showDialog(
  //   context: context,
  //   builder: (context) {
  //     return AlertDialog(
  //       content: Text('Title: ${video.title}, Duration: ${video.duration}'),
  //     );
  //   },
  // );
  // ignore: avoid_print
  print('###');
  await Permission.storage.request();
  // ignore: avoid_print
  print('#####');

  // Get the streams manifest and the audio track.
  var manifest = await yt.videos.streamsClient.getManifest(id);
  var audio = manifest.audioOnly.firstWhere((item) => item.tag == 140);
  // ignore: avoid_print
  print('#######');
  // Build the directory.
  var dir = await DownloadsPathProvider.downloadsDirectory;
  var dirM =
      await Directory(dir.uri.toFilePath() + 'Music/').create(recursive: true);
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
      // return AlertDialog(
      //   content: Text('Download completed and saved to: ${filePath}'),
      // );
    },
  );
}
