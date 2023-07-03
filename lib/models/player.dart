import 'package:flutter/material.dart';

class Player {
  final String username;
  final Color color;

  int score = 0;
  int energy = 0;
  int maxEnergy;
  int restingCmp = 0;
  int minimumRestingTime;

  // Current position of the player
  int row = -1;
  int col = -1;
  final List<List<int>> _nextPosition = [];

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

    row = -1;
    col = -1;
  }

  ///
  /// Advance the current position to next position in the queue
  bool march() {
    if (_nextPosition.isEmpty || isExhausted) return false;

    final newPosition = _nextPosition.removeAt(0);
    row = newPosition[0];
    col = newPosition[1];

    energy--;
    restingCmp = 0;

    return true;
  }

  bool get isExhausted => energy <= 0;

  void rest() {
    // If not rested, then wait
    if (restingCmp < minimumRestingTime) {
      restingCmp++;
      return;
    }

    // If well rested and not at its maximum stamina
    if (energy < maxEnergy) {
      energy++;
      // Penalize long movement
      if (_nextPosition.isNotEmpty) restingCmp = 0;
    }
  }

  ///
  /// Add a target path to the position queue
  void addTarget(int row, int col) {
    _computePath(row, col);
  }

  ///
  /// Computes the path to get from current
  /// position to target and adds the re
  void _computePath(int rowTarget, int colTarget) {
    // Initialize the new row and col to end of _nextPosition if exists.
    // Otherwise, set it a current position
    int rowNew = row;
    int colNew = col;
    if (_nextPosition.isNotEmpty) {
      rowNew = _nextPosition.last[0];
      colNew = _nextPosition.last[1];
    }

    // Perform a march toward the target row or col at a time
    while (rowNew != rowTarget || colNew != colTarget) {
      int rowError = rowTarget - rowNew;
      int colError = colTarget - colNew;

      // Advance for 1 step in the direction of error
      rowNew += rowError.sign;
      colNew += colError.sign;
      _nextPosition.add([rowNew, colNew]);
    }
  }
}
