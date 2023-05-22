import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/widgets/sweeper_tile.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.nbRows,
    required this.nbCols,
  });

  static const route = '/game-screen';
  final int nbRows;
  final int nbCols;

  @override
  Widget build(BuildContext context) {
    final tileSize = (MediaQuery.of(context).size.height - 2 * 12) / nbRows;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(0, 255, 0, 1)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: nbCols * tileSize,
            child: GridView.count(
              crossAxisCount: nbCols,
              children: List.generate(nbRows * nbCols, (index) {
                return SweeperTile(number: 1, tileSize: tileSize);
              }),
            ),
          ),
        ),
      ),
    );
  }
}
