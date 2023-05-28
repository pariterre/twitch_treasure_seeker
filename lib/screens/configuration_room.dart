import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/main_interface.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
import 'package:twitched_minesweeper/screens/idle_room.dart';

class ConfigurationRoom extends StatefulWidget {
  const ConfigurationRoom({super.key});

  static const route = '/configuration-room';

  @override
  State<ConfigurationRoom> createState() => _ConfigurationRoomState();
}

class _ConfigurationRoomState extends State<ConfigurationRoom> {
  late final MainInterface _mainInterface;

  final _nbMaxPlayersController = TextEditingController();
  final _nbRowsController = TextEditingController();
  final _nbColsController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mainInterface = MainInterface(
        twitchManager:
            ModalRoute.of(context)!.settings.arguments as TwitchManager);

    // Set default parameters
    _nbMaxPlayersController.text =
        _mainInterface.gameManager.maxPlayers.toString();
    _nbRowsController.text = _mainInterface.gameManager.nbRows.toString();
    _nbColsController.text = _mainInterface.gameManager.nbCols.toString();
  }

  void _goToIdleRoom() {
    Navigator.of(context)
        .pushReplacementNamed(IdleRoom.route, arguments: _mainInterface);
  }

  Widget _buildMaxPlayersForm() {
    final windowHeight = MediaQuery.of(context).size.height;

    return Container(
      width: windowHeight * 0.5,
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: TextField(
        controller: _nbMaxPlayersController,
        onChanged: (value) => setState(() {
          if (int.tryParse(value) == null) {
            _nbMaxPlayersController.text = "";
          }
        }),
        decoration:
            const InputDecoration(labelText: 'Nombre de joueurs maximum'),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildDimensionsForm() {
    final textSize = ThemeSize.text(context);

    return Row(
      children: [
        Text('Dimensions :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        const SizedBox(width: 10),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _nbRowsController,
            onChanged: (value) => setState(() {
              if (int.tryParse(value) == null) {
                _nbRowsController.text = "";
              }
            }),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _nbColsController,
            onChanged: (value) => setState(() {
              if (int.tryParse(value) == null) {
                _nbColsController.text = "";
              }
            }),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildParameters() {
    final windowHeight = MediaQuery.of(context).size.height;

    final smallPadding = ThemePadding.small(context);
    final interlinePadding = ThemePadding.interline(context);

    final titleSize = ThemeSize.title(context);

    return Theme(
      data: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(gapPadding: 100),
          filled: true,
          fillColor: Colors.white,
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
      ),
      child: Center(
        child: Container(
            width: windowHeight * 0.7,
            height: windowHeight * 0.5,
            decoration: const BoxDecoration(color: ThemeColor.main),
            child: Padding(
              padding: EdgeInsets.only(
                  left: smallPadding,
                  top: smallPadding,
                  bottom: smallPadding * 1.5),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parameters',
                      style:
                          TextStyle(color: Colors.white, fontSize: titleSize),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: smallPadding, top: interlinePadding * 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMaxPlayersForm(),
                          SizedBox(height: 2 * interlinePadding),
                          _buildDimensionsForm(),
                          // Text(
                          //   'Dimension du terrain : ${_mainInterface.gameManager.nbRows}x${_mainInterface.gameManager.nbCols}',
                          //   style: TextStyle(
                          //       color: Colors.white, fontSize: textSize),
                          // ),
                          // SizedBox(height: interlinePadding),
                          // Text(
                          //   'Nombre d\'essais : ${_mainInterface.gameManager.nbBombs}',
                          //   style: TextStyle(
                          //       color: Colors.white, fontSize: textSize),
                          // ),
                        ],
                      ),
                    ),
                  ]),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: windowWidth,
        height: windowHeight,
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _buildParameters(),
            ElevatedButton(onPressed: _goToIdleRoom, child: const Text('Start'))
          ],
        ),
      ),
    );
  }
}
