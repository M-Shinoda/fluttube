import 'package:flutter_riverpod/flutter_riverpod.dart';

final countProvider = StateNotifierProvider<CountStateNotifier, int>((_) {
  return CountStateNotifier();
});

class CountStateNotifier extends StateNotifier<int> {
  CountStateNotifier() : super(0);
  void update() => state = state += 1;
}
