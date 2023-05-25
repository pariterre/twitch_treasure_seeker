import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/main_interface.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
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

  Widget _buildScore(double height) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.main,
        borderRadius: BorderRadius.circular(5),
      ),
      height: height,
      width: 300,
      child: Padding(
        padding: EdgeInsets.only(
            left: ThemePadding.small(context),
            top: ThemePadding.small(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score',
              style: TextStyle(
                  color: Colors.white, fontSize: ThemeSize.title(context)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: ThemePadding.small(context)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _mainInterface.gameManager.players.keys.map((name) {
                    final player = _mainInterface.gameManager.players[name]!;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: ThemePadding.interline(context)),
                      child: Text(
                        '${player.username}: ${player.score} (${player.bombs} bombs)',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ThemeSize.text(context)),
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
    const offsetFromTop = 25.0;
    const scoreHeight = 250.0;
    final gameHeight = MediaQuery.of(context).size.height - 2 * offsetFromTop;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: Center(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
              Padding(
                padding: const EdgeInsets.only(top: offsetFromTop),
                child: _buildGameTiles(gameHeight),
              ),
              Positioned(
                  left: 0, top: offsetFromTop, child: _buildScore(scoreHeight)),
            ],
          ),
        ),
      ),
    );
  }
}
