import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';
import 'package:twitched_minesweeper/widgets/sweeper_tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.gameManager,
  });

  final GameManager gameManager;
  static const route = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    widget.gameManager.onStateChanged = () => setState(() {});
  }

  Widget _buildGameTiles(double availableHeight) {
    final tileSize = availableHeight / widget.gameManager.nbRows;

    return SizedBox(
      height: availableHeight,
      width: widget.gameManager.nbCols * tileSize - 1,
      child: GridView.count(
        crossAxisCount: widget.gameManager.nbCols,
        children: List.generate(
            widget.gameManager.nbRows * widget.gameManager.nbCols, (index) {
          return SweeperTile(
              gameManager: widget.gameManager,
              tileIndex: index,
              tileSize: tileSize);
        }, growable: false),
      ),
    );
  }

  Widget _buildGameControl() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
            onPressed: () {
              widget.gameManager.newGame();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Reset', style: TextStyle(fontSize: 20)),
            ))
      ],
    );
  }

  Widget _buildScore(double height) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 45, 74, 168),
        borderRadius: BorderRadius.circular(5),
      ),
      height: height,
      width: 300,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Score',
              style: TextStyle(color: Colors.white, fontSize: 26),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.gameManager.playersController.players
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              '${e.username}: ${e.score} (${e.bombs} bombs)',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ))
                      .toList()),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const scoreHeight = 180.0;
    final gameHeight =
        MediaQuery.of(context).size.height - 4 * 12 - 60 - scoreHeight;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 255, 0)),
        child: Center(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: _buildGameTiles(gameHeight),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: _buildScore(scoreHeight),
                  )),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildGameControl(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
