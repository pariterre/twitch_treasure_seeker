import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/managers/game_manager.dart';
import 'package:twitch_treasure_seeker/widgets/sweeper_tile.dart';

class GameGrid extends StatelessWidget {
  const GameGrid({super.key, required this.tileSize});

  final double tileSize;

  @override
  Widget build(BuildContext context) {
    final textSize = tileSize * 3 / 4;
    final gm = GameManager.instance;

    return Row(
      children: List.generate(gm.nbCols, (col) {
        return Column(
          children: List.generate(gm.nbRows, (row) {
            return SizedBox(
              width: tileSize,
              height: tileSize,
              child: SweeperTile(
                tileIndex: row * gm.nbCols + col,
                tileSize: tileSize,
                textSize: textSize,
              ),
            );
          }),
        );
      }, growable: false),
    );
  }
}
