import 'dart:math';

import 'package:twitch_treasure_seeker/models/french_words.dart';

class WordsManager {
  /// Prepare the singleton
  static final WordsManager _instance = WordsManager._();
  static WordsManager get instance => _instance;
  WordsManager._();

  final _random = Random();
  final List<String> _words = frenchWords;

  ///
  /// Get a random word from the list (capitalized)
  late int _seed = _random.nextInt(_words.length);
  String get next {
    _seed = _random.nextInt(_words.length);
    return current;
  }

  String get current => _words[_seed].toUpperCase();
}
