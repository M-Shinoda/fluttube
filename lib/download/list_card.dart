import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../states/download_list.dart';

class ListCard extends HookWidget {
  final List<UrlState> items;
  const ListCard({Key? key, required this.items}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
                  items[index].progress == 0.0 ? null : items[index].progress,
            ),
          ),
        );
      },
    );
  }
}

class ListCacheCard extends HookWidget {
  final List<DownloadCache> caches;
  const ListCacheCard({Key? key, required this.caches}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: caches.length,
        itemBuilder: (BuildContext context, int index) {
          final item = caches[index];

          return Card(
              child: ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(item.name.toString(),
                      style:
                          const TextStyle(overflow: TextOverflow.ellipsis))));
        });
  }
}
