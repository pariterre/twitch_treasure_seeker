import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/enums.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';

extension TileColor on Tile {
  Color get color {
    switch (this) {
      case Tile.one:
        return const Color.fromARGB(255, 9, 148, 183);
      case Tile.two:
        return const Color.fromARGB(255, 121, 30, 249);
      case Tile.three:
        return Colors.red;
      case Tile.four:
        return const Color.fromARGB(255, 139, 105, 2);
      case Tile.five:
        return Colors.purple;
      case Tile.six:
        return Colors.brown;
      case Tile.seven:
        return const Color.fromARGB(255, 212, 85, 0);
      case Tile.eight:
        return Colors.deepPurple;
      case Tile.bomb:
        return const Color.fromARGB(255, 10, 41, 66);
      default:
        throw 'Wrong color';
    }
  }
}

class SweeperTile extends StatelessWidget {
  const SweeperTile({
    super.key,
    required this.gameManager,
    required this.tileIndex,
    required this.tileSize,
  });

  final GameManager gameManager;
  final int tileIndex;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    final tile = gameManager.tile(tileIndex);
    // index is the number of bomb for the first eight indices
    final nbBombAround = tile.index;
    final textSize = tileSize * 3 / 4;

    return Container(
      decoration: BoxDecoration(
        color:
            tile == Tile.concealed ? ThemeColor.conceiled : ThemeColor.revealed,
        border: Border.all(width: 3),
      ),
      child: tile == Tile.concealed || tile == Tile.zero
          ? null
          : Center(
              child: tile == Tile.bomb
                  ? Text('\u2600',
                      style: TextStyle(fontSize: textSize, color: tile.color))
                  : Text(
                      nbBombAround > 0 ? nbBombAround.toString() : '',
                      style: TextStyle(
                          fontSize: textSize,
                          color: tile.color,
                          fontWeight: FontWeight.bold),
                    )),
    );
  }
}
