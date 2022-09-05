import 'package:flutter/material.dart';
import 'package:fluttube/download_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ListCard extends HookConsumerWidget {
  final List<UrlState> items;
  const ListCard({Key? key, required this.items}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var dList = ref.watch(downloadListProvider);

    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];

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
              value:
                  dList[index].progress == 0.0 ? null : dList[index].progress,
            ),
          ),
        );
      },
    );
  }
}
