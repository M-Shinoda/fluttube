import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/utils/file_manage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/choice.dart';
import '../models/download_cache.dart';
import '../states/download_list.dart';
import 'list_card.dart';

class ChoiceView extends HookConsumerWidget {
  const ChoiceView({Key? key, required this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dList = ref.watch(downloadListProvider);
    final updator = useState(0);

    useEffect(() {
      if (!choice.complete) return null;
      print('update');
      if ([...dList.map((state) => state.completed)].contains(false) &&
          updator.value != 0) return;
      updator.value += 1;
      return null;
    }, [dList]);

    final Future<List<DownloadCache>> featchCacheSnapshot =
        useMemoized(() async {
      if (updator.value == 0) return [];
      print('fetch');
      return await FileManager().readCache();
    }, [updator.value]);

    final fetchCache = useFuture(featchCacheSnapshot);

    return Column(children: <Widget>[
      Expanded(
          child: !choice.complete
              ? ListCard(
                  items: [...dList.where((urlState) => !urlState.completed)])
              : fetchCache.data != null
                  ? ListCacheCard(caches: [...fetchCache.data!.reversed])
                  : Container())
    ]);
  }
}
