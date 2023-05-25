import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/enums.dart';
import 'package:twitched_minesweeper/models/main_interface.dart';
import 'package:twitched_minesweeper/widgets/sweeper_tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const route = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MainInterface _mainInterface;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mainInterface =
        ModalRoute.of(context)!.settings.arguments as MainInterface;

    _mainInterface.gameManager.onStateChanged = () => setState(() {});
    _mainInterface.gameManager.newGame();
  }

  Widget _buildGameTiles(double availableHeight) {
    final tileSize = availableHeight / _mainInterface.gameManager.nbRows;

    return SizedBox(
      height: availableHeight,
      width: _mainInterface.gameManager.nbCols * tileSize - 1,
      child: GridView.count(
        crossAxisCount: _mainInterface.gameManager.nbCols,
        children: List.generate(
            _mainInterface.gameManager.nbRows *
                _mainInterface.gameManager.nbCols, (index) {
          return SweeperTile(
              gameManager: _mainInterface.gameManager,
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
              _mainInterface.gameManager.newGame();
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
        color: ThemeColor.main,
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
                  children: _mainInterface.gameManager.players.keys.map((name) {
                    final player = _mainInterface.gameManager.players[name]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '${player.username}: ${player.score} (${player.bombs} bombs)',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }).toList()),
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
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
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
