import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';
import 'package:twitched_minesweeper/screens/game_screen.dart';

class RegisterPlayersScreen extends StatefulWidget {
  const RegisterPlayersScreen({
    super.key,
    required this.gameManager,
  });

  final GameManager gameManager;
  static const route = '/register-players';

  @override
  State<RegisterPlayersScreen> createState() => _RegisterPlayersScreenState();
}

class _RegisterPlayersScreenState extends State<RegisterPlayersScreen> {
  @override
  void initState() {
    super.initState();
    widget.gameManager.playersController.onStateChanged = () => setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 255, 0)),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Container(
                  width: 300,
                  height: 500,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 45, 74, 168)),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 40.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'The minesweepers',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 26),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, left: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    widget.gameManager.playersController.players
                                        .map<Widget>((e) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Text(
                                                e.username,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ))
                                        .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 500 / 2 + 10, left: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Parameters',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 26),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, top: 10, bottom: 4.0),
                                  child: Text(
                                    'Dimension: ${widget.gameManager.nbRows}x${widget.gameManager.nbCols}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, bottom: 4.0),
                                  child: Text(
                                    'Bombs: ${widget.gameManager.nbBombs}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(GameScreen.route),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Start',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
