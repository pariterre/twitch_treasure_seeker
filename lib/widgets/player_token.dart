import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/player.dart';

class PlayerToken extends StatelessWidget {
  const PlayerToken({super.key, required this.tileSize, required this.player});

  final double tileSize;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tileSize * 1 / 2,
      width: tileSize * 1 / 2,
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(25)),
    );
  }
}
