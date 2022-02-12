import 'package:flutter/material.dart';
import 'package:fluttube/count.dart';
import 'package:fluttube/download_list.dart';
import 'package:fluttube/list_card.dart';
import 'package:fluttube/url.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeBodyView extends HookConsumerWidget {
  const HomeBodyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countNotifier = ref.read(countProvider.notifier);
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // crossAxisAlignment: CrossAxisAlignment,
          children: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: () {
                  // conditionList =
                  //     dListNotifier.getConditionList(true).toList();]
                  dListNotifier.setDisplayList(true);
                },
                child: const Text("ダウンロード済"),
                style: TextButton.styleFrom(
                    backgroundColor:
                        dList.condition ? Colors.orange[100] : null),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  // conditionList =
                  //     dListNotifier.getConditionList(false).toList();
                  dListNotifier.setDisplayList(false);
                },
                child: const Text("ダウンロード中"),
                style: TextButton.styleFrom(
                    backgroundColor:
                        dList.condition ? null : Colors.orange[100]),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListCard(items: dList.displayList),
        ),
        FloatingActionButton(
          onPressed: () {
            // ignore: avoid_print
            print('touch floating button');
            countNotifier.update();
          },
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
