import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DownloadView extends HookConsumerWidget {
  const DownloadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: DefaultTabController(
        length: choices.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Fluttube '),
            bottom: TabBar(
              tabs: choices.map(
                (Choice choice) {
                  return Tab(
                    text: choice.title,
                    icon: Icon(choice.icon),
                  );
                },
              ).toList(),
            ),
          ),
          body: TabBarView(
            children: choices.map((Choice choice) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ChoiceCard(choice: choice),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({required this.title, required this.icon});
  final String title;
  final IconData icon;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'ダウンロード済み', icon: Icons.cloud_done_outlined),
  Choice(title: 'ダウンロード中', icon: Icons.cloud_download_outlined),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key? key, required this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0),
            Text(choice.title),
          ],
        ),
      ),
    );
  }
}
