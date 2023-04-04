import 'package:android_content_provider/android_content_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttube/services/service_locator.dart';
import 'package:fluttube/utils/image_color_picker.dart';

import 'audio/audio.dart';
import 'audio/page_manager.dart';

class FloatingPlayer extends HookWidget {
  const FloatingPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final artColor = useState<Color?>(null);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return const AudioView(); // 遷移先の画面widgetを指定
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: artColor.value?.withAlpha(200) ?? Colors.grey,
            borderRadius: BorderRadius.circular(10)),
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CurrentArt(
                artColor: artColor,
              ),
            ),
            const CurrentTitle(),
            const Align(
              alignment: Alignment.centerRight,
              child: AudioControlButtons(),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrentTitle extends StatelessWidget {
  const CurrentTitle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<MediaItem?>(
      valueListenable: pageManager.currentSongNotifier,
      builder: (_, mediaItem, __) {
        return Expanded(
          child: Text(
            mediaItem?.title ?? '',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.fade,
          ),
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: const [
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
        ],
      ),
    );
  }
}

class CurrentArt extends HookWidget {
  final ValueNotifier<Color?>? artColor;
  const CurrentArt({this.artColor, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final currentMediaItem = useState<MediaItem?>(null);
    final _loadSignal = useState<CancellationSignal?>(null);

    final _listenCallback = useCallback((PageManager pageManager) {
      currentMediaItem.value = pageManager.currentSongNotifier.value;
    }, const []);

    useEffect(() {
      final pageManager = getIt<PageManager>();
      pageManager.currentSongNotifier
          .addListener(() => _listenCallback(pageManager));
      return () {
        pageManager.currentSongNotifier
            .removeListener(() => _listenCallback(pageManager));
      };
    }, const []);

    final getCacheSize = useCallback(() {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      return (60 * devicePixelRatio).toInt();
    }, const []);

    final imageWidget = useMemoized(() async {
      if (currentMediaItem.value == null) return Container();
      final cacheSize = getCacheSize();
      _loadSignal.value?.cancel();
      _loadSignal.value = CancellationSignal();
      final bytes = await AndroidContentResolver.instance.loadThumbnail(
        uri: currentMediaItem.value!.extras!['url'],
        width: cacheSize,
        height: cacheSize,
        cancellationSignal: _loadSignal.value,
      );
      artColor?.value = ImageColorPicker.fromBytes(bytes).frequentColor;
      return Image.memory(bytes, cacheHeight: cacheSize, cacheWidth: cacheSize);
    }, [currentMediaItem.value]);

    final imageWidgetSnapshot = useFuture(imageWidget);

    return imageWidgetSnapshot.hasData
        ? Container(
            child: imageWidgetSnapshot.data!,
          )
        : const CircularProgressIndicator();
  }
}
