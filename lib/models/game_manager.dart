import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ennemy.dart';
import 'enums.dart';
import 'game_tile.dart';
import 'player.dart';

const List<Color> colorCycle = [
  Colors.purple,
  Colors.cyan,
  Colors.orange,
  Colors.pink,
  Colors.indigo,
  Colors.blueGrey,
  Colors.black,
  Colors.red,
  Colors.brown,
  Colors.blue,
];

///
/// Easy accessors translating index into row/col pair or row/col pair into
/// index
int gridIndex(GameTile tile, int nbCols) => tile.row * nbCols + tile.col;
// int gridRow(int index, int nbCols) => index < 0 ? -1 : index ~/ nbCols;
// int gridCol(int index, int nbCols) => index < 0 ? -1 : index % nbCols;
GameTile gridTile(int index, int nbCols) =>
    GameTile(index < 0 ? -1 : index ~/ nbCols, index < 0 ? -1 : index % nbCols);

class GameManager {
  bool _isFirstTime = true; // If it is the first time the game is run
  Future<void> setIsGameRunningForTheFirstTime(bool value) async {
    _isFirstTime = value;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstTime', _isFirstTime);
  }

  bool get isGameRunningForTheFirstTime => _isFirstTime;

  var _status = GameStatus.initial;
  final Function(List<NeedRedraw>) needRedrawCallback;
  final Function(Player) onTreasureFound;
  final Function(Player, Ennemy) onAttacked;
  final Function() onGameOver;

  // speed a which each movements are triggered
  final Duration _defaultGameSpeed = const Duration(milliseconds: 500);
  late Duration _gameSpeed = _defaultGameSpeed;
  Duration get gameSpeed => _gameSpeed;

  // Maximum number of players allowed to play
  final int _defaultMaxPlayers = 10;
  late int _maxPlayers = _defaultMaxPlayers;
  int get maxPlayers => _maxPlayers;
  final Map<String, Player> _players = {};
  final Map<String, Ennemy> _ennemies = {};

  // Size of the grid
  final int _defaultNbRows = 20;
  late int _nbRows = _defaultNbRows;
  int get nbRows => _nbRows;

  final int _defaultNbCols = 10;
  late int _nbCols = _defaultNbCols;
  int get nbCols => _nbCols;

  // Number of treasures on the grid
  final int _defaultNbTreasures = 40;
  late int _nbTreasures = _defaultNbTreasures;
  int get nbTreasures => _nbTreasures;

  // The actual grid
  List<int> _grid = [];
  List<bool> _isRevealed = [];

  // The player stored by username
  Map<String, Player> get players => _players;

  final int _defaultMaxEnergy = 8;
  late int _maxEnergy = _defaultMaxEnergy;
  int get maxEnergy => _maxEnergy;

  final int _defaultRestingTime = 2;
  late int _restingTime = _defaultRestingTime;
  int get restingTime => _restingTime;

  final int _rabbitRestingTime = 20;

  // If the game is still open for registration
  bool _canRegister = true;
  void closeRegistration() => _canRegister = false;

  static Future<GameManager> factory({
    required Function(List<NeedRedraw>) needRedrawCallback,
    required Function(Player) onTreasureFound,
    required Function(Player, Ennemy) onAttacked,
    required Function() onGameOver,
  }) async {
    final manager = GameManager._(
        needRedrawCallback: needRedrawCallback,
        onTreasureFound: onTreasureFound,
        onAttacked: onAttacked,
        onGameOver: onGameOver);

    await manager._loadGameParameters();
    return manager;
  }

  GameManager._({
    required this.needRedrawCallback,
    required this.onTreasureFound,
    required this.onAttacked,
    required this.onGameOver,
  }) {
    _generateGrid();
    _startGameLoopTimer();
  }

  ///
  /// Reset the players
  void resetPlayers() => _players.clear();

