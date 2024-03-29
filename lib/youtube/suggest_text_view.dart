import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

class SuggestSearch {
  final String query;
  final List<String> suggestQueries;
  SuggestSearch({required this.query, required this.suggestQueries});

  SuggestSearch.fromJson(List<dynamic> json)
      : query = json[0],
        suggestQueries = json[1].cast<String>() as List<String>;
}

class SuggestSearchContent extends HookConsumerWidget {
  final ValueNotifier<SuggestSearch?> suggestSearch;
  final ValueNotifier<String> searchText;
  final ValueNotifier<bool> isVisibleSuggestText;
  const SuggestSearchContent(
      {required this.suggestSearch,
      required this.searchText,
      required this.isVisibleSuggestText,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputText = useState('');
    final textController = useTextEditingController();

    final fetchSuggest = useMemoized(() async {
      if (inputText.value == '') {
        return SuggestSearch(query: '', suggestQueries: []);
      }
      final res = await http.get(Uri.parse(
          'https://www.google.com/complete/search?client=youtube&hl=us&ds=yt&q=${inputText.value}&json=true'));
      if (res.statusCode == 200) {
        try {
          return SuggestSearch.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
        } catch (e) {
          print(e);
        }
      } else {
        throw Exception('Failed to Load');
      }
      return null;
    }, [inputText.value]);

    final suggestSnapshot = useFuture(fetchSuggest);

    useEffect(() {
      textController.text = searchText.value;
      print("ff");
      return null;
    }, [searchText.value]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (suggestSnapshot.hasData) {
          suggestSearch.value = suggestSnapshot.data;
        }
      });
      return null;
    }, [suggestSnapshot.data]);

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: TextField(
            controller: textController,
            onChanged: (value) {
              inputText.value = value;
              isVisibleSuggestText.value = true;
            },
            onSubmitted: (value) {
              searchText.value = value;
              isVisibleSuggestText.value = false;
            }));
  }
}
