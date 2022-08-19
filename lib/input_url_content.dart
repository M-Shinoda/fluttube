import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'download_list.dart';
import 'url.dart';

class InputUrlContent extends HookConsumerWidget {
  const InputUrlContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlNotifier = ref.read(textFieldUrlProvider.notifier);
    final url = ref.watch(textFieldUrlProvider);
    final dListNotifier = ref.read(downloadListProvider.notifier);
    final dList = ref.watch(downloadListProvider);
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            onChanged: (value) {
              urlNotifier.update(value);
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            dListNotifier.setUrl(url);
            // ignore: avoid_print
            print(dList.displayList.length);
          },
          child: const Text('Download'),
        ),
      ],
    );
  }
}
