import 'package:flutter_riverpod/flutter_riverpod.dart';

final textFieldUrlProvider =
    StateNotifierProvider<TextFieldUrlStateNotifier, String>((_) {
  return TextFieldUrlStateNotifier();
});

class TextFieldUrlStateNotifier extends StateNotifier<String> {
  TextFieldUrlStateNotifier() : super('');
  void update(String url) => state = url;
}
