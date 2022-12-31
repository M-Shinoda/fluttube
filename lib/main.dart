import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/utils/file_manage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:yt/yt.dart';

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

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);

    useEffect(() {
      Future.delayed(Duration.zero, () async {
        await FileManager().init(
            musicFolderName: 'Music',
            playlistSaveFolderName: 'Playlist',
            cacheFolderName: 'Cache');

        sharingUrlProc(dListNotifier);
        getIt<PageManager>().init();
        final yt = await Yt.withOAuth(
            oAuthClientId:
                OAuthCredentials.fromYaml('credentials.yaml').oAuthClientId);
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
