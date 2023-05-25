import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/main_interface.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
import 'package:twitched_minesweeper/screens/game_screen.dart';

class RegisterPlayersScreen extends StatefulWidget {
  const RegisterPlayersScreen({super.key});

  static const route = '/register-players';

  @override
  State<RegisterPlayersScreen> createState() => _RegisterPlayersScreenState();
}

class _RegisterPlayersScreenState extends State<RegisterPlayersScreen> {
  late MainInterface _mainInterface;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mainInterface =
        ModalRoute.of(context)!.settings.arguments as MainInterface;
    _mainInterface.onRequestStartPlaying = startPlaying;
    _mainInterface.gameManager.onStateChanged = () => setState(() {});
  }

  void startPlaying() {
    Navigator.of(context)
        .pushReplacementNamed(GameScreen.route, arguments: _mainInterface);
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final smallPadding = ThemePadding.small(context);
    final interlinePadding = ThemePadding.interline(context);

    final titleSize = ThemeSize.title(context);
    final textSize = ThemeSize.text(context);

    final players = _mainInterface.gameManager.players;

    return Scaffold(
      body: Container(
        width: windowWidth,
        height: windowHeight,
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Container(
                  width: windowHeight * 0.45,
                  height: windowHeight * 0.2 +
                      players.length * (textSize + interlinePadding),
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
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Les chercheurs de bleuets (${players.length}/${_mainInterface.gameManager.maxPlayers})',
                              style: TextStyle(
                                  color: Colors.white, fontSize: titleSize),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: interlinePadding * 2,
                                  left: smallPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: players.keys.map<Widget>((name) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: interlinePadding),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: textSize),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Parameters',
                              style: TextStyle(
                                  color: Colors.white, fontSize: titleSize),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: smallPadding,
                                  top: interlinePadding * 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dimension: ${_mainInterface.gameManager.nbRows}x${_mainInterface.gameManager.nbCols}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: textSize),
                                  ),
                                  SizedBox(height: interlinePadding),
                                  Text(
                                    'Essais: ${_mainInterface.gameManager.nbBombs}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: textSize),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
