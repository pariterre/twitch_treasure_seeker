import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/managers/game_manager.dart';
import 'package:twitch_treasure_seeker/models/minesweeper_theme.dart';
import 'package:twitch_treasure_seeker/screens/end_screen.dart';
import 'package:twitch_treasure_seeker/widgets/game_grid.dart';
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

  void _onTreasureFound() =>
      _treasureFoundKey.currentState!.showMessage('Un bleuet trouvé');

  void _onGameOver() =>
      Navigator.of(context).pushReplacementNamed(EndScreen.route);

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final offsetFromBorder = windowHeight * 0.02;
    final gridHeight = windowHeight - 2 * offsetFromBorder;

    final gm = GameManager.instance;
    final tileSize = gridHeight / (gm.nbRows + 1);

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
                  backgroundColor: ThemeColor.main,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
