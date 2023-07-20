import 'package:flutter/material.dart';

import 'game_tile.dart';

///
/// This is the abstract class that holds any actor (such as players)
abstract class Actor {
  final String name;
  final Color color;

  Actor({required this.name, required this.color});

  // Current position of the player
  GameTile tile = const GameTile.starting();
  final List<GameTile> nextPosition = [];

  ///
  /// Advance the current position to next position in the queue
  bool march(List<GameTile> forbiddenTiles) {
    if (nextPosition.isEmpty) return false;

    if (tile != const GameTile.starting() &&
        forbiddenTiles.contains(nextPosition.first)) {
      nextPosition.clear();
      return false;
    }

    tile = nextPosition.removeAt(0);
    return true;
  }

  ///
  /// Computes the path to get from current
  /// position to target and adds the re
  void addTarget(GameTile tileTarget) {
    // Initialize the new row and col to end of _nextPosition if exists.
    // Otherwise, set it a current position
    GameTile nextTile = tile.copy;
    if (nextPosition.isNotEmpty) nextTile = nextPosition.last;

    // Perform a march toward the target row or col at a time
    while (nextTile != tileTarget) {
      // Advance for 1 step in the direction of error
      nextTile = GameTile(nextTile.row + (tileTarget.row - nextTile.row).sign,
          nextTile.col + (tileTarget.col - nextTile.col).sign);
      nextPosition.add(nextTile);
    }
  }
}
