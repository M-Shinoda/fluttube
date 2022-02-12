import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'download_list.dart';
import 'list_card.dart';
import 'models/choice.dart';

class ChoiceView extends HookConsumerWidget {
  const ChoiceView({Key? key, required this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dListNotifier = ref.read(downloadListProvider.notifier);
    return Column(
      children: <Widget>[
        Expanded(
          child: ListCard(
              items: dListNotifier.getList(isComlete: choice.complete)),
        ),
      ],
    );
  }
}
