import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/enums.dart';
import 'package:twitched_minesweeper/models/game_interface.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
import 'package:twitched_minesweeper/screens/end_screen.dart';
import 'package:twitched_minesweeper/widgets/game_grid.dart';
import 'package:twitched_minesweeper/widgets/game_score.dart';
import 'package:twitched_minesweeper/widgets/growing_container.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  static const route = '/game-screen';

  final _growingTextTime = const Duration(seconds: 1, milliseconds: 500);
  final _fadingTextTime = const Duration(milliseconds: 500);

  void _onTreasureFound(
      String username, GlobalKey<GrowingContainerState> growingKey) {
    growingKey.currentState!.showMessage('$username a trouvé\nun bleuet');
  }

  void _onGameOver(BuildContext context, GameInterface gameInterface) {
    gameInterface.onStateChanged = null;
    gameInterface.onGameOver = null;
    gameInterface.onTreasureFound = null;

    Future.delayed(Duration(
        milliseconds:
            _growingTextTime.inMilliseconds + _fadingTextTime.inMilliseconds));
    Navigator.of(context)
        .pushReplacementNamed(EndScreen.route, arguments: gameInterface);
  }

  @override
  Widget build(BuildContext context) {
    final congratulationMessageKey = GlobalKey<GrowingContainerState>();
    final scoreKey = GlobalKey<GameScoreState>();
    final gridKey = GlobalKey<GameGridState>();

    late final gameInterface =
        ModalRoute.of(context)!.settings.arguments as GameInterface;
    gameInterface.onStateChanged = (needRedraw) {
      if (needRedraw.contains(NeedRedraw.grid)) {
        gridKey.currentState!.rebuild();
      }
      if (needRedraw.contains(NeedRedraw.score)) {
        scoreKey.currentState!.rebuild();
      }
    };
    gameInterface.gameManager.newGame();
    gameInterface.onGameOver = () => _onGameOver(context, gameInterface);
    gameInterface.onTreasureFound =
        (username) => _onTreasureFound(username, congratulationMessageKey);

    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final offsetFromBorder = windowHeight * 0.02;
    final gridHeight = windowHeight - 2 * offsetFromBorder;

    final tileSize = gridHeight / (gameInterface.gameManager.nbRows + 1);

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
                child: GameGrid(
                    key: gridKey,
                    gameInterface: gameInterface,
                    tileSize: tileSize),
              ),
              Positioned(
                  left: (gameInterface.gameManager.nbCols + 1) * tileSize +
                      offsetFromBorder * 2,
                  top: offsetFromBorder + tileSize,
                  child:
                      GameScore(key: scoreKey, gameInterface: gameInterface)),
              Positioned(
                left: offsetFromBorder,
                right: windowWidth -
                    ((gameInterface.gameManager.nbCols + 1.5) * tileSize +
                        2 * offsetFromBorder),
                top: 0,
                bottom: windowHeight * 1 / 4,
                child: Center(
                    child: GrowingContainer(
                  key: congratulationMessageKey,
                  startingSize: windowHeight * 0.01,
                  finalSize: windowHeight * 0.04,
                  growingTime: _growingTextTime,
                  fadingTime: _fadingTextTime,
                )),
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child:
                        TwitchDebugPanel(manager: gameInterface.twitchManager),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
