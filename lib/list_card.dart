import 'package:flutter/material.dart';
import 'package:fluttube/download_list.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ListCard extends HookConsumerWidget {
  final List<UrlState> items;
  ListCard({Key? key, required this.items}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);
    var dList = ref.watch(downloadListProvider);
    double d = 0.0;

    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: this.items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = this.items[index];

        return Card(
          child: ListTile(
            leading: const Icon(Icons.people),
            title: Text(
              item.url.toString() + " : " + item.completed.toString(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: CircularProgressIndicator(
              value: dList.displayList[index].progress == 0.0
                  ? null
                  : dList.displayList[index].progress,
            ),
          ),
        );
      },
    );
  }
}
