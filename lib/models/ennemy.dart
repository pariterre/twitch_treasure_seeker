import 'package:twitched_minesweeper/models/game_manager.dart';
import 'package:twitched_minesweeper/models/game_tile.dart';
import 'package:twitched_minesweeper/models/player.dart';

import 'actor.dart';

class Ennemy extends Actor {
  Ennemy(
      {required super.name, required super.color, required this.restingTime});

  int restingCmp = 0;
  int restingTime;
  List<GameTile> influencedTiles = [];
  List<Player> hasAttacked = [];

  bool get shouldChangePosition => restingCmp >= restingTime;

  bool attack(Player player) {
    if (!influencedTiles.contains(player.tile) ||
        hasAttacked.contains(player)) {
      return false;
    }

    // Remove half of the treasures
    player.treasures = player.treasures ~/ 2;

    // Make sure to not attack twice
    hasAttacked.add(player);
    return true;
  }

  @override
  void addTarget(GameTile tileTarget) {
    nextPosition.clear();
    hasAttacked.clear();
    super.addTarget(tileTarget);
    restingCmp = 0;
  }

  @override
  bool march({GameManager? gameManager}) {
    if (gameManager == null) throw 'gameManager is mandatory';

    // If it has reached it has not reached its final position
    if (super.march()) {
      _updateInfluencedTiles(gameManager);
      return true;
    }

    // Take some rest
    restingCmp++;
    return false;
  }

  /// Update the influenced tiles based on current position.
  void _updateInfluencedTiles(GameManager gameManager) {
    influencedTiles.clear();

    for (final row in [-1, 0, 1]) {
      for (final col in [-1, 0, 1]) {
        final newTile = GameTile(tile.row + row, tile.col + col);
        if (gameManager.isInsideGrid(newTile)) {
          influencedTiles.add(newTile);
        }
      }
    }
  }
}
