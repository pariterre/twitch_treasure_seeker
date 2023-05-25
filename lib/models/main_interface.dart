import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/enums.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';

enum _Status {
  waitForRequestLaunchGame,
  waitForPlayerToJoin,
  play,
}

class MainInterface {
  final gameManager = GameManager();
  _Status _status = _Status.waitForRequestLaunchGame;

  // This is called when the moderator requested launching the game
  Function()? onRequestLaunchGame;

  // This is called when the moderator requested to start the game
  Function()? onRequestStartPlaying;

  // This is called when the game is over
  Function()? onGameOver;

  // This is called at each interaction of a user to redraw the map if necessary
  void Function()? onStateChanged;

  // This is called whenever a bomb is found so it can be drawn on the screen
  void Function(String playerName)? onBombFound;

  TwitchManager twitchManager;

  MainInterface({required this.twitchManager}) {
    twitchManager.irc!.messageCallback = _messageReceived;
  }

  bool _isModerator(String username) {
    return username == twitchManager.api.streamerUsername.toLowerCase() ||
        username == twitchManager.api.moderatorUsername.toLowerCase();
  }

  void _messageReceived(String username, String message) {
    if (_status == _Status.waitForRequestLaunchGame) {
      if (_isModerator(username) && message == '!chercheursDeBleuets') {
        _status = _Status.waitForPlayerToJoin;
        if (onRequestLaunchGame != null) onRequestLaunchGame!();
      }
      return;
    }

    if (_status == _Status.waitForPlayerToJoin) {
      if (message == '!joindre') {
        final result = gameManager.addPlayer(username);
        if (onStateChanged != null) onStateChanged!();
      }
      if (_isModerator(username) && message == '!start') {
        _status = _Status.play;
        if (onRequestStartPlaying != null) onRequestStartPlaying!();
      }

      // TODO change parameters of the game
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

        if (result == RevealResult.hit && onBombFound != null) {
          onBombFound!(username);
        }
        if (onStateChanged != null) onStateChanged!();

        // If the game is over, return to initial window
        if (gameManager.isGameOver) {
          _status = _Status.waitForRequestLaunchGame;
          if (onGameOver != null) onGameOver!();
        }
      }
    }
  }
}
