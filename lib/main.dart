import 'package:flutter/material.dart';
import 'package:fluttube/bottom_view.dart';
import 'package:fluttube/download_list.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'utils.dart';

void main() {
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
      sharingUrlProc(dListNotifier);
      return;
    }, []);

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomView(),
    );
  }
}
