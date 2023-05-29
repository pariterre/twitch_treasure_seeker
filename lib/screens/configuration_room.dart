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
  final _nbBombsController = TextEditingController();

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
    _nbBombsController.text = _mainInterface.gameManager.nbBombs.toString();
  }

  void _goToIdleRoom() {
    _mainInterface.gameManager.setGameParameters(
      maximumPlayers: int.tryParse(_nbMaxPlayersController.text),
      nbRows: int.tryParse(_nbRowsController.text),
      nbCols: int.tryParse(_nbColsController.text),
      nbBombs: int.tryParse(_nbBombsController.text),
    );

    Navigator.of(context)
        .pushReplacementNamed(IdleRoom.route, arguments: _mainInterface);
  }

  Widget _buildMaxPlayersForm() {
    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Nombre de joueurs maximum :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _nbMaxPlayersController,
            onChanged: (value) => setState(() {
              if (int.tryParse(value) == null) {
                _nbMaxPlayersController.text = "";
              }
            }),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildDimensionsForm() {
    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Dimensions :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        const SizedBox(width: 10),
        Row(
          children: [
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
        ),
      ],
    );
  }

  Widget _buildBombsForm() {
    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Nombre de bombes :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _nbBombsController,
            onChanged: (value) => setState(() {
              if (int.tryParse(value) == null) {
                _nbBombsController.text = "";
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
            height: windowHeight * 0.5,
            width: windowHeight * 0.5,
            decoration: const BoxDecoration(color: ThemeColor.main),
            child: Padding(
              padding: EdgeInsets.only(
                  left: smallPadding,
                  top: smallPadding,
                  bottom: smallPadding * 1.5,
                  right: smallPadding),
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
                          SizedBox(height: 4 * interlinePadding),
                          _buildDimensionsForm(),
                          SizedBox(height: 4 * interlinePadding),
                          _buildBombsForm(),
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
    final windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
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
