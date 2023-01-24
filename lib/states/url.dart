import 'package:flutter_riverpod/flutter_riverpod.dart';

final textFieldUrlProvider =
    StateNotifierProvider<TextFieldDownloadStateNotifier, String>((_) {
  return TextFieldDownloadStateNotifier();
});

class TextFieldDownloadStateNotifier extends StateNotifier<String> {
  TextFieldDownloadStateNotifier() : super('');
  void update(String url) => state = url;
}
