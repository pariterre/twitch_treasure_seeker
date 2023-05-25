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

  Widget _buildGameTiles(double tileSize) {
    return SizedBox(
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

  Widget _buildScore() {
    final windowHeight = MediaQuery.of(context).size.height;

    final smallPadding = ThemePadding.small(context);
    final interlinePadding = ThemePadding.interline(context);

    final titleSize = ThemeSize.title(context);
    final textSize = ThemeSize.text(context);

    final players = _mainInterface.gameManager.players;

    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.main,
        borderRadius: BorderRadius.circular(5),
      ),
      height:
          windowHeight * 0.08 + players.length * (textSize + interlinePadding),
      width: windowHeight * 0.40,
      child: Padding(
        padding: EdgeInsets.only(left: smallPadding, top: smallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score',
              style: TextStyle(color: Colors.white, fontSize: titleSize),
            ),
            SizedBox(height: interlinePadding * 2),
            Padding(
              padding: EdgeInsets.only(left: smallPadding, right: smallPadding),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: players.keys.map((name) {
                    final player = _mainInterface.gameManager.players[name]!;
                    return Padding(
                      padding: EdgeInsets.only(bottom: interlinePadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${player.username}:',
                            style: TextStyle(
                                color: Colors.white, fontSize: textSize),
                          ),
                          Text(
                            '${player.score} bleuets (${player.bombs} essais)',
                            style: TextStyle(
                                color: Colors.white, fontSize: textSize),
                          )
                        ],
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
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final offsetFromBorder = windowHeight * 0.02;
    final gridHeight = windowHeight - 2 * offsetFromBorder;

    final tileSize = gridHeight / _mainInterface.gameManager.nbRows;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: Center(
          child: Stack(
            children: [
              SizedBox(
                width: windowWidth,
                height: windowHeight,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: offsetFromBorder, top: offsetFromBorder),
                child: _buildGameTiles(tileSize),
              ),
              Positioned(
                  left: _mainInterface.gameManager.nbCols * tileSize +
                      offsetFromBorder * 2,
                  top: offsetFromBorder,
                  child: _buildScore()),
            ],
          ),
        ),
      ),
    );
  }
}
