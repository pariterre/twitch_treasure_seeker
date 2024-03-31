import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_treasure_seeker/models/game_interface.dart';
import 'package:twitch_treasure_seeker/models/minesweeper_theme.dart';
import 'package:twitch_treasure_seeker/screens/configuration_room.dart';
import 'package:twitch_treasure_seeker/screens/lobby_screen.dart';

class IdleRoom extends StatefulWidget {
  const IdleRoom({super.key});

  static const route = '/idle-room';

  @override
  State<IdleRoom> createState() => _IdleRoomState();
}

class _IdleRoomState extends State<IdleRoom> {
  late final GameInterface _mainInterface;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mainInterface =
        ModalRoute.of(context)!.settings.arguments as GameInterface;
    _mainInterface.gameManager.resetPlayers();
    _mainInterface.onRequestSetupScreen = _onRequestSetupScreen;
    _mainInterface.onRequestLaunchGame = _onRequestLaunchGame;
  }

  void _unregisterCallbacks() {
    _mainInterface.onRequestSetupScreen = null;
    _mainInterface.onRequestLaunchGame = null;
  }

  void _onRequestSetupScreen() async {
    _unregisterCallbacks();
    await _mainInterface.gameManager.setIsGameRunningForTheFirstTime(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(ConfigurationRoom.route,
        arguments: _mainInterface.twitchManager);
  }

  void _onRequestLaunchGame() {
    _unregisterCallbacks();
    Navigator.of(context)
        .pushReplacementNamed(LobbyScreen.route, arguments: _mainInterface);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TwitchDebugOverlay(
        manager: _mainInterface.twitchManager,
        startingPosition: Offset(MediaQuery.of(context).size.width - 300,
            MediaQuery.of(context).size.height / 2 - 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        ),
      ),
    );
  }
}
