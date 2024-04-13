import 'dart:math';

import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart' as tm;
import 'package:twitch_treasure_seeker/managers/game_interface.dart';
import 'package:twitch_treasure_seeker/managers/twitch_manager.dart';
import 'package:twitch_treasure_seeker/models/minesweeper_theme.dart';
import 'package:twitch_treasure_seeker/models/player.dart';
import 'package:twitch_treasure_seeker/screens/game_screen.dart';
import 'package:twitch_treasure_seeker/widgets/actor_token.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  static const route = '/lobby-screen';

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  void initState() {
    super.initState();

    final gm = GameManager.instance;
    gm.onRequestStartPlaying = startPlaying;
    gm.onStateChanged = (needRedraw) => setState(() {});
  }

  void startPlaying() {
    final gm = GameManager.instance;
    gm.onStateChanged = null;

    Navigator.of(context).pushReplacementNamed(GameScreen.route);
  }

  Column _buildPlayerList(
    Map<String, Player> players,
  ) {
    final smallPadding = ThemePadding.small(context);
    final interlinePadding = ThemePadding.interline(context);

    final titleSize = ThemeSize.title(context);
    final textSize = ThemeSize.text(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Les chercheurs de bleuets (${players.length}/${GameManager.instance.gameLogic.maxPlayers})',
          style: TextStyle(color: Colors.white, fontSize: titleSize),
        ),
        Padding(
          padding:
              EdgeInsets.only(top: interlinePadding * 2, left: smallPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: players.isEmpty
                ? [
                    Padding(
                      padding: EdgeInsets.only(bottom: interlinePadding),
                      child: Text(
                        'Aucun joueur pour le moment',
                        style:
                            TextStyle(color: Colors.white, fontSize: textSize),
                      ),
                    )
                  ]
                : players.keys.map<Widget>((name) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: interlinePadding),
                      child: Row(
                        children: [
                          ActorToken(
                              actor: players[name]!, tileSize: textSize * 2),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: TextStyle(
                                color: Colors.white, fontSize: textSize),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildParameters() {
    final gl = GameManager.instance.gameLogic;

    final smallPadding = ThemePadding.small(context);
    final interlinePadding = ThemePadding.interline(context);

    final titleSize = ThemeSize.title(context);
    final textSize = ThemeSize.text(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paramètres',
          style: TextStyle(color: Colors.white, fontSize: titleSize),
        ),
        Padding(
          padding:
              EdgeInsets.only(left: smallPadding, top: interlinePadding * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dimension du terrain : ${gl.nbRows}x${gl.nbCols}',
                style: TextStyle(color: Colors.white, fontSize: textSize),
              ),
              SizedBox(height: interlinePadding),
              Text(
                'Nombre d\'essais : ${gl.nbTreasures}',
                style: TextStyle(color: Colors.white, fontSize: textSize),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final smallPadding = ThemePadding.small(context);
    final interlinePadding = ThemePadding.interline(context);

    final textSize = ThemeSize.text(context);

    final players = GameManager.instance.gameLogic.players;

    return Scaffold(
      body: Container(
          width: windowWidth,
          height: windowHeight,
          decoration: const BoxDecoration(color: ThemeColor.greenScreen),
          child: tm.TwitchDebugOverlay(
            manager: TwitchManager.instance.manager,
            startingPosition: Offset(MediaQuery.of(context).size.width - 300,
                MediaQuery.of(context).size.height / 2 - 100),
            child: Center(
              child: Container(
                  width: windowHeight * 0.45,
                  height: windowHeight * 0.22 +
                      max(players.length, 1) *
                          (textSize + 2 * interlinePadding + 6),
                  decoration: const BoxDecoration(color: ThemeColor.main),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: smallPadding,
                        top: smallPadding,
                        bottom: smallPadding * 1.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlayerList(players),
                        _buildParameters(),
                      ],
                    ),
                  )),
            ),
          )),
    );
  }
}
