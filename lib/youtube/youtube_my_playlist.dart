import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/youtube_model.dart';
import '../states/download_list.dart';
import '../utils/youtube_api.dart';

class YoutubeMyPlaylist extends HookConsumerWidget {
  const YoutubeMyPlaylist({Key? key}) : super(key: key);

  @override
  build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);
    final playlistItems = useState<List<PlaylistItem>>([]);
    final _playlistsSnapshot =
        useMemoized(() => getMyChannelPlaylistOnlyPublic(), const []);
    final playlistsSnapshot = useFuture(_playlistsSnapshot);

    final onTapCard = useCallback(
        (MyPlaylist playlist,
                ValueNotifier<List<PlaylistItem>> playlistItems) async =>
            dListNotifier.setPlaylist(playlist, playlistItems),
        const []);

    return SafeArea(
        child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
                children: (playlistsSnapshot.data ?? [])
                    .map((playlist) => InkWell(
                        onTap: () => onTapCard(playlist, playlistItems),
                        child: Card(
                            child: Container(
                                height: 50,
                                width: double.maxFinite,
                                alignment: Alignment.centerLeft,
                                child: Text(playlist.title)))))
                    .toList())));
  }
}
