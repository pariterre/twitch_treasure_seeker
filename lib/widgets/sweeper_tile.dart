import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_controller.dart';

List<Color> _tileColors = const [
  Color.fromARGB(255, 9, 148, 183),
  Color.fromARGB(255, 46, 146, 50),
  Colors.red,
  Color.fromARGB(255, 139, 105, 2),
  Colors.purple,
  Colors.brown,
  Color.fromARGB(255, 212, 85, 0),
  Colors.deepPurple,
];

class SweeperTile extends StatelessWidget {
  const SweeperTile({
    super.key,
    required this.gameController,
    required this.tileIndex,
    required this.tileSize,
  });

  final GameController gameController;
  final int tileIndex;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    final nbBombAround = gameController.getTile(tileIndex);
    final textSize = tileSize * 3 / 4;
    final tileValue = gameController.getTile(tileIndex);

    return InkWell(
      onTap: () => gameController.revealTile(tileIndex),
      child: Container(
        decoration: BoxDecoration(
          color: gameController.getTile(tileIndex) > -2
              ? const Color.fromARGB(255, 204, 234, 248)
              : const Color.fromARGB(255, 45, 74, 168),
          border: Border.all(width: 3),
        ),
        child: tileValue > -2 && tileValue != 0
            ? Center(
                child: nbBombAround < 0
                    ? Text('\u2600', style: TextStyle(fontSize: textSize))
                    : Text(
                        nbBombAround > 0 ? nbBombAround.toString() : '',
                        style: TextStyle(
                            fontSize: textSize,
                            color: _tileColors[tileValue - 1],
                            fontWeight: FontWeight.bold),
                      ))
            : null,
      ),
    );
  }
}
