import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/download_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:youtube_api/youtube_api.dart';

import 'suggest_text_view.dart';

String key = 'AIzaSyAM2qP2XwtD5-9C0q7F5mtCnTuk2VCn1xA';
YoutubeAPI ytApi = YoutubeAPI(key, maxResults: 30);
List<YouTubeVideo> videoResult = [];

class YoutubeView extends HookConsumerWidget {
  const YoutubeView({Key? key}) : super(key: key);

  @override
  build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);

    final searchText = useState('');
    final suggestSearch = useState<SuggestSearch?>(null);
    final isVisibleSuggestText = useState(false);

    final searchSnapshot = useMemoized(
        () async => searchText.value != ''
            ? await ytApi.search(searchText.value)
            : null,
        [searchText.value]);
    final searchResult = useFuture(searchSnapshot);

    final _suggestList = useCallback(() {
      if (suggestSearch.value != null &&
          suggestSearch.value!.query != '' &&
          isVisibleSuggestText.value) {
        return Container(
            width: double.maxFinite,
            color: Colors.white,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...suggestSearch.value!.suggestQueries
                      .map((query) => suggestTextContent(query))
                ]));
      } else {
        return Container();
      }
    }, [suggestSearch.value, isVisibleSuggestText.value]);

    // useEffect(() {
    //   Future.delayed(Duration.zero, () async {
    //     final a = await ytApi.nextPage();
    //     inspect(a);
    //   });
    // }, [searchResult.data]);

    Widget _searchTextField() {
      return Container(
          padding: const EdgeInsets.only(top: 30),
          child: SuggestSearchContent(
              suggestSearch: suggestSearch,
              searchText: searchText,
              isVisibleSuggestText: isVisibleSuggestText));
    }

    return Column(children: [
      _searchTextField(),
      Expanded(
          child: Stack(children: [
        SingleChildScrollView(
            child: Column(children: [
          if (searchResult.hasData)
            ...searchResult.data!.map((item) => videoCard(item, dListNotifier))
        ])),
        _suggestList()
      ]))
    ]);
  }
}

Widget videoCard(YouTubeVideo item, dListNotifier) {
  return GestureDetector(
      onTap: () {
        dListNotifier.setUrl(item.url);
      },
      child: Container(
          color: Colors.black12,
          margin: const EdgeInsets.all(10),
          child: Row(children: [
            Image.network(item.thumbnail.medium.url!, width: 70),
            Expanded(child: Text(item.title, overflow: TextOverflow.ellipsis))
          ])));
}

Widget suggestTextContent(String suggest) {
  return Container(
      height: 20,
      decoration: const BoxDecoration(
          color: Colors.white60,
          borderRadius: BorderRadius.all(Radius.circular(30))),
      child: Text(suggest));
}
