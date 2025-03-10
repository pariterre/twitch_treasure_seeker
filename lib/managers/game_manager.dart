import 'dart:math';

import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/models/enums.dart';
import 'package:twitch_treasure_seeker/models/game_tile.dart';
import 'package:twitch_treasure_seeker/models/generic_listener.dart';

const List<Color> colorCycle = [
  Colors.purple,
  Colors.cyan,
  Colors.orange,
  Colors.pink,
  Colors.indigo,
  Colors.blueGrey,
  Colors.black,
  Colors.red,
  Colors.brown,
  Colors.blue,
];

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
  }

  // Listeners
  final onTileRevealed = GenericListener<Function()>();
  final onTreasureFound = GenericListener<Function()>();
  final onGameOver = GenericListener<Function()>();

  // Size of the grid
  final int nbRows = 20;
  final int nbCols = 10;
  final int nbTreasures = 40;

  // The actual grid
  List<int> _grid = [];
  List<bool> _isRevealed = [];

  ///
  /// Reset the board to initial and call the refresh the draw
  void newGame() {
    _generateGrid();
  }

  ///
  /// Get the value of a tile of a specific [index]. If the tile is not
  /// revealed yet, this method returns concealed; if the tile is a treasure, then it
  /// returns treasure, otherwise it returns the number of treasure around it.
  Tile getTile(int index) =>
      _isRevealed[index] ? getRevealedTile(index) : Tile.concealed;

  ///
  /// Same as tile, but return the non-conceiled value
  Tile getRevealedTile(int index) =>
      _grid[index] < 0 ? Tile.treasure : Tile.values[_grid[index]];

  ///
  /// Get the number of treasures that were found
  int get treasuresFound => _grid.asMap().keys.fold(
      0, (prev, index) => prev + (getTile(index) == Tile.treasure ? 1 : 0));

  ///
  /// Main interface for a user to reveal a tile from the grid
  RevealResult revealTile({GameTile? tile, int? tileIndex}) {
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

    // Start the recursive process of revealing all the required tiles
    _revealTileRecursive(tileIndex);

    // Give points if necessary
    if (_grid[tileIndex] == -1) {
      _adjustSurroundingHints(toGridTile(tileIndex, nbCols));
      onTreasureFound.notifyListeners((callback) => callback());
    }

    // Check if the game is over
    if (treasuresFound == nbTreasures) {
      onGameOver.notifyListeners((callback) => callback());
      return RevealResult.gameOver;
    }

    // Notify the listeners that a tile was revealed
    onTileRevealed.notifyListeners((callback) => callback());
    return _grid[tileIndex] == -1 ? RevealResult.hit : RevealResult.miss;
  }

  ///
  /// Reveal a tile. If it is a zero, it is recursively called to all its
  /// neighbourhood so it automatically reveals all the surroundings
  void _revealTileRecursive(int idx, {List<bool>? isChecked}) {
    // If it is already revealed, do nothing
    if (_isRevealed[idx] || (isChecked != null && isChecked[idx])) return;

    // For each zeros encountered, we must check around if it is another zero
    // so it can be reveal. We must make sure we don't recheck a previously
    // checked tile though so we don't go in an infinite loop of checking.
    if (isChecked == null) {
      // Prepare the isChecked structure and launch the recursive procedure
      isChecked = List.filled(nbRows * nbCols, false);
      return _revealTileRecursive(idx, isChecked: isChecked);
    }

    // Reveal the current tile
    _isRevealed[idx] = true;

    // If the current tile is not zero or a treasure, stop revealing,
    // otherwise reveal the tiles around
    if (_grid[idx] != 0) return;

    final currentTile = toGridTile(idx, nbCols);
    for (var j = -1; j < 2; j++) {
      for (var k = -1; k < 2; k++) {
        // Do not reveal itself
        if (j == 0 && k == 0) continue;

        // Do not try to reveal tile outside of the grid
        final newTile = GameTile(currentTile.row + j, currentTile.col + k);
        if (!_isInsideGrid(newTile)) continue;

        // Reveal the tile if it was not already revealed
        final newIndex = toGridIndex(newTile, nbCols);
        if (_isRevealed[newIndex]) continue;

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

    // Populate it with treasures
    final rand = Random();
    for (var i = 0; i < nbTreasures; i++) {
      var indexOfTreasure = -1;
      do {
        indexOfTreasure = rand.nextInt(nbRows * nbCols);
        // Make sure it was not already a treasure
      } while (_grid[indexOfTreasure] == -1);
      _grid[indexOfTreasure] = -1;
    }

    // Recalculate the value of each tile based on number of treasures around it
    for (var i = 0; i < nbRows * nbCols; i++) {
      // Do not recompute tile with a treasure in it
      if (_grid[i] < 0) continue;

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
          if (_grid[toGridIndex(checkedTile, nbCols)] < 0) {
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
}
