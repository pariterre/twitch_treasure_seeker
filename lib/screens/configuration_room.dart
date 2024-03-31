import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_treasure_seeker/models/game_interface.dart';
import 'package:twitch_treasure_seeker/models/minesweeper_theme.dart';
import 'package:twitch_treasure_seeker/models/twitch_config.dart';
import 'package:twitch_treasure_seeker/screens/idle_room.dart';
import 'package:twitch_treasure_seeker/widgets/are_you_sure_dialog.dart';

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
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_mainInterface == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _initializeMainInterface();
      });
    }
  }

  Future<void> _initializeMainInterface() async {
    final route = ModalRoute.of(context)!;
    if (!mounted) return;

    final twitchManager = route.settings.arguments == null
        ? await _getConnectedTwitchManager(loadPreviousSession: true)
        : route.settings.arguments as TwitchManager;

    _mainInterface = await GameInterface.factory(twitchManager: twitchManager);
    if (mounted && !_mainInterface!.gameManager.isGameRunningForTheFirstTime) {
      Navigator.of(context)
          .pushReplacementNamed(IdleRoom.route, arguments: _mainInterface);
    }

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
    setState(() {});
  }

  Future<void> _reinitializeTwitchConnection() async {
    final manager =
        await _getConnectedTwitchManager(loadPreviousSession: false);
    _mainInterface!.updateTwitchManager(manager);
  }

  Future<TwitchManager> _getConnectedTwitchManager(
      {required bool loadPreviousSession}) async {
    return (await showDialog<TwitchManager>(
      context: context,
      builder: (context) => TwitchAuthenticationDialog(
        isMockActive: false,
        debugPanelOptions: twitchMocker,
        onConnexionEstablished: (manager) => Navigator.pop(context, manager),
        appInfo: twitchAppInfo,
        reload: loadPreviousSession,
      ),
    ))!;
  }

  void _goToIdleRoom() {
    if (int.tryParse(_nbMaxPlayersController.text) == null ||
        int.tryParse(_maxEnergyController.text) == null ||
        int.tryParse(_nbRowsController.text) == null ||
        int.tryParse(_nbColsController.text) == null ||
        int.tryParse(_nbTreasuresController.text) == null ||
        int.tryParse(_restingTimeController.text) == null ||
        int.tryParse(_gameSpeedController.text) == null) return;

    Navigator.of(context)
        .pushReplacementNamed(IdleRoom.route, arguments: _mainInterface);
  }

  void _resetGameParameters() {
    _mainInterface!.gameManager.resetGameParameters();
    _nbMaxPlayersController.text =
        _mainInterface!.gameManager.maxPlayers.toString();
    _nbRowsController.text = _mainInterface!.gameManager.nbRows.toString();
    _nbColsController.text = _mainInterface!.gameManager.nbCols.toString();
    _nbTreasuresController.text =
        _mainInterface!.gameManager.nbTreasures.toString();
    _maxEnergyController.text =
        _mainInterface!.gameManager.maxEnergy.toString();
    _restingTimeController.text =
        _mainInterface!.gameManager.restingTime.toString();
    _gameSpeedController.text =
        _mainInterface!.gameManager.gameSpeed.inMilliseconds.toString();
  }

  Widget _buildMaxPlayersForm() {
    void setMaxPlayers() {
      final value = int.tryParse(_nbMaxPlayersController.text);
      if (value == null) return;
      _mainInterface!.gameManager.setGameParameters(maximumPlayers: value);
    }

    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Nombre de joueurs maximum :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 50,
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) setMaxPlayers();
            },
            child: TextField(
              controller: _nbMaxPlayersController,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaxEnergy() {
    void setMaxEnergy() {
      final value = int.tryParse(_maxEnergyController.text);
      if (value == null) return;
      _mainInterface!.gameManager.setGameParameters(maxEnergy: value);
    }

    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Énergie maximale :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 50,
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) setMaxEnergy();
            },
            child: TextField(
              controller: _maxEnergyController,
              style: const TextStyle(color: Colors.black),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDimensionsForm() {
    void setNbRows() {
      final value = int.tryParse(_nbRowsController.text);
      if (value == null) return;
      _mainInterface!.gameManager.setGameParameters(nbRows: value);
    }

    void setNbCols() {
      final value = int.tryParse(_nbColsController.text);
      if (value == null) return;
      _mainInterface!.gameManager.setGameParameters(nbCols: value);
    }

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
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) setNbRows();
                },
                child: TextField(
                  controller: _nbRowsController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 50,
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) setNbCols();
                },
                child: TextField(
                  controller: _nbColsController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTreasuresForm() {
    void setTeasures() {
      final value = int.tryParse(_nbTreasuresController.text);
      if (value == null) return;
      _mainInterface!.gameManager.setGameParameters(nbTreasures: value);
    }

    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Nombre de bleuets :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 50,
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) setTeasures();
            },
            child: TextField(
              controller: _nbTreasuresController,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestingTimeForm() {
    void setResting() {
      final value = int.tryParse(_restingTimeController.text);
      if (value == null) return;
      _mainInterface!.gameManager.setGameParameters(restingTime: value);
    }

    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Temps de repos minimum :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 50,
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) setResting();
            },
            child: TextField(
              controller: _restingTimeController,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameSpeed() {
    void setGameSpeed() {
      final value = int.tryParse(_gameSpeedController.text);
      if (value == null) return;
      _mainInterface!.gameManager
          .setGameParameters(gameSpeed: Duration(milliseconds: value));
    }

    final textSize = ThemeSize.text(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Vitesse de jeu (ms) :',
            style: TextStyle(color: Colors.white, fontSize: textSize)),
        SizedBox(
          width: 55,
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) setGameSpeed();
            },
            child: TextField(
              controller: _gameSpeedController,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              style: const TextStyle(color: Colors.black),
            ),
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

    return _mainInterface == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
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
                        const SizedBox(height: 24),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: _resetGameParameters,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white),
                              child: const Text(
                                'Remise à zéro',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _goToIdleRoom,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white),
                              child: const Text(
                                'Start',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final answer = await showDialog<bool>(
                                context: context,
                                builder: (context) => const AreYouSureDialog(
                                      title: 'Reconnexion à Twitch',
                                      content:
                                          'Êtes-vous certain de vouloir reconnecter à Twitch?',
                                    ));
                            if (answer == null || !answer) return;

                            _reinitializeTwitchConnection();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: Text('Reconnecter Twitch',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: ThemeSize.text(context))),
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
