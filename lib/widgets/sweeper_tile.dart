import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/enums.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';

import 'actor_token.dart';

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
      case Tile.treasure:
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
    required this.textSize,
  });

  final GameManager gameManager;
  final int tileIndex;
  final double tileSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    final tile = gameManager.tile(tileIndex);
    final players = gameManager.playersOnTile(tileIndex);
    final ennemies = gameManager.ennemiesOnTile(tileIndex);

    // index is the number of treasure around the current tile
    final nbTreasuresAround = tile.index;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: tile == Tile.starting
              ? null
              : BoxDecoration(
                  color: tile == Tile.concealed
                      ? ThemeColor.conceiled
                      : ThemeColor.revealed,
                  border: Border.all(width: tileSize * 0.02),
                ),
          child: tile == Tile.concealed ||
                  tile == Tile.zero ||
                  tile == Tile.starting
              ? null
              : Center(
                  child: tile == Tile.treasure
                      ? Text(
                          '\u2600',
                          style: TextStyle(
                            fontSize: textSize,
                            color: tile.color,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          nbTreasuresAround > 0
                              ? nbTreasuresAround.toString()
                              : '',
                          style: TextStyle(
                              fontSize: textSize,
                              color: tile.color,
                              fontWeight: FontWeight.bold),
                        )),
        ),
        if (players.isNotEmpty)
          ...players
              .map((player) => ActorToken(tileSize: tileSize, actor: player)),
        // Draw the ennemies and their influence
        ...gameManager.ennemyInfluenceOnTile(tileIndex).map((ennemy) {
          debugPrint(gridTile(tileIndex, gameManager.nbCols).toString());
          return Container(
            decoration: BoxDecoration(color: ennemy.color.withAlpha(50)),
          );
        }),
        if (ennemies.isNotEmpty)
          ...ennemies
              .map((ennemy) => ActorToken(tileSize: tileSize, actor: ennemy)),
      ],
    );
  }
}
