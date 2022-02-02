import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/count.dart';
import 'package:fluttube/download_list.dart';
import 'package:fluttube/list_card.dart';
import 'package:fluttube/url.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';

class HomeBodyView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countNotifier = ref.read(countProvider.notifier);
    final count = ref.watch(countProvider);
    final urlNotifier = ref.read(textFieldUrlProvider.notifier);
    final url = ref.watch(textFieldUrlProvider);
    final dListNotifier = ref.read(downloadListProvider.notifier);
    final dList = ref.watch(downloadListProvider);

    bool condition = false;

    return Container(
      child: Column(
        children: <Widget>[
          // Text('$count'),
          // Text('$url'),
          // Text('$dList'),
          Text(dList.displayList.isNotEmpty
              ? dList.displayList.last.url
              : 'No data'),
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
                    condition = true;
                    dListNotifier.setDisplayList(true);
                  },
                  child: Text("ダウンロード済"),
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
                      condition = false;
                      dListNotifier.setDisplayList(false);
                    },
                    child: Text("ダウンロード中"),
                    style: TextButton.styleFrom(
                        backgroundColor:
                            dList.condition ? null : Colors.orange[100])),
              ),
            ],
          ),
          Expanded(
            child: ListCard(items: dList.displayList),
          ),
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
