import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/enums.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';

enum _Status {
  waitForRequestLaunchGame,
  waitForPlayerToJoin,
  play,
  endGame,
}

class MainInterface {
  final gameManager = GameManager();
  _Status _status = _Status.waitForRequestLaunchGame;

  // This is called when the moderator requested launching the game
  Function()? _onRequestLaunchGame;
  set onRequestLaunchGame(Function()? value) {
    _onRequestLaunchGame = value;
    if (value != null) _status = _Status.waitForRequestLaunchGame;
  }

  // This is called when the moderator requested to start the game
  Function()? _onRequestStartPlaying;
  set onRequestStartPlaying(Function()? value) =>
      _onRequestStartPlaying = value;

  // This is called when the game is over
  Function()? _onGameOver;
  set onGameOver(Function()? value) => _onGameOver = value;

  // This is called at each interaction of a user to redraw the map if necessary
  void Function()? _onStateChanged;
  set onStateChanged(Function()? value) => _onStateChanged = value;

  // This is called whenever a bomb is found so it can be drawn on the screen
  void Function(String playerName)? _onBombFound;
  set onBombFound(Function(String playerName)? value) => _onBombFound = value;

  void _checkForSetParameters({required String message}) {
    RegExp re;

    re = RegExp(r'^!setMaxPlayers ([0-9]{1,2})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      gameManager.setGameParameters(maximumPlayers: int.parse(groups[0]!));
      if (_onStateChanged != null) _onStateChanged!();
      return;
    }

    re = RegExp(r'^!setRows ([0-9]{1,2})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      gameManager.setGameParameters(nbRows: int.parse(groups[0]!));
      if (_onStateChanged != null) _onStateChanged!();
      return;
    }

    re = RegExp(r'^!setCols ([0-9]{1,2})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      gameManager.setGameParameters(nbCols: int.parse(groups[0]!));
      if (_onStateChanged != null) _onStateChanged!();
      return;
    }

    re = RegExp(r'^!setBombs ([0-9]{1,2})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      gameManager.setGameParameters(nbBombs: int.parse(groups[0]!));
      if (_onStateChanged != null) _onStateChanged!();
      return;
    }
  }

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
        if (_onRequestLaunchGame != null) _onRequestLaunchGame!();
      }
      return;
    }

    if (_status == _Status.waitForPlayerToJoin) {
      if (message == '!joindre') {
        gameManager.addPlayer(username);
        if (_onStateChanged != null) _onStateChanged!();
        return;
      }

      if (_isModerator(username)) {
        if (message == '!start') {
          _status = _Status.play;
          if (_onRequestStartPlaying != null) _onRequestStartPlaying!();
          return;
        }

        _checkForSetParameters(message: message);
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

        if (result == RevealResult.hit && _onBombFound != null) {
          _onBombFound!(username);
        }
        if (_onStateChanged != null) _onStateChanged!();

        // If the game is over
        if (gameManager.isGameOver) {
          _status = _Status.endGame;
          if (_onGameOver != null) _onGameOver!();
        }
      }
    }
  }
}
