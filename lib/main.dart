import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttube/bottom_view.dart';
import 'package:fluttube/download_list.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:permission_handler/permission_handler.dart';
import 'utils.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

late Directory dir;
late Directory dirM;
late Directory dirC;

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);

    useEffect(() {
      Future.delayed(Duration.zero, () async {
        await Permission.storage.request();
        dir = await DownloadsPathProvider.downloadsDirectory;
        dirM = Directory(dir.uri.toFilePath() + 'Music');
        dirC = Directory(dir.uri.toFilePath() + 'Cache');
        sharingUrlProc(dListNotifier);
      });
      return;
    }, []);

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomView(),
    );
  }
}
