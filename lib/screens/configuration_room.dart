import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/game_interface.dart';
import 'package:twitched_minesweeper/models/minesweeper_theme.dart';
import 'package:twitched_minesweeper/screens/idle_room.dart';

class ConfigurationRoom extends StatefulWidget {
  const ConfigurationRoom({super.key});

  static const route = '/configuration-room';

  @override
  State<ConfigurationRoom> createState() => _ConfigurationRoomState();
}

class _ConfigurationRoomState extends State<ConfigurationRoom> {
  GameInterface? _mainInterface;

  final _nbMaxPlayersController = TextEditingController();
  final _maxEnergyController = TextEditingController();
  final _nbRowsController = TextEditingController();
  final _nbColsController = TextEditingController();
  final _nbTreasuresController = TextEditingController();
  final _restingTimeController = TextEditingController();
  final _gameSpeedController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_mainInterface == null) {
      _mainInterface = GameInterface(
          twitchManager:
              ModalRoute.of(context)!.settings.arguments as TwitchManager);
      // Set default parameters
      _nbMaxPlayersController.text =
          _mainInterface!.gameManager.maxPlayers.toString();
      _maxEnergyController.text =
          _mainInterface!.gameManager.maxEnergy.toString();
      _nbRowsController.text = _mainInterface!.gameManager.nbRows.toString();
      _nbColsController.text = _mainInterface!.gameManager.nbCols.toString();
      _nbTreasuresController.text =
          _mainInterface!.gameManager.nbTreasures.toString();
      _restingTimeController.text =
          _mainInterface!.gameManager.restingTime.toString();
      _gameSpeedController.text =
          _mainInterface!.gameManager.gameSpeed.inMilliseconds.toString();
    }
  }

  void _goToIdleRoom() {
    final gameSpeed = int.tryParse(_gameSpeedController.text);

    _mainInterface!.gameManager.setGameParameters(
      maximumPlayers: int.tryParse(_nbMaxPlayersController.text),
      maxEnergy: int.tryParse(_maxEnergyController.text),
      nbRows: int.tryParse(_nbRowsController.text),
      nbCols: int.tryParse(_nbColsController.text),
      nbTreasures: int.tryParse(_nbTreasuresController.text),
      restingTime: int.tryParse(_restingTimeController.text),
      gameSpeed: gameSpeed == null ? null : Duration(milliseconds: gameSpeed),
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
              if (value != '' && int.tryParse(value) == null) {
                _nbMaxPlayersController.text = '';
              }
            }),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildMaxEnergy() {
    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Énergie maximale :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _maxEnergyController,
            onChanged: (value) => setState(() {
              if (value != '' && int.tryParse(value) == null) {
                _maxEnergyController.text = '';
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
                  if (value != '' && int.tryParse(value) == null) {
                    _nbRowsController.text = '';
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
                  if (value != '' && int.tryParse(value) == null) {
                    _nbColsController.text = '';
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

  Widget _buildTreasuresForm() {
    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Nombre de bleuets :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _nbTreasuresController,
            onChanged: (value) => setState(() {
              if (value != '' && int.tryParse(value) == null) {
                _nbTreasuresController.text = '';
              }
            }),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildRestingTimeForm() {
    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Temps de repos minimum :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _restingTimeController,
            onChanged: (value) => setState(() {
              if (value != '' && int.tryParse(value) == null) {
                _restingTimeController.text = '';
              }
            }),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildGameSpeed() {
    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Vitesse de jeu (ms) :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 55,
          child: TextField(
            controller: _gameSpeedController,
            onChanged: (value) => setState(() {
              if (value != '' && int.tryParse(value) == null) {
                _gameSpeedController.text = '';
              }
            }),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildParameters() {
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Parameters',
          style: TextStyle(color: Colors.white, fontSize: titleSize),
        ),
        Container(
          padding:
              EdgeInsets.only(left: smallPadding, top: interlinePadding * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMaxPlayersForm(),
              SizedBox(height: 4 * interlinePadding),
              _buildMaxEnergy(),
              SizedBox(height: 4 * interlinePadding),
              _buildDimensionsForm(),
              SizedBox(height: 4 * interlinePadding),
              _buildTreasuresForm(),
              SizedBox(height: 4 * interlinePadding),
              _buildRestingTimeForm(),
              SizedBox(height: 4 * interlinePadding),
              _buildGameSpeed(),
            ],
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    final smallPadding = ThemePadding.small(context);

    return Scaffold(
      body: Container(
        height: windowHeight,
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: Center(
          child: Container(
            width: windowHeight * 0.5,
            decoration: const BoxDecoration(color: ThemeColor.main),
            child: Padding(
              padding: EdgeInsets.only(
                  left: smallPadding,
                  top: smallPadding,
                  bottom: smallPadding * 1.5,
                  right: smallPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildParameters(),
                  ElevatedButton(
                    onPressed: _goToIdleRoom,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text(
                      'Start',
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
