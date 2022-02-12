import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttube/choice_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'models/choice.dart';

class DownloadView extends HookConsumerWidget {
  const DownloadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const List<Choice> choices = <Choice>[
      Choice(
          title: 'ダウンロード済み', icon: Icons.cloud_done_outlined, complete: true),
      Choice(
          title: 'ダウンロード中',
          icon: Icons.cloud_download_outlined,
          complete: false),
    ];

    return MaterialApp(
      home: DefaultTabController(
        initialIndex: 1,
        length: choices.length,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            toolbarHeight: 0,
            bottom: TabBar(
              tabs: choices.map(
                (choice) {
                  return Tab(
                    text: choice.title,
                    icon: Icon(choice.icon),
                  );
                },
              ).toList(),
            ),
          ),
          body: TabBarView(
            children: choices.map((choice) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ChoiceView(choice: choice),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
