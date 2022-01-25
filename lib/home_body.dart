import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/count.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeBodyView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countNotifier = ref.read(countProvider.notifier);
    final count = ref.watch(countProvider);

    return Container(
      child: Column(
        children: <Widget>[
          Text('$count'),
          // リストビュー
          Expanded(child: Container()),
          FloatingActionButton(
            onPressed: () {
              print('touch floating button');
              countNotifier.update();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
