import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/managers/game_manager.dart';
import 'package:twitch_treasure_seeker/models/enums.dart';
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

  final _treasureFoundKey = GlobalKey<GrowingContainerState>();

  @override
  void initState() {
    super.initState();

    final gm = GameManager.instance;
    gm.onTileRevealed.listen(_onTileRevealed);
    gm.onTreasureFound.listen(_onTreasureFound);
    gm.onGameOver.listen(_onGameOver);
  }

// Dispose
  @override
  void dispose() {
    final gm = GameManager.instance;
    gm.onTileRevealed.cancel(_onTileRevealed);
    gm.onTreasureFound.cancel(_onTreasureFound);
    gm.onGameOver.cancel(_onGameOver);

    super.dispose();
  }

  void _onTileRevealed() => setState(() {});

  void _onTreasureFound(Tile tile) {
    // _treasureFoundKey.currentState!.showMessage('Un bleuet trouvé');
  }

  void _onGameOver(bool hasWin) {
    if (hasWin) {
      _treasureFoundKey.currentState!.showMessage('Vous avez gagné');
    } else {
      _treasureFoundKey.currentState!.showMessage('Vous avez perdu');
    }
    // Navigator.of(context).pushReplacementNamed(EndScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final offsetFromBorder = windowHeight * 0.02;
    final headerHeight = 100.0;
    final gridHeight = windowHeight - 2 * offsetFromBorder - headerHeight;

    final gm = GameManager.instance;
    final tileSize = gridHeight / (gm.nbRows + 1);
    final gridWidth = gm.nbCols * tileSize;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
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
                  key: _treasureFoundKey,
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
