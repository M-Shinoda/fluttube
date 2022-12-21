import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/main.dart';
import 'package:fluttube/states/download_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';

import '../audio/page_manager.dart';
import '../services/playlist_repository.dart';
import '../services/service_locator.dart';

class PlaylisView extends HookConsumerWidget {
  const PlaylisView({Key? key}) : super(key: key);

  @override
  build(BuildContext context, WidgetRef ref) {
    final _playlistsCard = useMemoized(() async {
      final playlists = dirP.listSync();
      return playlists.map((playlist) => InkWell(
          onTap: () async {
            final songRepository = getIt<PlaylistRepository>();
            final pageManager = getIt<PageManager>();
            pageManager.switchingPlaylist(
                await songRepository.fetchAnotherPlaylist(
                    basename(playlist.path).replaceFirst('.txt', '')));
          },
          child: Card(
              child: Container(
            height: 50,
            width: double.maxFinite,
            alignment: Alignment.centerLeft,
            child: Text(basename(playlist.path)),
          ))));
    }, const []);

    final playlistCardSnapshot = useFuture(_playlistsCard);

    return SafeArea(
        child: Container(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  children: playlistCardSnapshot.data?.toList() ?? [],
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                        onPressed: () {}, child: const Icon(Icons.add)))
              ],
            )));
  }
}
