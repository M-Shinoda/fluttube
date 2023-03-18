import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/states/download_list.dart';
import 'package:fluttube/utils/file_manage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';

import '../audio/page_manager.dart';
import '../services/playlist_repository.dart';
import '../services/service_locator.dart';

class PlaylisView extends HookConsumerWidget {
  const PlaylisView({Key? key}) : super(key: key);

  @override
  build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);
    final _playlistsCard = useMemoized(() async {
      final playlists = FileManager().getDirPFileList();
      return playlists.map((playlist) => InkWell(
          onTap: () async {
            getIt<PageManager>().switchingPlaylist(
                await getIt<PlaylistRepository>().fetchAnotherPlaylist(
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
                        onPressed: () async {
                          final playlists = FileManager().getDirPFileList();
                          for (var playlistFile in playlists) {
                            final playlistId = basename(playlistFile.path)
                                .replaceFirst('.txt', '');

                            dListNotifier.setPlaylist(playlistId,
                                isWriteCache: false);
                          }
                        },
                        child: const Icon(Icons.add)))
              ],
            )));
  }
}
