import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_controller.dart';
import 'package:twitched_minesweeper/widgets/sweeper_tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
  });

  final int nbRows = 20;
  final int nbCols = 10;
  final int nbBombs = 20;

  static const route = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final gameController = GameController(
      nbRows: widget.nbRows, nbCols: widget.nbCols, nbBombs: widget.nbBombs);

  @override
  void initState() {
    super.initState();
    gameController.mainWindowSetState = setState;
  }

  Widget _buildGameTiles(double availableHeight) {
    final tileSize = availableHeight / gameController.nbRows;

    return SizedBox(
      height: availableHeight,
      width: gameController.nbCols * tileSize - 1,
      child: GridView.count(
        crossAxisCount: gameController.nbCols,
        children: List.generate(gameController.nbRows * gameController.nbCols,
            (index) {
          return SweeperTile(
              gameController: gameController,
              tileIndex: index,
              tileSize: tileSize);
        }, growable: false),
      ),
    );
  }

  Widget _buildGameControl() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
              onPressed: () {
                gameController.reset();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Reset', style: TextStyle(fontSize: 20)),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameHeight = MediaQuery.of(context).size.height - 2 * 12 - 100;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(0, 255, 0, 1)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGameTiles(gameHeight),
              _buildGameControl(),
            ],
          ),
        ),
      ),
    );
  }
}
