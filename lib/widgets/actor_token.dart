import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/models/actor.dart';

class ActorToken extends StatelessWidget {
  const ActorToken({super.key, required this.tileSize, required this.actor});

  final double tileSize;
  final Actor actor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tileSize * 1 / 2,
      width: tileSize * 1 / 2,
      decoration: BoxDecoration(
          color: actor.color,
          borderRadius: BorderRadius.circular(25),
          border: Border.all()),
    );
  }
}
