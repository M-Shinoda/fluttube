import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageColorPicker {
  final img.Image image;

  ImageColorPicker(Uint8List imageBytes) : image = img.decodeImage(imageBytes)!;

  ImageColorPicker.fromBytes(Uint8List imageBytes)
      : image = img.decodeImage(imageBytes)!;

  ImageColorPicker.fromFile(String path)
      : image = img.decodeImage(File(path).readAsBytesSync())!;

  /// 画像の座標から色を取得
  Color pickColor(int x, int y) {
    final pixel = image.getPixel(x, y);
    return Color.fromARGB(
        pixel.a.toInt(), pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
  }

  /// 画像で最も使われている色を取得
  /// 全ピクセル分処理が行われるため遅い
  Color get frequentColor {
    Map<String, int> colorWithFrequentCount = {};
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final color = pickColor(x, y);
        if (colorWithFrequentCount.containsKey(color.toString())) {
          final count = colorWithFrequentCount[color.toString()]! + 1;
          colorWithFrequentCount[color.toString()] = count;
        } else {
          colorWithFrequentCount[color.toString()] = 1;
        }
      }
    }
    final maxCount = colorWithFrequentCount.values.reduce(max);
    String colorString = '';
    colorWithFrequentCount.forEach((key, count) {
      if (count == maxCount) {
        colorString = key;
        return;
      }
    });
    return Color(int.parse(colorString.substring(6, 16)));
  }

  int get width => image.width;

  int get height => image.height;
}
