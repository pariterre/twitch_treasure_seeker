import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_app.dart';
import 'package:twitch_treasure_seeker/managers/twitch_manager.dart';
import 'package:twitch_treasure_seeker/models/enums.dart';
import 'package:twitch_treasure_seeker/managers/game_interface.dart';
import 'package:twitch_treasure_seeker/models/minesweeper_theme.dart';
import 'package:twitch_treasure_seeker/screens/end_screen.dart';
import 'package:twitch_treasure_seeker/widgets/game_grid.dart';
import 'package:twitch_treasure_seeker/widgets/game_score.dart';
import 'package:twitch_treasure_seeker/widgets/growing_container.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const route = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _growingTextTime = const Duration(seconds: 1, milliseconds: 500);

  final _fadingTextTime = const Duration(milliseconds: 500);

  final _treasureFoundKey = GlobalKey<GrowingContainerState>();
  final _attackedKey = GlobalKey<GrowingContainerState>();
  final _scoreKey = GlobalKey<GameScoreState>();
  final _gridKey = GlobalKey<GameGridState>();

  final _audioPlayer = AudioPlayer()
    ..play(AssetSource('music_sugar_plum.mp3'), volume: 0.25);

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final gm = GameManager.instance;
    gm.onStateChanged = (needRedraw) {
      if (needRedraw.contains(NeedRedraw.grid)) {
        _gridKey.currentState!.rebuild();
      }

      if (needRedraw.contains(NeedRedraw.score)) {
        _scoreKey.currentState!.rebuild();
      }
    };
    gm.gameLogic.newGame();
    gm.onGameOver = () => _onGameOver();
    gm.onTreasureFound = (username) => _onTreasureFound(username);
    gm.onAttacked = (player, ennemy) => _onAttacked(player, ennemy);
  }

  void _onTreasureFound(String player) => _treasureFoundKey.currentState!
      .showMessage('$player a trouvé\nun bleuet');

  void _onAttacked(String player, String ennemy) => _attackedKey.currentState!
      .showMessage('$ennemy a volé les\nbleuts de $player');

  void _onGameOver() {
    final gm = GameManager.instance;
    gm.onStateChanged = null;
    gm.onGameOver = null;
    gm.onTreasureFound = null;

    Future.delayed(Duration(
        milliseconds:
            _growingTextTime.inMilliseconds + _fadingTextTime.inMilliseconds));
    Navigator.of(context).pushReplacementNamed(EndScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final gl = GameManager.instance.gameLogic;

    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final offsetFromBorder = windowHeight * 0.02;
    final gridHeight = windowHeight - 2 * offsetFromBorder;

    final tileSize = gridHeight / (gl.nbRows + 1);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: Center(
          child: TwitchAppDebugOverlay(
            manager: TwitchManager.instance.manager,
            startingPosition: Offset(MediaQuery.of(context).size.width - 300,
                MediaQuery.of(context).size.height / 2 - 100),
            child: Stack(
              children: [
                SizedBox(
                  width: windowWidth,
                  height: windowHeight,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: offsetFromBorder, top: offsetFromBorder),
                  child: GameGrid(key: _gridKey, tileSize: tileSize),
                ),
                Positioned(
                    left: (gl.nbCols + 1) * tileSize + offsetFromBorder * 2,
                    top: offsetFromBorder + tileSize,
                    child: GameScore(key: _scoreKey)),
                Positioned(
                  left: offsetFromBorder,
                  right: windowWidth -
                      ((gl.nbCols + 1.5) * tileSize + 2 * offsetFromBorder),
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
                      ((gl.nbCols + 1.5) * tileSize + 2 * offsetFromBorder),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
