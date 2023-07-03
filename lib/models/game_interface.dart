import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitched_minesweeper/models/game_manager.dart';

enum _Status {
  waitForRequestLaunchGame,
  waitForPlayerToJoin,
  play,
  endGame,
}

class GameInterface {
  late final gameManager = GameManager(onStateChanged: () {
    if (_onStateChanged != null) _onStateChanged!();
  }, onTreasureFound: (player) {
    if (_onTreasureFound != null) _onTreasureFound!(player.username);
  });
  _Status _status = _Status.waitForRequestLaunchGame;

  TwitchManager twitchManager;
  List<String>? _moderators;

  GameInterface({required this.twitchManager}) {
    twitchManager.irc.messageCallback = _messageReceived;
  }

  // This is called when a moderator requested launching the game
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

  // This is called whenever a treasure is found so it can be drawn on the screen
  void Function(String player)? _onTreasureFound;
  set onTreasureFound(Function(String username)? value) =>
      _onTreasureFound = value;

  ///
  /// This is called whenever a message is sent to the chat. Do something
  /// depending on which Status the game is currently
  void _messageReceived(String username, String message) async {
    if (_status == _Status.waitForRequestLaunchGame) {
      return await _checkForLaunchingGameMessage(username, message);
    }

    if (_status == _Status.waitForPlayerToJoin) {
      return await _manageRegistering(message, username);
    }

    if (_status == _Status.play) {
      return await _managePlay(message, username);
    }
  }

  ///
  /// Manage inputs from users during the play time
  Future<void> _managePlay(String message, String username) async {
    // If not a player, do nothing
    if (!gameManager.players.keys.contains(username)) return;

    // Parse the input. It must be of the format : XY, where X is a letter
    // and Y is a number between 0 to 99 (0 beween outside of the grid
    // though).
    final re = RegExp(r'^([a-zA-Z])([0-9]{1,2})$');
    if (!re.hasMatch(message)) return;
    final groups = re.allMatches(message).toList()[0].groups([1, 2]);

    // Reveal the map
    final row = groups[0]!.toLowerCase().codeUnits[0] - 'a'.codeUnits[0];
    final col = int.parse(groups[1]!) - 1;
    gameManager.setPlayerMove(username, row: row, col: col);

    // If the game is over
    if (gameManager.isGameOver) {
      _status = _Status.endGame;
      if (_onGameOver != null) _onGameOver!();
    }
  }

  ///
  /// Manage inputs during registering period (either add a new player or
  /// start the game)
  Future<void> _manageRegistering(String message, String username) async {
    if (message == '!joindre') {
      gameManager.addPlayer(username);
      if (_onStateChanged != null) _onStateChanged!();
      return;
    }

    if (await _isAModerator(username)) {
      if (message == '!start') {
        _status = _Status.play;
        if (_onRequestStartPlaying != null) _onRequestStartPlaying!();
        return;
      }

      _checkForSetParameters(message: message);
    }
  }

  ///
  /// Manage inputs during idle
  Future<void> _checkForLaunchingGameMessage(
      String username, String message) async {
    if (await _isAModerator(username) && message == '!chercheursDeBleuets') {
      _status = _Status.waitForPlayerToJoin;
      if (_onRequestLaunchGame != null) _onRequestLaunchGame!();
    }
  }

  ///
  /// Check if a message contains anything related to setting up the game
  void _checkForSetParameters({required String message}) {
    RegExp re;
    int? maximumPlayers;
    int? nbRows;
    int? nbCols;
    int? maxEnergy;
    int? nbTreasures;
    int? restingTime;
    Duration? gameSpeed;

    re = RegExp(r'^!setMaxPlayers ([0-9]{1,2})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      maximumPlayers = int.parse(groups[0]!);
    }

    re = RegExp(r'^!setRows ([0-9]{1,2})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      nbRows = int.parse(groups[0]!);
    }

    re = RegExp(r'^!setCols ([0-9]{1,2})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      nbCols = int.parse(groups[0]!);
    }

    re = RegExp(r'^!setMaxEnergy ([0-9]{1,2})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      maxEnergy = int.parse(groups[0]!);
    }

    re = RegExp(r'^!setMaxEnergy ([0-9]{1,2})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      nbTreasures = int.parse(groups[0]!);
    }

    re = RegExp(r'^!setRestingTime ([0-9]{1,2})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      nbTreasures = int.parse(groups[0]!);
    }

    re = RegExp(r'^!setGameSpeed ([0-9]{1,4})$');
    if (re.hasMatch(message)) {
      final groups = re.allMatches(message).toList()[0].groups([1]);
      gameSpeed = Duration(milliseconds: int.parse(groups[0]!));
    }

    gameManager.setGameParameters(
      maximumPlayers: maximumPlayers,
      nbRows: nbRows,
      nbCols: nbCols,
      maxEnergy: maxEnergy,
      nbTreasures: nbTreasures,
      restingTime: restingTime,
      gameSpeed: gameSpeed,
    );
    if (_onStateChanged != null) _onStateChanged!();
  }

  ///
  /// Test if the [username] is a moderator of the channel
  Future<bool> _isAModerator(String username) async {
    // In order to reduce time, we assume moderators don't change during a game
    // so only fetch them once.
    if (_moderators == null) {
      _moderators = await twitchManager.api.fetchModerators();
      _moderators!
          .add((await twitchManager.api.login(twitchManager.api.streamerId))!);
    }
    return _moderators!.contains(username);
  }
}
