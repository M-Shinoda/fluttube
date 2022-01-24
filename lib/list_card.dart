import 'package:flutter/material.dart';

class ListCard extends StatefulWidget {
  const ListCard({Key? key, required this.items}) : super(key: key);
  final List<Map<String, dynamic>> items;

  @override
  State<ListCard> createState() => _ListCard();
}

class _ListCard extends State<ListCard> {
  @override
  Widget build(BuildContext context) {
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
              item["id"].toString() + " : " + item["title"],
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
