import 'package:common/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/managers/game_manager.dart';
import 'package:twitch_treasure_seeker/models/minesweeper_theme.dart';
import 'package:twitch_treasure_seeker/widgets/game_grid.dart';
import 'package:twitch_treasure_seeker/widgets/growing_container.dart';
import 'package:twitch_treasure_seeker/widgets/header.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const route = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _growingTextTime = const Duration(seconds: 1, milliseconds: 500);
  final _fadingTextTime = const Duration(milliseconds: 500);

  final _rewardFoundKey = GlobalKey<GrowingContainerState>();

  @override
  void initState() {
    super.initState();

    final gm = GameManager.instance;
    gm.onGameStarted.listen(_refresh);
    gm.onTileRevealed.listen(_refresh);
    gm.onGameOver.listen(_onGameOver);
  }

// Dispose
  @override
  void dispose() {
    final gm = GameManager.instance;
    gm.onGameStarted.cancel(_refresh);
    gm.onTileRevealed.cancel(_refresh);
    gm.onGameOver.cancel(_onGameOver);

    super.dispose();
  }

  void _refresh() => setState(() {});

  void _onGameOver(bool hasWin) {
    if (hasWin) {
      _rewardFoundKey.currentState!.showMessage('Vous avez gagné');
    } else {
      _rewardFoundKey.currentState!.showMessage('Vous avez perdu');
    }

    Future.delayed(Duration(seconds: 5), () {
      GameManager.instance.resetGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final offsetFromBorder = windowHeight * 0.02;
    final headerHeight = 160.0;
    final gridHeight = windowHeight - 2 * offsetFromBorder - headerHeight;

    final gm = GameManager.instance;
    final tileSize = gridHeight / (gm.nbRows + 1);
    final gridWidth = gm.nbCols * tileSize;

    return Scaffold(
      body: Background(
        backgroundLayer: Opacity(
          opacity: 0.05,
          child: Image.asset(
            'assets/images/train.png',
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            children: [
              Positioned(
                  top: offsetFromBorder,
                  left: 0,
                  right: 0,
                  child: Center(
                      child: SizedBox(
                          height: headerHeight, child: const Header()))),
              Positioned(
                top: offsetFromBorder + headerHeight,
                left: (windowWidth - gridWidth) / 2,
                right: (windowWidth - gridWidth) / 2,
                child: GameGrid(tileSize: tileSize),
              ),
              Positioned(
                left: offsetFromBorder,
                right: windowWidth -
                    ((gm.nbCols + 1.5) * tileSize + 2 * offsetFromBorder),
                top: 0,
                bottom: windowHeight * 1 / 4,
                child: Center(
                    child: GrowingContainer(
                  key: _rewardFoundKey,
                  startingSize: windowHeight * 0.01,
                  finalSize: windowHeight * 0.04,
                  growingTime: _growingTextTime,
                  fadingTime: _fadingTextTime,
                  backgroundColor:
                      gm.hasLost ? ThemeColor.lost : ThemeColor.main,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
