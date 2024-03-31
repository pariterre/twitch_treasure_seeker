import 'dart:math';

import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_treasure_seeker/models/game_interface.dart';
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
  late GameInterface _mainInterface;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mainInterface =
        ModalRoute.of(context)!.settings.arguments as GameInterface;
    _mainInterface.onRequestStartPlaying = startPlaying;
    _mainInterface.onStateChanged = (needRedraw) => setState(() {});
  }

  void startPlaying() {
    _mainInterface.onStateChanged = null;

    Navigator.of(context)
        .pushReplacementNamed(GameScreen.route, arguments: _mainInterface);
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
          'Les chercheurs de bleuets (${players.length}/${_mainInterface.gameManager.maxPlayers})',
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
                'Dimension du terrain : ${_mainInterface.gameManager.nbRows}x${_mainInterface.gameManager.nbCols}',
                style: TextStyle(color: Colors.white, fontSize: textSize),
              ),
              SizedBox(height: interlinePadding),
              Text(
                'Nombre d\'essais : ${_mainInterface.gameManager.nbTreasures}',
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

    final players = _mainInterface.gameManager.players;

    return Scaffold(
      body: Container(
          width: windowWidth,
          height: windowHeight,
          decoration: const BoxDecoration(color: ThemeColor.greenScreen),
          child: TwitchDebugOverlay(
            manager: _mainInterface.twitchManager,
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