  ///
  /// Set the game parameters
  Future<void> setGameParameters({
    int? maximumPlayers,
    int? nbRows,
    int? nbCols,
    int? nbTreasures,
    int? maxEnergy,
    int? restingTime,
    Duration? gameSpeed,
  }) async {
    maximumPlayers = maximumPlayers ?? _maxPlayers;
    nbRows = nbRows ?? _nbRows;
    nbCols = nbCols ?? _nbCols;
    nbTreasures = nbTreasures ?? _nbTreasures;
    maxEnergy = maxEnergy ?? _maxEnergy;
    restingTime = restingTime ?? _restingTime;
    gameSpeed = gameSpeed ?? _gameSpeed;

    if (maximumPlayers < 1 || maximumPlayers > colorCycle.length) {
      throw 'Maximum number of players must be between 1 to ${colorCycle.length}';
    }
    if (nbRows < 1) {
      throw 'Number of rows must be greater or equal to 1';
    }
    if (nbCols < 1) {
      throw 'Number of cols must be greater or equal to 1';
    }
    if (nbTreasures < 1) {
      throw 'Number of treasures must be greater or equal to 1';
    }
    if (maxEnergy < 1) {
      throw 'Number of energy must be greater or equal to 1';
    }
    if (restingTime < 1) {
      throw 'Resting time must be greater or equal to 1';
    }

    if (_nbTreasures > _nbRows * _nbCols) {
      throw 'Too many treasures for the number of tiles';
    }

    if (gameSpeed.inSeconds < 0) {
      throw 'gameSpeed must be a Duration longer than zero';
    }

    _maxPlayers = maximumPlayers;
    _nbRows = nbRows;
    _nbCols = nbCols;
    _nbTreasures = nbTreasures;
    _maxEnergy = maxEnergy;
    _restingTime = restingTime;
    _gameSpeed = gameSpeed;

    await _saveGameParameters();
  }

  Future<void> resetGameParameters() async => await setGameParameters(
      maximumPlayers: _defaultMaxPlayers,
      nbRows: _defaultNbRows,
      nbCols: _defaultNbCols,
      nbTreasures: _defaultNbTreasures,
      maxEnergy: _defaultMaxEnergy,
      restingTime: _defaultRestingTime,
      gameSpeed: _defaultGameSpeed);

  ///
  /// Load parameters from a previous session
  Future<void> _loadGameParameters() async {
    final prefs = await SharedPreferences.getInstance();

    _isFirstTime = prefs.getBool('isFirstTime') ?? true;

    final maximumPlayers = prefs.getInt('maximumPlayers');
    final nbRows = prefs.getInt('nbRows');
    final nbCols = prefs.getInt('nbCols');
    final nbTreasures = prefs.getInt('nbTreasures');
    final maxEnergy = prefs.getInt('maxEnergy');
    final restingTime = prefs.getInt('restingTime');
    final gameSpeed = prefs.getInt('gameSpeed') == null
        ? null
        : Duration(milliseconds: prefs.getInt('gameSpeed')!);

    setGameParameters(
      maximumPlayers: maximumPlayers,
      nbRows: nbRows,
      nbCols: nbCols,
      nbTreasures: nbTreasures,
      maxEnergy: maxEnergy,
      restingTime: restingTime,
      gameSpeed: gameSpeed,
    );
  }

  ///
  /// Load parameters from a previous session
  Future<void> _saveGameParameters() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('isFirstTime', false);

