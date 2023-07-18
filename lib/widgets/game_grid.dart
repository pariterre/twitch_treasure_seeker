import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_interface.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';
import 'package:twitched_minesweeper/models/game_tile.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
import 'package:twitched_minesweeper/widgets/sweeper_tile.dart';

class GameGrid extends StatefulWidget {
  const GameGrid({
    super.key,
    required this.gameInterface,
    required this.tileSize,
  });

  final GameInterface gameInterface;
  final double tileSize;

  @override
  State<GameGrid> createState() => GameGridState();
}

class GameGridState extends State<GameGrid> {
  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final textSize = widget.tileSize * 3 / 4;
    final gm = widget.gameInterface.gameManager;

    return SizedBox(
      width:
          (gm.nbCols + 1) * widget.tileSize + 2, // +2 so the overlap a tiny bit
      child: GridView.count(
        crossAxisCount: gm.nbCols + 1,
        children: List.generate(
            gm.nbRows * gm.nbCols + gm.nbRows + gm.nbCols + 1, (index) {
          // We have to construct the grid alongside the header.
          // So every row and col being 0 is the name, otherwise
          // it is the grid (with its index offset by 1)
          final tile = gridTile(index, gm.nbCols + 1);

          // Starting tile
          if (tile.row == 0 && tile.col == 0) {
            return SweeperTile(
              gameManager: gm,
              tileIndex: -1,
              tileSize: widget.tileSize,
              textSize: textSize,
            );
          }

          // Header of SweeperTile
          if (tile.row == 0 || tile.col == 0) {
            return Container(
              decoration: BoxDecoration(
                  color: ThemeColor.conceiledContrast,
                  border: Border.all(width: widget.tileSize * 0.02)),
              child: Center(
                  child: Text(
                '${tile.col == 0 ? String.fromCharCode('A'.codeUnits[0] + tile.row - 1) : tile.col}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: textSize * 0.75, fontWeight: FontWeight.bold),
              )),
            );
          }

          // Draw the actual grid
          final tileIndex =
              gridIndex(GameTile(tile.row - 1, tile.col - 1), gm.nbCols);
          return SweeperTile(
            gameManager: gm,
            tileIndex: tileIndex,
            tileSize: widget.tileSize,
            textSize: textSize,
          );
        }, growable: false),
      ),
    );
  }
}
