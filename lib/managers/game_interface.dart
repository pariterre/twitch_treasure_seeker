import 'package:twitch_treasure_seeker/models/game_logic.dart';
import 'package:twitch_treasure_seeker/managers/twitch_manager.dart';
import 'package:twitch_treasure_seeker/models/enums.dart';
import 'package:twitch_treasure_seeker/models/game_tile.dart';

enum _Status {
  waitForRequestLaunchGame,
  waitForPlayerToJoin,
  play,
  endGame,
}

class GameManager {
  GameLogic? _gameLogic;
  GameLogic get gameLogic => _gameLogic!;
  _Status _status = _Status.waitForRequestLaunchGame;

  void updateTwitchManager() {
    TwitchManager.instance.manager?.chat.onMessageReceived
        .startListening(_messageReceived);
  }

  List<String>? _moderators;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  Future<void> initialize() async {
    updateTwitchManager();

    _gameLogic = await GameLogic.factory(
        needRedrawCallback: (needRedraw) {
          if (_onStateChanged != null) _onStateChanged!(needRedraw);
        },
        onTreasureFound: (player) {
          if (_onTreasureFound != null) _onTreasureFound!(player.name);
        },
        onAttacked: (player, ennemy) => _onAttacked!(player.name, ennemy.name),
        onGameOver: () {
          _status = _Status.endGame;
          if (_onGameOver != null) _onGameOver!();
        });

    _isInitialized = true;
  }

  // Prepare the singleton
  static final GameManager _singleton = GameManager._();
  static GameManager get instance => _singleton;
  GameManager._();

  // This is called when a moderator requested launching the game
  Function()? _onRequestLaunchGame;
  set onRequestLaunchGame(Function()? value) {
    _onRequestLaunchGame = value;
    if (value != null) _status = _Status.waitForRequestLaunchGame;
  }

  // This is called when a moderator requested setup screen
  Function()? _onRequestSetupScreen;
  set onRequestSetupScreen(Function()? value) => _onRequestSetupScreen = value;

  // This is called when the moderator requested to start the game
  Function()? _onRequestStartPlaying;
  set onRequestStartPlaying(Function()? value) =>
      _onRequestStartPlaying = value;

  Function()? _onRequestReset;
  set onRequestReset(Function()? value) => _onRequestReset = value;

  // This is called when the game is over
  Function()? _onGameOver;
  set onGameOver(Function()? value) => _onGameOver = value;

  // This is called at each interaction of a user to redraw the map if necessary
  void Function(List<NeedRedraw>)? _onStateChanged;
  set onStateChanged(Function(List<NeedRedraw>)? value) =>
      _onStateChanged = value;

  // This is called whenever a treasure is found so it can be drawn on the screen
  void Function(String player)? _onTreasureFound;
  set onTreasureFound(Function(String username)? value) =>
      _onTreasureFound = value;

// This is called whenever a treasure is found so it can be drawn on the screen
  void Function(String player, String ennemy)? _onAttacked;
  set onAttacked(Function(String, String)? value) => _onAttacked = value;

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

    if (_status == _Status.endGame) {
      return await _manageEnd(message, username);
    }
  }

  ///
  /// Manage inputs from users during the play time
  Future<void> _managePlay(String message, String username) async {
    // Force end of game if asked
    if (await _isAModerator(username) && message == '!stop') {
      gameLogic.forceGameOver();
      return;
    }

    // If not a player, do nothing
    if (!gameLogic.players.keys.contains(username)) return;

    // Parse the input. It must be of the format : XY, where X is a letter
    // and Y is a number between 0 to 99 (0 beween outside of the grid
    // though).
    final re = RegExp(r'^([a-zA-Z])([0-9]{1,2})$');
    if (!re.hasMatch(message)) return;
    final groups = re.allMatches(message).toList()[0].groups([1, 2]);

    // Reveal the map
    final row = int.parse(groups[1]!) - 1;
    final col = groups[0]!.toLowerCase().codeUnits[0] - 'a'.codeUnits[0];
    gameLogic.setPlayerMove(username, newTile: GameTile(row, col));
  }

  ///
  /// Manage inputs from users during the play time
  Future<void> _manageEnd(String message, String username) async {
    // Reset game
    if (await _isAModerator(username) && message == '!reset') {
      if (_onRequestReset != null) _onRequestReset!();
      return;
    }
  }

  ///
  /// Manage inputs during registering period (either add a new player or
  /// start the game)
  Future<void> _manageRegistering(String message, String username) async {
    if (message == '!joindre') {
      gameLogic.addPlayer(username);
      if (_onStateChanged != null) _onStateChanged!([NeedRedraw.playerList]);
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
    if (await _isAModerator(username)) {
      if (message == '!chercheursDeBleuets') {
        _status = _Status.waitForPlayerToJoin;
        if (_onRequestLaunchGame != null) _onRequestLaunchGame!();
      }

      if (message == '!setup') {
        if (_onRequestSetupScreen != null) _onRequestSetupScreen!();
      }
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

    gameLogic.setGameParameters(
      maximumPlayers: maximumPlayers,
      nbRows: nbRows,
      nbCols: nbCols,
      maxEnergy: maxEnergy,
      nbTreasures: nbTreasures,
      restingTime: restingTime,
      gameSpeed: gameSpeed,
    );
    if (_onStateChanged != null) {
      _onStateChanged!([NeedRedraw.grid, NeedRedraw.score]);
    }
  }

  ///
  /// Test if the [username] is a moderator of the channel
  Future<bool> _isAModerator(String username) async {
    // In order to reduce time, we assume moderators don't change during a game
    // so only fetch them once.
    _moderators ??= await TwitchManager.instance.manager?.api
        .fetchModerators(includeStreamer: true);
    return _moderators!.contains(username);
  }
}
