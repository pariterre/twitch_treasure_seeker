import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';
import 'package:twitched_minesweeper/models/game_interface.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
import 'package:twitched_minesweeper/screens/end_screen.dart';
import 'package:twitched_minesweeper/widgets/growing_container.dart';
import 'package:twitched_minesweeper/widgets/sweeper_tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const route = '/game-screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameInterface _mainInterface;

  final _growingTextTime = const Duration(seconds: 1, milliseconds: 500);
  final _fadingTextTime = const Duration(milliseconds: 500);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mainInterface =
        ModalRoute.of(context)!.settings.arguments as GameInterface;

    _mainInterface.onStateChanged = () => setState(() {});
    _mainInterface.gameManager.newGame();
    _mainInterface.onGameOver = _onGameOver;
    _mainInterface.onBombFound = _onBombFound;
  }

  String? _currentBombMessage;
  void _onBombFound(String message) {
    setState(() {
      _currentBombMessage = message;
    });

    Future.delayed(Duration(
            milliseconds: _growingTextTime.inMilliseconds +
                _fadingTextTime.inMilliseconds))
        .then((value) {
      if (!mounted) return;
      setState(() {
        _currentBombMessage = null;
      });
    });
  }

  void _onGameOver() {
    _mainInterface.onStateChanged = null;
    _mainInterface.onGameOver = null;
    _mainInterface.onBombFound = null;

    Future.delayed(Duration(
        milliseconds:
            _growingTextTime.inMilliseconds + _fadingTextTime.inMilliseconds));
    Navigator.of(context)
        .pushReplacementNamed(EndScreen.route, arguments: _mainInterface);
  }

  Widget _buildGrid(double tileSize) {
    final textSize = tileSize * 3 / 4;
    final gm = _mainInterface.gameManager;

    return SizedBox(
      width: (gm.nbCols + 1) * tileSize,
      child: GridView.count(
        crossAxisCount: gm.nbCols + 1,
        children: List.generate(
            gm.nbRows * gm.nbCols + gm.nbRows + gm.nbCols + 1, (index) {
          // We have to construct the grid alongside the name of the
          // rows and cols. So every row and col being 0 is the name, otherwise
          // it is the grid (with its index offset by 1)
          final row = gridRow(index, gm.nbCols + 1);
          final col = gridCol(index, gm.nbCols + 1);
          if (row == 0 && col == 0) return Container();
          if (row == 0 || col == 0) {
            return Container(
              decoration: BoxDecoration(
                  color: ThemeColor.conceiledContrast,
                  border: Border.all(width: tileSize * 0.02)),
              child: Center(
                  child: Text(
                '${col == 0 ? String.fromCharCode('A'.codeUnits[0] + row - 1) : col}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: textSize * 0.75, fontWeight: FontWeight.bold),
              )),
            );
          }

          final tileIndex = gridIndex(row - 1, col - 1, gm.nbCols);
          return SweeperTile(
            gameManager: gm,
            tileIndex: tileIndex,
            tileSize: tileSize,
            textSize: textSize,
          );
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
                            player.username,
                            style: TextStyle(
                                color: Colors.white, fontSize: textSize),
                          ),
                          Text(
                            '${player.score} bleuets (${player.bombs} essais)',
                            style: TextStyle(
                                color: Colors.white, fontSize: textSize),
                          ),
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

    final tileSize = gridHeight / (_mainInterface.gameManager.nbRows + 1);

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
                child: _buildGrid(tileSize),
              ),
              Positioned(
                  left: (_mainInterface.gameManager.nbCols + 1) * tileSize +
                      offsetFromBorder * 2,
                  top: offsetFromBorder + tileSize,
                  child: _buildScore()),
              if (_currentBombMessage != null)
                Positioned(
                  left: offsetFromBorder,
                  right: windowWidth -
                      ((_mainInterface.gameManager.nbCols + 1.5) * tileSize +
                          2 * offsetFromBorder),
                  top: 0,
                  bottom: windowHeight * 1 / 4,
                  child: Center(
                      child: GrowingContainer(
                    startingSize: windowHeight * 0.01,
                    finalSize: windowHeight * 0.04,
                    title: _currentBombMessage!,
                    growingTime: _growingTextTime,
                    fadingTime: _fadingTextTime,
                  )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
