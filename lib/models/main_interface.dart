import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';

enum _Status {
  waitForRequestGameStart,
  waitForPlayerToJoin,
  play,
}

class MainInterface {
  final gameManager = GameManager();
  _Status _status = _Status.waitForRequestGameStart;

  Function()? onRequestLaunchGame;
  Function()? onRequestStartPlaying;

  TwitchManager twitchManager;

  MainInterface({required this.twitchManager}) {
    twitchManager.irc!.messageCallback = _messageReceived;
  }

  bool _isModerator(String username) {
    return username == twitchManager.api.streamerUsername ||
        username == twitchManager.api.moderatorUsername;
  }

  void _messageReceived(String username, String message) {
    if (_status == _Status.waitForRequestGameStart) {
      if (_isModerator(username) && message == '!trouveBleuet') {
        _status = _Status.waitForPlayerToJoin;
        if (onRequestLaunchGame != null) onRequestLaunchGame!();
      }
      return;
    }

    if (_status == _Status.waitForPlayerToJoin) {
      if (message == '!joindre') {
        gameManager.addPlayer(username);
      }
      if (_isModerator(username) && message == '!start') {
        _status = _Status.play;
        if (onRequestStartPlaying != null) onRequestStartPlaying!();
      }
      return;
    }

    if (_status == _Status.play) {
      if (gameManager.players.keys.contains(username)) {
        // Parse the input. It must be of the format : XY, where X is a letter
        // and Y is a number between 0 to 99 (0 beween outside of the grid
        // though).
        final re = RegExp(r'^([a-zA-Z])([0-9]{1,2})$');
        if (!re.hasMatch(message)) return;
        final groups = re.allMatches(message).toList()[0].groups([1, 2]);

        // Reveal the map
        final row = groups[0]!.toLowerCase().codeUnits[0] - 'a'.codeUnits[0];
        final col = int.parse(groups[1]!) - 1;
        final result = gameManager.revealTile(username, row: row, col: col);
      }
    }
  }
}
