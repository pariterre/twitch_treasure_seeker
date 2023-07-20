import 'package:twitched_minesweeper/models/game_manager.dart';
import 'package:twitched_minesweeper/models/game_tile.dart';
import 'package:twitched_minesweeper/models/player.dart';

import 'actor.dart';

class Ennemy extends Actor {
  Ennemy(
      {required super.name, required super.color, required this.restingTime});

  int restingCmp = 0;
  int restingTime;

  int influenceRadius = 0;
  int maxInfluenceRadius = 2;
  int influenceRadiusDelay = 3;
  int influenceRadiusDelayCmp = 0;
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
  bool march(List<GameTile> forbiddenTiles, {GameManager? gameManager}) {
    if (gameManager == null) throw 'gameManager is mandatory';
    bool shouldUpdate = false;

    // If it has reached it has not reached its final position
    if (super.march([])) {
      influenceRadius = influenceRadius > 0 ? influenceRadius - 1 : 0;
      influenceRadiusDelayCmp = 0;
      _updateInfluencedTiles(gameManager);
      return true;
    } else {
      influenceRadiusDelayCmp++;
      if (influenceRadiusDelayCmp >= influenceRadiusDelay &&
          influenceRadius < maxInfluenceRadius) {
        influenceRadiusDelayCmp = 0;
        influenceRadius++;
        _updateInfluencedTiles(gameManager);
        shouldUpdate = true;
      }
    }

    // Take some rest
    restingCmp++;
    return shouldUpdate;
  }

  /// Update the influenced tiles based on current position.
  void _updateInfluencedTiles(GameManager gameManager) {
    influencedTiles.clear();

    for (int row = -influenceRadius; row <= influenceRadius; row++) {
      for (int col = -influenceRadius; col <= influenceRadius; col++) {
        final newTile = GameTile(tile.row + row, tile.col + col);
        if (gameManager.isInsideGrid(newTile)) {
          influencedTiles.add(newTile);
        }
      }
    }
  }
}