    prefs.setInt('maximumPlayers', _maxPlayers);
    prefs.setInt('nbRows', _nbRows);
    prefs.setInt('nbCols', _nbCols);
    prefs.setInt('nbTreasures', _nbTreasures);
    prefs.setInt('maxEnergy', _maxEnergy);
    prefs.setInt('restingTime', _restingTime);
    prefs.setInt('gameSpeed', _gameSpeed.inMilliseconds);
  }

  ///
  /// Get the player that has the highest score
  List<String> get playersWithHighestScore {
    List<String> out = [];
    var highestScore = -1;
    for (final player in players.keys) {
      final treasures = players[player]!.treasures;
      if (treasures >= highestScore) {
        if (treasures > highestScore) out.clear();

        out.add(player);
        highestScore = treasures;
      }
    }
    return out;
  }

  ///
  /// Reset the board to initial and call the refresh the draw
  void newGame() {
    _generateGrid();
    for (final player in _players.keys) {
      _players[player]!
          .reset(maxEnergy: _maxEnergy, minimumRestingTime: _restingTime);
    }

    _ennemies.clear();
    _ennemies['rabbit'] = Ennemy(
      name: 'rabbit',
      color: Colors.white,
      restingTime: _rabbitRestingTime,
    );

    for (final ennemy in _ennemies.keys) {
      _ennemies[ennemy]!.tile = GameTile.random(_nbRows, _nbCols);
    }

    _status = GameStatus.isRunning;
  }

  ///
  /// Add a new player to the player pool
  AddPlayerStatus addPlayer(String username) {
    // This is to prevent adding player when the game is started
    if (!_canRegister) return AddPlayerStatus.registrationIsClosed;
    if (_players.length >= _maxPlayers) return AddPlayerStatus.noMoreSpaceLeft;

    _players[username] = Player(
        name: username,
        color: colorCycle[_players.length],
        maxEnergy: _maxEnergy,
        minimumRestingTime: _restingTime);

    return AddPlayerStatus.success;
  }

  ///
  /// Get the value of a tile of a specific [index]. If the tile is not
  /// revealed yet, this method returns concealed; if the tile is a treasure, then it
  /// returns treasure, otherwise it returns the number of treasure around it.
  /// If index < 0, then it returns starting
  Tile tile(int index) => index < 0
      ? Tile.starting
      : (_isRevealed[index]
          ? (_grid[index] < 0 ? Tile.treasure : Tile.values[_grid[index]])
          : Tile.concealed);

  ///
  /// Same as tile, but return the non-conceiled value
  Tile forceGetTile(int index) => index < 0
      ? Tile.starting
      : _grid[index] < 0
          ? Tile.treasure
          : Tile.values[_grid[index]];

  ///
  /// Get all the players on the tile [index].
  List<Player> playersOnTile(int index) {
    List<Player> out = [];

    final tile = gridTile(index, nbCols);
    for (final p in _players.keys) {
      if (_players[p]!.tile == tile) {
        out.add(_players[p]!);
      }
    }
    return out;
  }

  ///
  /// Get all the players on the tile [index].
  List<Ennemy> ennemiesOnTile(int index) {
    List<Ennemy> out = [];

    final tile = gridTile(index, nbCols);
    for (final ennemy in _ennemies.keys) {
      if (_ennemies[ennemy]!.tile == tile) {
        out.add(_ennemies[ennemy]!);
      }
    }
    return out;
  }

  ///
  /// Get all the players on the tile [index].
  List<Ennemy> ennemiesThatCanAttack(int index) {
    List<Ennemy> out = [];

    final tile = gridTile(index, nbCols);
    for (final ennemy in _ennemies.keys) {
      if (_ennemies[ennemy]!.influencedTiles.contains(tile)) {
        out.add(_ennemies[ennemy]!);
        continue;
      }
    }
    return out;
  }

  ///
  /// Get the number of treasures that were found
  int get treasuresFound {
    int cmp = 0;
    for (var i = 0; i < _grid.length; i++) {
      if (tile(i) == Tile.treasure) cmp++;
    }
    return cmp;
  }

  void forceGameOver() {
    _status = GameStatus.isOver;
    onGameOver();
  }

  ///
  /// Is the game over based
  bool get isGameOver {
    if (_status == GameStatus.isOver) return true;

    // If all the treasures are found
    if (treasuresFound == nbTreasures) {
      forceGameOver();
    }

    return _status == GameStatus.isOver;
  }

  ///
  /// Adds a move to the moves list of [username] player.
  void setPlayerMove(String username, {required GameTile newTile}) {
    // Safe guards
    // If game is over
    if (isGameOver) return;
    // If tile not in the grid
    if (!isInsideGrid(newTile)) return;
    // Player who played is actually a player
    if (!players.containsKey(username)) return;

    final player = _players[username]!;
    player.addTarget(newTile);
  }

  ///
  /// Main interface for a user to reveal a tile from the grid
  RevealResult _revealTile(String username, {required GameTile tile}) {
    // Safe guards
    // If game is over
    if (isGameOver) return RevealResult.gameOver;
    // If tile not in the grid
    if (!isInsideGrid(tile)) return RevealResult.outsideGrid;
    // If tile was already revealed
    final index = gridIndex(tile, nbCols);
    if (_isRevealed[index]) return RevealResult.alreadyRevealed;
    // Player still has energy
    if (_players[username]!.energy < 0) return RevealResult.noEnergyLeft;

    // Start the recursive process of revealing all the required tiles
    _revealTileRecursive(index);

    // Give points if necessary
    if (_grid[index] == -1) {
      _players[username]!.treasures += 1;
      return RevealResult.hit;
    } else {
      return RevealResult.miss;
    }
  }

  ///
  /// Reveal a tile. If it is a zero, it is recursively called to all its
  /// neighbourhood so it automatically reveals all the surroundings
  Future<void> _revealTileRecursive(int idx, {List<bool>? isChecked}) async {
    // If it is already open, do nothing
    if (_isRevealed[idx] || (isChecked != null && isChecked[idx])) return;

    // For each zeros encountered, we must check around if it is another zero
    // so it can be reveal. We must make sure we don't recheck a previously
    // checked tile though so we don't go in an infinite loop of checking.
    if (isChecked == null) {
      // Prepare the isChecked structure and launch the recursive procedure
      isChecked = List.filled(nbRows * nbCols, false);
      await _revealTileRecursive(idx, isChecked: isChecked);
      return;
    }

    // Reveal the current tile
    _isRevealed[idx] = true;

    // If the current tile is not zero, stop revealing, otherwise reveal the
    // tiles around
    if (_grid[idx] != 0) return;

    final currentTile = gridTile(idx, nbCols);
    for (var j = -1; j < 2; j++) {
      for (var k = -1; k < 2; k++) {
        // Do not reveal itself
        if (j == 0 && k == 0) continue;

        final newTile = GameTile(currentTile.row + j, currentTile.col + k);

        // Do not try to reveal tile outside of the grid
        if (!isInsideGrid(newTile)) continue;

        // Reveal the tile if it was not already revealed
        final newIndex = gridIndex(newTile, nbCols);
        if (!_isRevealed[newIndex]) {
          // If it was a zero reveal to tiles around
          await _revealTileRecursive(newIndex, isChecked: isChecked);
        }
      }
    }
  }

  ///
  /// Start the timer that calls the game loop
  void _startGameLoopTimer() => Timer.periodic(_gameSpeed, (_) => _gameLoop());

  ///
  /// Internal loop that is called each time step. It advances the player
  /// towards their next position and check the state of the tiles
  void _gameLoop() {
    if (_status != GameStatus.isRunning) return;

    List<NeedRedraw> needRedraw = [];

    for (final p in _players.keys) {
      final player = _players[p]!;
      if (player.rest()) needRedraw.add(NeedRedraw.score);
      if (player
          .march(_players.keys.map((key) => players[key]!.tile).toList())) {
        needRedraw.add(NeedRedraw.grid);
      }

      for (final ennemy in _ennemies.keys) {
        if (_ennemies[ennemy]!.attack(player)) {
          onAttacked(player, _ennemies[ennemy]!);
        }
      }

      if (_revealTile(p, tile: player.tile) == RevealResult.hit) {
        player.refillEnergy();

        // Lower all the number surronding
        _lowerTreasureMarker(player.tile);

        // Notify game interface
        onTreasureFound(player);
      }
    }

    for (final ennemy in _ennemies.keys) {
      if (_ennemies[ennemy]!.shouldChangePosition) {
        _ennemies[ennemy]!.addTarget(GameTile.random(_nbRows, _nbCols));
      }
      if (_ennemies[ennemy]!.march([], gameManager: this)) {
        needRedraw.add(NeedRedraw.grid);
      }
    }

    // Notify the game interface of the new state of the game
    needRedrawCallback(needRedraw);
  }

  ///
  /// Get if a tile is inside or outside the current grid
  bool isInsideGrid(GameTile tile) {
    // Do not check rows or column outside of the grid
    return (tile.row >= 0 &&
        tile.col >= 0 &&
        tile.row < nbRows &&
        tile.col < nbCols);
  }

  ///
  /// Generate a new grid with randomly positionned treasures
  void _generateGrid() {
    // Create an empty grid
    _grid = List.filled(nbRows * nbCols, 0);
    _isRevealed = List.filled(nbRows * nbCols, false);

    // Populate it with treasures
    final rand = Random();
    for (var i = 0; i < nbTreasures; i++) {
      var indexOfTreasure = -1;
      do {
        indexOfTreasure = rand.nextInt(nbRows * nbCols);
        // Make sure it was not already a treasure
      } while (_grid[indexOfTreasure] == -1);
      _grid[indexOfTreasure] = -1;
    }

    // Recalculate the value of each tile based on number of treasures around it
    for (var i = 0; i < nbRows * nbCols; i++) {
      // Do not recompute tile with a treasure in it
      if (_grid[i] < 0) continue;

      var nbTreasuresAroundTile = 0;

      final currentTile = gridTile(i, nbCols);
      // Check the previous row to next row
      for (var j = -1; j <= 1; j++) {
        // Check the previous col to next col
        for (var k = -1; k <= 1; k++) {
          // Do not check itself
          if (j == 0 && k == 0) continue;

          // Find the current checked tile
          final checkedTile =
              GameTile(currentTile.row + j, currentTile.col + k);
          if (!isInsideGrid(checkedTile)) continue;

          // If there is a treasure, add it to the counter
          if (_grid[gridIndex(checkedTile, nbCols)] < 0) {
            nbTreasuresAroundTile++;
          }
        }
      }

      // Store the number in the tile
      _grid[i] = nbTreasuresAroundTile;
    }
  }

  ///
  /// When a treasure is found, lower all the surronding numbers
  void _lowerTreasureMarker(GameTile treasure) {
    for (var j = -1; j <= 1; j++) {
      // Check the previous col to next col
      for (var k = -1; k <= 1; k++) {
        // Do not check itself
        if (j == 0 && k == 0) continue;

        final tile = GameTile(treasure.row + j, treasure.col + k);
        if (!isInsideGrid(tile)) continue;
        final index = gridIndex(tile, nbCols);

        // If this is not a treasure, reduce that tile by one
        if (_grid[index] > 0) _grid[index]--;
      }
    }
  }
}
