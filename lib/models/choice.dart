import 'package:flutter/cupertino.dart';

class Choice {
  const Choice(
      {required this.title, required this.icon, required this.complete});
  final String title;
  final IconData icon;
  final bool complete;
}
