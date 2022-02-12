import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttube/home.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BottomView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _pageWidget = [Container(), HomeView()];
    final _currentIndex = useState(0);

    void _onItemTapped(int index) {
      _currentIndex.value = index;
    }

    return Scaffold(
      body: _pageWidget.elementAt(_currentIndex.value),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: "Download"),
        ],
        currentIndex: _currentIndex.value,
        fixedColor: Colors.blueGrey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
