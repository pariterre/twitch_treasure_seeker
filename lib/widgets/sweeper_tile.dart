import 'dart:math';

import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/models/enums.dart';
import 'package:twitch_treasure_seeker/managers/game_manager.dart';

extension TileColor on Tile {
  Color get color {
    switch (this) {
      case Tile.one:
        return const Color.fromARGB(255, 89, 171, 191);
      case Tile.two:
        return const Color.fromARGB(255, 30, 139, 249);
      case Tile.three:
        return const Color.fromARGB(255, 171, 161, 235);
      case Tile.four:
        return const Color.fromARGB(255, 139, 105, 2);
      case Tile.five:
        return Colors.purple;
      case Tile.six:
        return Colors.brown;
      case Tile.seven:
        return const Color.fromARGB(255, 212, 85, 0);
      case Tile.eight:
        return Colors.deepPurple;
      case Tile.treasure:
        return const Color.fromARGB(255, 10, 41, 66);
      default:
        return const Color.fromARGB(0, 0, 0, 0);
    }
  }
}

class SweeperTile extends StatelessWidget {
  const SweeperTile({
    super.key,
    required this.tileIndex,
    required this.tileSize,
    required this.textSize,
  });

  final int tileIndex;
  final double tileSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    final gm = GameManager.instance;
    final tile = gm.getTile(tileIndex);

    // index is the number of treasure around the current tile
    final nbTreasuresAround = tile.index;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: tileSize * 0.02),
      ),
      child: GestureDetector(
        onTap: () => gm.revealTile(tileIndex: tileIndex),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                  // border: Border.all(width: tileSize * 0.02),
                  ),
              child: Image.asset(tile == Tile.concealed
                  ? 'assets/grass.png'
                  : 'assets/open_grass.png'),
            ),
            tile == Tile.treasure
                ? const _TreasureTile()
                : Text(
                    nbTreasuresAround > 0 ? nbTreasuresAround.toString() : '',
                    style: TextStyle(
                        fontSize: textSize * 0.65,
                        color: tile.color,
                        fontWeight: FontWeight.bold),
                  ),
          ],
        ),
      ),
    );
  }
}

class _TreasureTile extends StatefulWidget {
  const _TreasureTile();

  @override
  State<_TreasureTile> createState() => _TreasureTileState();
}

class _TreasureTileState extends State<_TreasureTile> {
  double _easeOutExponential(double x) {
    return 1 - (x == 1 ? 1.0 : pow(2, -50 * x).toDouble());
  }

  double _pulsing(double x) {
    return 0.05 * (sin(20 * x) + pi) + (1 - 0.3);
  }

  double _animation(double t) {
    return _easeOutExponential(t) * _pulsing(t);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        duration: const Duration(seconds: 4),
        tween: Tween<double>(begin: 1, end: 0.02),
        builder: (context, value, child) {
          return SizedBox(
              height: _animation(value) * 30,
              width: _animation(value) * 30,
              child: Image.asset('assets/blueberries.png'));
        });
  }
}
