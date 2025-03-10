import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/managers/game_manager.dart';
import 'package:twitch_treasure_seeker/models/game_tile.dart';
import 'package:twitch_treasure_seeker/widgets/sweeper_tile.dart';

class GameGrid extends StatelessWidget {
  const GameGrid({super.key, required this.tileSize});

  final double tileSize;

  @override
  Widget build(BuildContext context) {
    final textSize = tileSize * 3 / 4;
    final gm = GameManager.instance;

    return SizedBox(
      width: gm.nbCols * tileSize + 2, // +2 so the overlap a tiny bit
      child: GridView.count(
        crossAxisCount: gm.nbCols,
        children: List.generate(gm.nbRows * gm.nbCols, (index) {
          // We have to construct the grid alongside the header.
          // So every row and col being 0 is the name, otherwise
          // it is the grid (with its index offset by 1)
          final tile = toGridTile(index, gm.nbCols);

          // Draw the actual grid
          final tileIndex =
              toGridIndex(GameTile(tile.row, tile.col), gm.nbCols);
          return SweeperTile(
            tileIndex: tileIndex,
            tileSize: tileSize,
            textSize: textSize,
          );
        }, growable: false),
      ),
    );
  }
}
