import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/floating_player.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../audio/audio.dart';
import '../download/download_view.dart';
import '../playlist/playlist_view.dart';
import '../states/download_list.dart';
import '../youtube/youtube_my_playlist.dart';
import '../youtube/youtube_view.dart';

class BottomView extends HookConsumerWidget {
  const BottomView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dList = ref.watch(downloadListProvider);
    final _pageWidget = [
      const YoutubeView(),
      const YoutubeMyPlaylist(),
      const AudioView(),
      const PlaylisView(),
      const DownloadView(),
    ];
    final _currentIndex = useState(0);
    final _pageViewController = PageController();

    void _onItemTapped(int index) {
      _pageViewController.animateToPage(index,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }

    final downloadingCount = useMemoized(() {
      int count = 0;
      for (var state in dList) {
        if (!state.completed) count++;
      }
      return count.toString();
    }, [dList]);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            // physics: NeverScrollableScrollPhysics(),
            controller: _pageViewController,
            children: _pageWidget,
            onPageChanged: (index) => _currentIndex.value = index,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 100),
              child: const FloatingPlayer(),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex.value,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Playlist(YT)"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded), label: "Audio"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Playlist"),
          BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded),
                  Text(downloadingCount)
                ],
              ),
              label: "Download"),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
