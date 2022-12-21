import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:permission_handler/permission_handler.dart';

import 'audio/page_manager.dart';
import 'components/utils.dart';
import 'navigation_bottom_bar/bottom_view.dart';
import 'services/service_locator.dart';
import 'states/download_list.dart';

void main() async {
  await setupServiceLocator();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000), // status bar color
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

late Directory dir;
late Directory dirM;
late File cacheFile;
late Directory dirP;

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);

    useEffect(() {
      Future.delayed(Duration.zero, () async {
        await Permission.storage.request();
        dir = await DownloadsPathProvider.downloadsDirectory;
        dirM = await Directory(dir.uri.toFilePath() + 'Music')
            .create(recursive: true);
        dirP = await Directory(dir.uri.toFilePath() + 'Playlist')
            .create(recursive: true);
        cacheFile = await File(
                Directory(dir.uri.toFilePath() + 'Cache').path + '/cache.txt')
            .create(recursive: true);
        sharingUrlProc(dListNotifier);
        getIt<PageManager>().init();
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
