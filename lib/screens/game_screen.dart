import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_controller.dart';
import 'package:twitched_minesweeper/widgets/sweeper_tile.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.gameController,
  });

  static const route = '/game-screen';
  final GameController gameController;

  @override
  Widget build(BuildContext context) {
    final tileSize =
        (MediaQuery.of(context).size.height - 2 * 12) / gameController.nbRows;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(0, 255, 0, 1)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: gameController.nbCols * tileSize,
            child: GridView.count(
              crossAxisCount: gameController.nbCols,
              children: List.generate(
                  gameController.nbRows * gameController.nbCols, (index) {
                return SweeperTile(
                    gameController: gameController,
                    tileIndex: index,
                    tileSize: tileSize);
              }, growable: false),
            ),
          ),
        ),
      ),
    );
  }
}
