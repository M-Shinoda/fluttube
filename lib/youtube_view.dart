import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/download_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:youtube_api/youtube_api.dart';

import 'input_url_content.dart';

String key = 'AIzaSyAM2qP2XwtD5-9C0q7F5mtCnTuk2VCn1xA';
YoutubeAPI ytApi = YoutubeAPI(key, maxResults: 30);
List<YouTubeVideo> videoResult = [];

class YoutubeView extends HookConsumerWidget {
  const YoutubeView({Key? key}) : super(key: key);

  @override
  build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);

    final searchSnapshot = useMemoized(() async => await ytApi.search('初音ミク'));
    final searchResult = useFuture(searchSnapshot);
    final suggestSearch = useState<SuggestSearch?>(null);

    // useEffect(() {
    //   Future.delayed(Duration.zero, () async {
    //     final a = await ytApi.nextPage();
    //     inspect(a);
    //   });
    // }, [searchResult.data]);

    return Column(
      children: [
        searchTextField(suggestSearch),
        Expanded(
          // height: 200,
          // width: double.infinity,
          child: SingleChildScrollView(
              child: Column(children: [
            if (suggestSearch.value != null)
              ...suggestSearch.value!.suggestQueries
                  .map((query) => Text(query)),
            if (searchResult.hasData)
              ...searchResult.data!
                  .map((item) => videoCard(item, dListNotifier))
          ])),
        )
      ],
    );
  }
}

Widget searchTextField(ValueNotifier<SuggestSearch?> suggestSearch) {
  return Container(
    padding: const EdgeInsets.only(top: 30),
    child: InputUrlContent(
      suggestSearch: suggestSearch,
    ),
  );
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
