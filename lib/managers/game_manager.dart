import 'dart:async';
import 'dart:math';

import 'package:twitch_treasure_seeker/managers/words_manager.dart';
import 'package:twitch_treasure_seeker/models/enums.dart';
import 'package:twitch_treasure_seeker/models/game_tile.dart';
import 'package:twitch_treasure_seeker/models/generic_listener.dart';

///
/// Easy accessors translating index into row/col pair or row/col pair into
/// index
int toGridIndex(GameTile tile, int nbCols) => tile.row * nbCols + tile.col;
GameTile toGridTile(int index, int nbCols) =>
    GameTile(index < 0 ? -1 : index ~/ nbCols, index < 0 ? -1 : index % nbCols);

class GameManager {
  /// Prepare the singleton
  static final GameManager _instance = GameManager._();
  static GameManager get instance => _instance;
  GameManager._() {
    _generateGrid();
    _startGameLoop();
  }

  ///
  /// Time remaining
  Duration _timeRemaining = const Duration(seconds: 20);
  Duration get timeRemaining => _timeRemaining;

  ///
  /// Number of tries remaining
  int _triesRemaining = 5;
  int get triesRemaining => _triesRemaining;

  ///
  /// Rewards when a treasure (tries) or a letter (time) are found
  final Duration _rewardInTime = const Duration(seconds: 5);
  final int _rewardInTrials = 1;

  // Listeners
  final onClockTicked = GenericListener<Function(Duration)>();
  final onTileRevealed = GenericListener<Function()>();
  final onTreasureFound = GenericListener<Function(Tile)>();
  final onGameOver = GenericListener<Function(bool)>();

  // Size of the grid
  final int nbRows = 20;
  final int nbCols = 10;
  final int nbTreasures = 40;
  final bool revealIfTreasureIsFound = false;

  // The actual grid
  List<int> _grid = [];
  Map<int, String> _letterGrid = {};
  List<bool> _isRevealed = [];

  ///
  /// If the game is over
  bool get hasWin =>
      treasuresFoundCount == nbTreasures ||
      lettersFoundCount == WordsManager.instance.current.length;
  bool get hasLost => isGameOver && !hasWin;
  bool get isGameOver =>
      hasWin || _timeRemaining.inSeconds <= 0 || _triesRemaining <= 0;

  ///
  /// Get the value of a tile of a specific [index]. If the tile is not
  /// revealed yet, this method returns concealed; if the tile is a treasure, then it
  /// returns treasure, otherwise it returns the number of treasure around it.
  Tile getTile(int index) =>
      _isRevealed[index] ? _getRevealedTile(index) : Tile.concealed;

  ///
  /// Same as tile, but return the non-conceiled value
  Tile _getRevealedTile(int index) {
    switch (_grid[index]) {
      case -2:
        return Tile.letter;
      case -1:
        return Tile.treasure;
      default:
        return Tile.values[_grid[index]];
    }
  }

  ///
  /// Get if a tile is a treasure
  bool _isTreasure(int index) => _grid[index] < 0;

  ///
  /// Get the number of treasures that were found
  int get treasuresFoundCount => _grid.asMap().keys.fold(
      0,
      (prev, index) =>
          prev + (_isRevealed[index] && _isTreasure(index) ? 1 : 0));

  ///
  /// Get the letter of a tile
  String? getLetter(int index) =>
      _isRevealed[index] ? _letterGrid[index] : null;

  ///
  /// Get all the letters that were found
  Iterable<bool> get getLettersFoundIndices =>
      _letterGrid.entries.map((entry) => _isRevealed[entry.key]);

  ///
  /// Get the number of letters that were found
  int get lettersFoundCount =>
      getLettersFoundIndices.fold(0, (prev, found) => prev + (found ? 1 : 0));

  ///
  /// Main interface for a user to reveal a tile from the grid
  RevealResult revealTile({GameTile? tile, int? tileIndex}) {
    if (isGameOver) return RevealResult.gameOver;

    if (tile == null && tileIndex == null) {
      throw 'You must provide either a tile or an index';
    } else if (tile != null && tileIndex != null) {
      throw 'You must provide either a tile or an index, not both';
    }

    if (tile != null) {
      tileIndex = toGridIndex(tile, nbCols);
    } else {
      tile = toGridTile(tileIndex!, nbCols);
    }

    // Safe guards
    // If tile not in the grid
    if (!_isInsideGrid(tile)) return RevealResult.outsideGrid;
    // If tile was already revealed
    if (_isRevealed[tileIndex]) return RevealResult.alreadyRevealed;

    // Change the values of the surrounding tiles if it is a treasure
    if (_isTreasure(tileIndex)) {
      _adjustSurroundingHints(tile);
      // If it is a letter, add time
      if (_grid[tileIndex] == -2) {
        _timeRemaining += _rewardInTime;
      } else {
        _triesRemaining += _rewardInTrials;
      }
    } else {
      // If it is not a treasure, reduce the number of tries
      _triesRemaining--;
    }

    // Start the recursive process of revealing all the required tiles
    _revealTileRecursive(tileIndex);

    // Notify the listeners that a tile was revealed
    onTileRevealed.notifyListeners((callback) => callback());
    if (_isTreasure(tileIndex)) {
      onTreasureFound.notifyListeners((callback) =>
          callback(_grid[tileIndex!] == -2 ? Tile.letter : Tile.treasure));
    }

    // Check if the game is over
    if (isGameOver) {
      onGameOver.notifyListeners((callback) => callback(hasWin));
      return RevealResult.gameOver;
    } else {
      return _isTreasure(tileIndex) ? RevealResult.hit : RevealResult.miss;
    }
  }

