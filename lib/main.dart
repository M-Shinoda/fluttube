import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttube/bottom_view.dart';
import 'package:fluttube/download_list.dart';
import 'package:fluttube/home.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'utils.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);

    useEffect(() {
      sharingUrlProc(dListNotifier);
    }, []);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomView(),
    );
  }
}
