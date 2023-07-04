import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_interface.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
import 'package:twitched_minesweeper/screens/idle_room.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  static const route = '/end-screen';

  Widget _buildCongratulation(context, GameInterface mainInterface) {
    final smallPadding = ThemePadding.small(context);

    final titleSize = ThemeSize.title(context);

    final players = mainInterface.gameManager.players;
    final playerWithHighestScore =
        mainInterface.gameManager.playerWithHighestScore;

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
              'Félication à $playerWithHighestScore qui remporte\n'
              'la partie avec ${players[playerWithHighestScore]!.treasures} points',
              style: TextStyle(color: Colors.white, fontSize: titleSize),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainInterface =
        ModalRoute.of(context)!.settings.arguments as GameInterface;

    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final offsetFromBorder = windowHeight * 0.02;

    Future.delayed(const Duration(seconds: 10)).then((_) {
      Navigator.of(context)
          .pushReplacementNamed(IdleRoom.route, arguments: mainInterface);
    });

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
              Positioned(
                  left: offsetFromBorder,
                  top: offsetFromBorder,
                  child: _buildCongratulation(context, mainInterface)),
            ],
          ),
        ),
      ),
    );
  }
}
