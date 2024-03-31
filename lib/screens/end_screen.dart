import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_treasure_seeker/models/game_interface.dart';
import 'package:twitch_treasure_seeker/models/minesweeper_theme.dart';
import 'package:twitch_treasure_seeker/screens/idle_room.dart';
import 'package:twitch_treasure_seeker/widgets/game_score.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  static const route = '/end-screen';

  Widget _buildCongratulation(context, GameInterface gameInterface) {
    final smallPadding = ThemePadding.small(context);

    final titleSize = ThemeSize.title(context);

    final players = gameInterface.gameManager.players;
    final playersWithHighestScore =
        gameInterface.gameManager.playersWithHighestScore;
    final nbTreasures = players[playersWithHighestScore[0]]!.treasures;

    var winnerNames = playersWithHighestScore[0];
    if (playersWithHighestScore.length > 1) {
      for (var i = 1; i < playersWithHighestScore.length - 1; i++) {
        winnerNames += ', ${playersWithHighestScore[i]}';
      }
      winnerNames += ' et ${playersWithHighestScore.last}';
    }

    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.main,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: EdgeInsets.all(smallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Félicitation à $winnerNames qui remporte${playersWithHighestScore.length > 1 ? 'nt' : ''}\n'
              'la partie avec $nbTreasures bleuet${nbTreasures < 2 ? '' : 's'}',
              style: TextStyle(color: Colors.white, fontSize: titleSize),
            ),
            GameScore(
              gameInterface: gameInterface,
              title: 'Score final',
              showEnergy: false,
            ),
          ],
        ),
      ),
    );
  }

  void _resetGame(BuildContext context, GameInterface gameInterface) {
    gameInterface.onRequestReset = null;
    Navigator.of(context)
        .pushReplacementNamed(IdleRoom.route, arguments: gameInterface);
  }

  @override
  Widget build(BuildContext context) {
    final gameInterface =
        ModalRoute.of(context)!.settings.arguments as GameInterface;
    gameInterface.onRequestReset = () => _resetGame(context, gameInterface);

    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final offsetFromBorder = windowHeight * 0.02;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: TwitchDebugOverlay(
          manager: gameInterface.twitchManager,
          startingPosition: Offset(MediaQuery.of(context).size.width - 300,
              MediaQuery.of(context).size.height / 2 - 100),
          child: Stack(
            children: [
              SizedBox(
                width: windowWidth,
                height: windowHeight,
              ),
              Positioned(
                  left: offsetFromBorder,
                  top: offsetFromBorder,
                  child: _buildCongratulation(context, gameInterface)),
            ],
          ),
        ),
      ),
    );
  }
}
