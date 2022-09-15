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
import 'page_manager.dart';
import 'services/service_locator.dart';
import 'utils.dart';

void main() async {
  await setupServiceLocator();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

late Directory dir;
late Directory dirM;
late File cacheFile;

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);

    useEffect(() {
      getIt<PageManager>().init();
      Future.delayed(Duration.zero, () async {
        await Permission.storage.request();
        dir = await DownloadsPathProvider.downloadsDirectory;
        dirM = Directory(dir.uri.toFilePath() + 'Music');
        cacheFile = await File(
                Directory(dir.uri.toFilePath() + 'Cache').path + '/cache.txt')
            .create(recursive: true);
        sharingUrlProc(dListNotifier);
      });
      return () {
        getIt<PageManager>().dispose();
      };
    }, []);

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomView(),
    );
  }
}
