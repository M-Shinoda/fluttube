import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import 'download_list.dart';

class SuggestSearch {
  final String query;
  final List<String> suggestQueries;
  SuggestSearch({required this.query, required this.suggestQueries});

  SuggestSearch.fromJson(List<dynamic> json)
      : query = json[0],
        suggestQueries = json[1].cast<String>() as List<String>;
}

Future<SuggestSearch?> fetch(String query) async {
  if (query == '') return null;
  final res = await http.get(Uri.parse(
      'https://www.google.com/complete/search?client=youtube&hl=us&ds=yt&q=$query&json=true'));
  if (res.statusCode == 200) {
    try {
      return SuggestSearch.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    } catch (e) {
      print(e);
    }
  } else {
    throw Exception('Failed to Load');
  }
}

class InputUrlContent extends HookConsumerWidget {
  final ValueNotifier<SuggestSearch?> suggestSearch;
  const InputUrlContent({required this.suggestSearch, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final urlNotifier = ref.read(textFieldUrlProvider.notifier);
    // final url = ref.watch(textFieldUrlProvider);
    final url = useState('');
    final dListNotifier = ref.read(downloadListProvider.notifier);
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            onChanged: (value) async {
              // urlNotifier.update(value);
              url.value = value;
              suggestSearch.value = await fetch(value);
            },
          ),
        ),
        // ElevatedButton(
        //   onPressed: () async {
        //     // dListNotifier.setUrl(url.value);
        //     // print();
        //   },
        //   child: const Text('Download'),
        // ),
      ],
    );
  }
}
