import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/managers/game_interface.dart';
import 'package:twitch_treasure_seeker/models/minesweeper_theme.dart';
import 'package:twitch_treasure_seeker/widgets/actor_token.dart';

class GameScore extends StatefulWidget {
  const GameScore({
    super.key,
    this.title = 'Score',
    this.showEnergy = true,
  });

  final String title;
  final bool showEnergy;

  @override
  State<GameScore> createState() => GameScoreState();
}

class GameScoreState extends State<GameScore> {
  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    final smallPadding = ThemePadding.small(context);
    final interlinePadding = ThemePadding.interline(context);

    final titleSize = ThemeSize.title(context);
    final textSize = ThemeSize.text(context);

    final players = GameManager.instance.gameLogic.players;
    final sortedNames = players.keys.toList();
    sortedNames.sort((a, b) => players[b]!.treasures - players[a]!.treasures);

    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.main,
        borderRadius: BorderRadius.circular(5),
      ),
      height: windowHeight * 0.08 +
          sortedNames.length * (textSize + 2 * interlinePadding + 6),
      width: windowHeight * 0.40,
      child: Padding(
        padding: EdgeInsets.only(left: smallPadding, top: smallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(color: Colors.white, fontSize: titleSize),
            ),
            SizedBox(height: interlinePadding * 2),
            Padding(
              padding: EdgeInsets.only(right: smallPadding),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sortedNames.map((name) {
                    final player =
                        GameManager.instance.gameLogic.players[name]!;
                    return Padding(
                      padding: EdgeInsets.only(bottom: interlinePadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ActorToken(actor: player, tileSize: textSize * 2),
                              const SizedBox(width: 4),
                              Text(
                                player.name,
                                style: TextStyle(
                                    color: Colors.white, fontSize: textSize),
                              ),
                            ],
                          ),
                          Text(
                            '${player.treasures} bleuet${player.treasures < 2 ? ' ' : 's '}${widget.showEnergy ? '(${player.energy} énergies)' : ''}',
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
}
