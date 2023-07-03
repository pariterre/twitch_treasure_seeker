import 'package:twitched_minesweeper/models/game_tile.dart';

import 'actors.dart';

class Ennemy extends Actor {
  Ennemy(
      {required super.name, required super.color, required this.restingTime});

  int restingCmp = 0;
  int restingTime;

  bool get shouldChangePosition => restingCmp >= restingTime;

  @override
  void addTarget(GameTile tileTarget) {
    nextPosition.clear();
    super.addTarget(tileTarget);
    restingCmp = 0;
  }

  @override
  bool march() {
    // If it has reached it has not reached its final position
    if (super.march()) return true;

    // Take some rest
    restingCmp++;
    return false;
  }
}
