import 'package:common/managers/theme_manager.dart';
import 'package:flutter/material.dart';

void main() async {
  await ThemeManager.factory();
  runApp(MaterialApp());
}
