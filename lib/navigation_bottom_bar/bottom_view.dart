import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../audio/audio.dart';
import '../download/download_view.dart';
import '../youtube/youtube_view.dart';

class BottomView extends HookConsumerWidget {
  const BottomView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _pageWidget = [
      const YoutubeView(),
      const AudioView(),
      const DownloadView()
    ];
    final _currentIndex = useState(0);
    final _pageViewController = PageController();

    void _onItemTapped(int index) {
      _pageViewController.animateToPage(index,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }

    return Scaffold(
      body: PageView(
        // physics: NeverScrollableScrollPhysics(),
        controller: _pageViewController,
        children: _pageWidget,
        onPageChanged: (index) => _currentIndex.value = index,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex.value,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded), label: "Audio"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: "Download"),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
