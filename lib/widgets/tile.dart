enum TileValue {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  treasure,
  letter;

  int get value {
    switch (this) {
      case zero:
        return 0;
      case one:
        return 1;
      case two:
        return 2;
      case three:
        return 3;
      case four:
        return 4;
      case five:
        return 5;
      case six:
        return 6;
      case seven:
        return 7;
      case eight:
        return 8;
      case treasure:
        return -1;
      case letter:
        return -2;
    }
  }

  @override
  String toString() {
    switch (this) {
      case zero:
        return '';
      case one:
        return '1';
      case two:
        return '2';
      case three:
        return '3';
      case four:
        return '4';
      case five:
        return '5';
      case six:
        return '6';
      case seven:
        return '7';
      case eight:
        return '8';
      case treasure:
        return '';
      case letter:
        return '';
    }
  }
}

class Tile {
  final int _index;
  int get index => _index;

  TileValue value;

  bool _isConcealed;
  bool get isConcealed => _isConcealed;
  bool get isRevealed => !_isConcealed;

  Tile({required int index, required this.value, required bool isConcealed})
      : _index = index,
        _isConcealed = isConcealed;

  void addTreasure() => value = TileValue.treasure;
  void addLetter() => value = TileValue.letter;
  bool get hasTreasure => value == TileValue.treasure;
  bool get hasLetter => value == TileValue.letter;
  bool get hasReward =>
      value == TileValue.treasure || value == TileValue.letter;
  bool get hasNoReward => !hasReward;

  void decrement() {
    if (hasReward) return;
    if (value == TileValue.zero) return;

    value = TileValue.values[value.value - 1];
  }

  void reveal() {
    _isConcealed = false;
  }
}
