import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/enums.dart';
import 'package:twitched_minesweeper/models/game_interface.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
import 'package:twitched_minesweeper/screens/end_screen.dart';
import 'package:twitched_minesweeper/widgets/game_grid.dart';
import 'package:twitched_minesweeper/widgets/game_score.dart';
import 'package:twitched_minesweeper/widgets/growing_container.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const route = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _growingTextTime = const Duration(seconds: 1, milliseconds: 500);

  final _fadingTextTime = const Duration(milliseconds: 500);

  GameInterface? _gameInterface;
  final _treasureFoundKey = GlobalKey<GrowingContainerState>();
  final _attackedKey = GlobalKey<GrowingContainerState>();
  final _scoreKey = GlobalKey<GameScoreState>();
  final _gridKey = GlobalKey<GameGridState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_gameInterface == null) {
      _gameInterface =
          ModalRoute.of(context)!.settings.arguments as GameInterface;
      _gameInterface!.onStateChanged = (needRedraw) {
        if (needRedraw.contains(NeedRedraw.grid)) {
          _gridKey.currentState!.rebuild();
        }
        if (needRedraw.contains(NeedRedraw.score)) {
          _scoreKey.currentState!.rebuild();
        }
      };
      _gameInterface!.gameManager.newGame();
      _gameInterface!.onGameOver = () => _onGameOver();
      _gameInterface!.onTreasureFound =
          (username) => _onTreasureFound(username);
      _gameInterface!.onAttacked =
          (player, ennemy) => _onAttacked(player, ennemy);
    }
  }

  void _onTreasureFound(String player) => _treasureFoundKey.currentState!
      .showMessage('$player a trouvé\nun bleuet');

  void _onAttacked(String player, String ennemy) => _attackedKey.currentState!
      .showMessage('$ennemy a volé les\nbleuts de $player');

  void _onGameOver() {
    _gameInterface!.onStateChanged = null;
    _gameInterface!.onGameOver = null;
    _gameInterface!.onTreasureFound = null;

    Future.delayed(Duration(
        milliseconds:
            _growingTextTime.inMilliseconds + _fadingTextTime.inMilliseconds));
    Navigator.of(context)
        .pushReplacementNamed(EndScreen.route, arguments: _gameInterface);
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final offsetFromBorder = windowHeight * 0.02;
    final gridHeight = windowHeight - 2 * offsetFromBorder;

    final tileSize = gridHeight / (_gameInterface!.gameManager.nbRows + 1);

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
                    key: _gridKey,
                    gameInterface: _gameInterface!,
                    tileSize: tileSize),
              ),
              Positioned(
                  left: (_gameInterface!.gameManager.nbCols + 1) * tileSize +
                      offsetFromBorder * 2,
                  top: offsetFromBorder + tileSize,
                  child: GameScore(
                      key: _scoreKey, gameInterface: _gameInterface!)),
              Positioned(
                left: offsetFromBorder,
                right: windowWidth -
                    ((_gameInterface!.gameManager.nbCols + 1.5) * tileSize +
                        2 * offsetFromBorder),
                top: 0,
                bottom: windowHeight * 1 / 4,
                child: Center(
                    child: GrowingContainer(
                  key: _treasureFoundKey,
                  startingSize: windowHeight * 0.01,
                  finalSize: windowHeight * 0.04,
                  growingTime: _growingTextTime,
                  fadingTime: _fadingTextTime,
                  backgroundColor: ThemeColor.main,
                )),
              ),
              Positioned(
                left: offsetFromBorder,
                right: windowWidth -
                    ((_gameInterface!.gameManager.nbCols + 1.5) * tileSize +
                        2 * offsetFromBorder),
                top: 0,
                bottom: windowHeight * 1 / 2,
                child: Center(
                    child: GrowingContainer(
                  key: _attackedKey,
                  startingSize: windowHeight * 0.01,
                  finalSize: windowHeight * 0.04,
                  growingTime: _growingTextTime,
                  fadingTime: _fadingTextTime,
                  backgroundColor: Colors.red,
                )),
              ),
              TwitchDebugPanel(
                  manager: _gameInterface!.twitchManager,
                  startingPosition: Offset(
                      MediaQuery.of(context).size.width - 300,
                      MediaQuery.of(context).size.height / 2 - 100)),
            ],
          ),
        ),
      ),
    );
  }
}
