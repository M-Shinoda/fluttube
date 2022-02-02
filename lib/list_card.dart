import 'package:flutter/material.dart';
import 'package:fluttube/download_list.dart';

class ListCard extends StatefulWidget {
  const ListCard({Key? key, required this.items}) : super(key: key);
  final List<UrlState> items;

  @override
  State<ListCard> createState() => _ListCard();
}

class _ListCard extends State<ListCard> {
  List<Map<String, dynamic>> dones = [];
  @override
  void initState() {
    super.initState();
    print('initState ########');
  }

  @override
  void didUpdateWidget(covariant ListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget');
  }

  @override
  Widget build(BuildContext context) {
    print("########" + widget.items.toString());
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: widget.items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items[index];

        return Card(
          child: ListTile(
            leading: const Icon(Icons.people),
            title: Text(
              item.url.toString() + " : " + item.completed.toString(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
