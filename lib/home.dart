import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/count.dart';
import 'package:fluttube/home_body.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'home_body.dart';

class HomeView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(countProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluttube '),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              print('$count');
            },
            icon: const Icon(CupertinoIcons.cloud_download),
          )
        ],
      ),
      body: HomeBodyView(),
    );
  }
}
