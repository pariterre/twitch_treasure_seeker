import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_tile.dart';

class Player {
  final String username;
  final Color color;

  int score = 0;
  int energy = 0;
  int maxEnergy;
  int restingCmp = 0;
  int minimumRestingTime;

  // Current position of the player
  GameTile tile = GameTile.none();
  final List<GameTile> _nextPosition = [];

  // Constructor
  Player({
    required this.username,
    required this.color,
    required this.maxEnergy,
    required this.minimumRestingTime,
  });

  void refillEnergy() {
    energy = maxEnergy;
  }

  // Reset player (usually for a new game)
  void reset({required int maxEnergy, required int minimumRestingTime}) {
    score = 0;

    this.maxEnergy = maxEnergy;
    energy = maxEnergy;

    this.minimumRestingTime = minimumRestingTime;
    restingCmp = minimumRestingTime;

    tile = GameTile.none();
  }

  ///
  /// Advance the current position to next position in the queue
  bool march() {
    if (_nextPosition.isEmpty || isExhausted) return false;

    tile = _nextPosition.removeAt(0);

    energy--;
    restingCmp = 0;

    return true;
  }

  ///
  /// Is the player exhausted (has no energy left)
  bool get isExhausted => energy <= 0;

  ///
  /// Rest the player, returns true if anything changed
  bool rest() {
    // If not rested, then wait
    if (restingCmp < minimumRestingTime) {
      restingCmp++;
      return true;
    }

    // If well rested and not at its maximum stamina
    if (energy < maxEnergy) {
      energy++;
      // Penalize long movement by restarting resting period
      if (_nextPosition.isNotEmpty) restingCmp = 0;
      return true;
    }
    return false;
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
