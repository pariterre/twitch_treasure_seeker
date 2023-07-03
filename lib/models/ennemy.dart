import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_tile.dart';

class Ennemy {
  final String name;
  final Color color;

  Ennemy({required this.name, required this.color});

  // Current position of the ennemy
  GameTile tile = GameTile.none();
  final List<GameTile> _nextPosition = [];

  ///
  /// Advance the current position to next position in the queue
  bool march() {
    if (_nextPosition.isEmpty) return false;

    tile = _nextPosition.removeAt(0);
    return true;
  }

  ///
  /// Add a target path to the position queue
  void addTarget(GameTile tile) => _computePath(tile);

  ///
  /// Computes the path to get from current
  /// position to target and adds the re
  void _computePath(GameTile tileTarget) {
    // Initialize the new row and col to end of _nextPosition if exists.
    // Otherwise, set it a current position
    GameTile nextTile = tile.copy;
    if (_nextPosition.isNotEmpty) nextTile = _nextPosition.last;

    // Perform a march toward the target row or col at a time
    while (nextTile != tileTarget) {
      // Advance for 1 step in the direction of error
      nextTile = GameTile(nextTile.row + (tileTarget.row - nextTile.row).sign,
          nextTile.col + (tileTarget.col - nextTile.col).sign);
      _nextPosition.add(nextTile);
    }
  }
}
