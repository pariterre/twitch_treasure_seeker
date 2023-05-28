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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mainInterface = MainInterface(
        twitchManager:
            ModalRoute.of(context)!.settings.arguments as TwitchManager);
  }

  void _goToIdleRoom() {
    Navigator.of(context)
        .pushReplacementNamed(IdleRoom.route, arguments: _mainInterface);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: ThemeColor.greenScreen),
      child: ElevatedButton(
        onPressed: _goToIdleRoom,
        child: const Text('Start'),
      ),
    );
  }
}
