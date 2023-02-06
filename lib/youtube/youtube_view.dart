import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:yt/yt.dart';

import '../models/youtube_model.dart';
import '../states/download_list.dart';
import '../utils/youtube_api.dart';
import 'suggest_text_view.dart';

String key = 'AIzaSyAM2qP2XwtD5-9C0q7F5mtCnTuk2VCn1xA';

class YoutubeView extends HookConsumerWidget {
  const YoutubeView({Key? key}) : super(key: key);

  @override
  build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);

    final searchText = useState('');
    final suggestSearch = useState<SuggestSearch?>(null);
    final isVisibleSuggestText = useState(false);
    final searchVideo = useState(false);
    final searchPlaylist = useState(true);
    final searchChannel = useState(false);

    final searchType = useMemoized(() {
      List<String> type = [];
      if (searchVideo.value) type.add('video');
      if (searchChannel.value) type.add('channel');
      if (searchPlaylist.value) type.add('playlist');

      if (type.isEmpty) type.add('video');
      return type.join(',');
    }, [searchChannel.value, searchPlaylist.value, searchVideo.value]);

    final searchSnapshot = useMemoized(
        () async => searchText.value != ''
            ? await ytApi.search
                .list(q: searchText.value, type: searchType, maxResults: 10)
            : null,
        [searchText.value, searchType]);
    final searchResult = useFuture(searchSnapshot);

    Widget _suggestTextContent(String suggest) {
      return GestureDetector(
          onTap: () {
            searchText.value = suggest;
            FocusScope.of(context).unfocus();
            isVisibleSuggestText.value = false;
          },
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 20,
              width: double.maxFinite,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Text(suggest)));
    }

    final _suggestList = useCallback(() {
      if (suggestSearch.value != null &&
          suggestSearch.value!.query != '' &&
          isVisibleSuggestText.value) {
        return SizedBox(
            width: double.maxFinite,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...suggestSearch.value!.suggestQueries
                  .map((query) => _suggestTextContent(query))
            ]));
      } else {
        return Container();
      }
    }, [suggestSearch.value, isVisibleSuggestText.value]);

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
      Row(children: [
        Expanded(
            child: Card(
                color: searchVideo.value ? Colors.blue.shade100 : null,
                child: InkWell(
                    child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        child: Text('video')),
                    onTap: () => searchVideo.value = !searchVideo.value))),
        Expanded(
            child: Card(
                color: searchPlaylist.value ? Colors.blue.shade100 : null,
                child: InkWell(
                    child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        child: Text('playlist')),
                    onTap: () =>
                        searchPlaylist.value = !searchPlaylist.value))),
        Expanded(
            child: Card(
                color: searchChannel.value ? Colors.blue.shade100 : null,
                child: InkWell(
                    child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        child: Text('channel')),
                    onTap: () => searchChannel.value = !searchChannel.value))),
      ]),
      Expanded(
          child: Stack(children: [
        SingleChildScrollView(
            child: Column(children: [
          if (searchResult.hasData)
            ...searchResult.data!.items.map(
                (item) => videoCard(ExtendsSearchResult(item), dListNotifier))
        ])),
        _suggestList()
      ]))
    ]);
  }
}

Widget videoCard(
  ExtendsSearchResult item,
  DownloadListStateNotifier dListNotifier,
) {
  inspect(item);
  return GestureDetector(
      onTap: () {
        if (item.itemKind == ItemKind.channel) return;
        if (item.itemKind == ItemKind.none) return;

        if (item.itemKind == ItemKind.playlist ||
            item.itemKind == ItemKind.video) {
          dListNotifier.setSearchResult(item);
        }

        // if (item.id.kind == 'youtube#video') {
        //   dListNotifier.setId(item.id.videoId!);
        // }
        // if (item.id.kind == 'youtube#playlist') {
        //   dListNotifier.setPlaylist(
        //       MyPlaylist(
        //           item.id.playlistId ?? '',
        //           item.snippet!.title,
        //           item.snippet?.description ?? '',
        //           item.snippet?.thumbnails.high?.url ?? ''),
        //       playlistItems);
        // }
      },
      child: Container(
          color: Colors.black12,
          margin: const EdgeInsets.all(10),
          child: Row(children: [
            Image.network(item.snippet!.thumbnails.medium!.url, width: 70),
            Expanded(
                child:
                    Text(item.snippet!.title, overflow: TextOverflow.ellipsis))
          ])));
}