  ///
  /// Reveal a tile. If it is a zero, it is recursively called to all its
  /// neighbourhood so it automatically reveals all the surroundings
  void _revealTileRecursive(int idx, {List<bool>? isChecked}) {
    // For each zeros encountered, we must check around if it is another zero
    // so it can be reveal. We must make sure we don't recheck a previously
    // checked tile though so we don't go in an infinite loop of checking.
    isChecked ??= List.filled(nbRows * nbCols, false); // If first time

    // If it is already revealed, do nothing
    if (isChecked[idx]) return;
    isChecked[idx] = true;

    // Reveal the current tile
    _isRevealed[idx] = true;

    // If the current tile is not zero, stop revealing, otherwise reveal the tiles around
    if (!revealIfTreasureIsFound && _isTreasure(idx)) return;
    if (_grid[idx] > 0) return;

    final currentTile = toGridTile(idx, nbCols);
    for (var j = -1; j < 2; j++) {
      for (var k = -1; k < 2; k++) {
        // Do not reveal itself
        if (j == 0 && k == 0) continue;

        // Do not try to reveal tile outside of the grid
        final newTile = GameTile(currentTile.row + j, currentTile.col + k);
        if (!_isInsideGrid(newTile)) continue;

        // If current tile is a treasure, only reveal new zeros
        final newIndex = toGridIndex(newTile, nbCols);
        if (_isTreasure(idx) && _grid[newIndex] != 0) continue;

        // Reveal the tile if it was not already revealed
        _revealTileRecursive(newIndex, isChecked: isChecked);
      }
    }
  }

  ///
  /// Get if a tile is inside or outside the current grid
  bool _isInsideGrid(GameTile tile) {
    // Do not check rows or column outside of the grid
    return (tile.row >= 0 &&
        tile.col >= 0 &&
        tile.row < nbRows &&
        tile.col < nbCols);
  }

  ///
  /// Generate a new grid with randomly positionned treasures
  void _generateGrid() {
    // Create an empty grid
    _grid = List.filled(nbRows * nbCols, 0);
    _isRevealed = List.filled(nbRows * nbCols, false);

    // Fetch a word to find
    final word = WordsManager.instance.next;
    _letterGrid = {};

    // Populate it with treasures
    final rand = Random();
    for (var i = 0; i < nbTreasures; i++) {
      var indexOfTreasure = -1;
      do {
        indexOfTreasure = rand.nextInt(nbRows * nbCols);
        // Make sure it was not already a treasure
      } while (_grid[indexOfTreasure] < 0);
      if (_letterGrid.length < word.length) {
        _letterGrid[indexOfTreasure] = word[_letterGrid.length];
        _grid[indexOfTreasure] = -2;
      } else {
        _grid[indexOfTreasure] = -1;
      }
    }

    // Recalculate the value of each tile based on number of treasures around it
    for (var i = 0; i < nbRows * nbCols; i++) {
      // Do not recompute tile with a treasure in it
      if (_isTreasure(i)) continue;

      var nbTreasuresAroundTile = 0;

      final currentTile = toGridTile(i, nbCols);
      // Check the previous row to next row
      for (var j = -1; j <= 1; j++) {
        // Check the previous col to next col
        for (var k = -1; k <= 1; k++) {
          // Do not check itself
          if (j == 0 && k == 0) continue;

          // Find the current checked tile
          final checkedTile =
              GameTile(currentTile.row + j, currentTile.col + k);
          if (!_isInsideGrid(checkedTile)) continue;

          // If there is a treasure, add it to the counter
          if (_isTreasure(toGridIndex(checkedTile, nbCols))) {
            nbTreasuresAroundTile++;
          }
        }
      }

      // Store the number in the tile
      _grid[i] = nbTreasuresAroundTile;
    }
  }

  ///
  /// When a treasure is found, lower all the surronding numbers
  void _adjustSurroundingHints(GameTile treasure) {
    for (var j = -1; j <= 1; j++) {
      // Check the previous col to next col
      for (var k = -1; k <= 1; k++) {
        // Do not check itself
        if (j == 0 && k == 0) continue;

        final tile = GameTile(treasure.row + j, treasure.col + k);
        if (!_isInsideGrid(tile)) continue;
        final index = toGridIndex(tile, nbCols);

        // If this is not a treasure, reduce that tile by one
        if (_grid[index] > 0) _grid[index]--;
      }
    }
  }

  ///
  /// Start the game loop
  Future<void> _startGameLoop() async {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _gameLoop();
      if (isGameOver) timer.cancel();
    });
  }

  ///
  /// The game loop
  void _gameLoop() {
    _tickClock();

    if (isGameOver) {
      onGameOver.notifyListeners((callback) => callback(hasWin));
      return;
    }
  }

  ///
  /// Tick the clock by one second
  void _tickClock() {
    _timeRemaining -= const Duration(seconds: 1);
    onClockTicked.notifyListeners((callback) => callback(_timeRemaining));
  }
}
