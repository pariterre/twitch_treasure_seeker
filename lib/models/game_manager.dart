import 'dart:async';
import 'dart:math';

import 'package:twitched_minesweeper/models/enums.dart';

import 'player.dart';

///
/// Easy accessors translating index into row/col pair or row/col pair into
/// index
int gridIndex(int row, int col, int nbCols) => row * nbCols + col;
int gridRow(int index, int nbCols) => index ~/ nbCols;
int gridCol(int index, int nbCols) => index % nbCols;

class GameManager {
  var _status = GameStatus.initial;
  Function()? updateState;

  // speed a which each movements are triggered
  final _gameSpeed = const Duration(seconds: 1);

  // Maximum number of players allowed to play
  int _maxPlayers = 10;
  int get maxPlayers => _maxPlayers;
  final Map<String, Player> _players = {};

  // Size of the grid
  int _nbRows = 20;
  int get nbRows => _nbRows;

  int _nbCols = 10;
  int get nbCols => _nbCols;

  // Number of bombs on the grid
  int _nbBombs = 10;
  int get nbBombs => _nbBombs;

  // The actual grid
  List<int> _grid = [];
  List<bool> _isRevealed = [];

  // The player stored by username
  Map<String, Player> get players => _players;

  // If the game is still open for registration
  bool _canRegister = true;
  void closeRegistration() => _canRegister = false;

  GameManager() {
    _generateGrid();
    _startTimer();
  }

  ///
  /// Reset the players
  void resetPlayers() {
    _players.clear();
  }

  ///
  /// Set the game parameters
  void setGameParameters(
      {int? maximumPlayers, int? nbRows, int? nbCols, int? nbBombs}) {
    maximumPlayers = maximumPlayers ?? _maxPlayers;
    nbRows = nbRows ?? _nbRows;
    nbCols = nbCols ?? _nbCols;
    nbBombs = nbBombs ?? _nbBombs;

    if (maximumPlayers < 1) {
      throw 'Maximum number of players must be greater or equal to 1';
    }
    if (nbRows < 1) {
      throw 'Number of rows must be greater or equal to 1';
    }
    if (nbCols < 1) {
      throw 'Number of cols must be greater or equal to 1';
    }
    if (nbBombs < 1) {
      throw 'Number of bombs must be greater or equal to 1';
    }

    if (_nbBombs > _nbRows * _nbCols) {
      throw 'Too many bombs for the number of tiles';
    }

    _maxPlayers = maximumPlayers;
    _nbRows = nbRows;
    _nbCols = nbCols;
    _nbBombs = nbBombs;
  }

  ///
  /// Get the player that has the highest score
  String get playerWithHighestScore {
    String out = "";
    var highestScore = -1;
    for (final player in players.keys) {
      if (players[player]!.score > highestScore) {
        out = player;
        highestScore = players[player]!.score;
      }
    }
    return out;
  }

  ///
  /// Reset the board to initial and call the refresh the draw
  void newGame() {
    _status = GameStatus.initial;
    _generateGrid();
    for (final player in _players.keys) {
      _players[player]!.reset(bombs: _nbBombs);
    }
  }

  ///
  /// Add a new player to the player pool
  AddPlayerStatus addPlayer(String username) {
    // This is to prevent adding player when the game is started
    if (!_canRegister) return AddPlayerStatus.registrationIsClosed;
    if (_players.length >= _maxPlayers) return AddPlayerStatus.noMoreSpaceLeft;

    _players[username] = Player(username: username);

    return AddPlayerStatus.success;
  }

  ///
  /// Get the value of a tile of a specific [index]. If the tile is not
  /// revealed yet, this method returns -2; if the tile is a bomb, then it
  /// returns -1, otherwise it returns the number of bomb around it.
  Tile tile(int index) => _isRevealed[index]
      ? (_grid[index] < 0 ? Tile.bomb : Tile.values[_grid[index]])
      : Tile.concealed;

  ///
  /// Get the number of bombs that were found
  int get bombsFound {
    int cmp = 0;
    for (var i = 0; i < _grid.length; i++) {
      if (tile(i) == Tile.bomb) cmp++;
    }
    return cmp;
  }

  void startGame() {
    if (_status != GameStatus.initial) return;

    _status = GameStatus.isRunning;
  }

  ///
  /// Is the game over based
  bool get isGameOver {
    if (_status == GameStatus.isOver) return true;

    // If all the bombs are found or noone has any bomb left to throw
    if (bombsFound == nbBombs ||
        _players.keys.fold<int>(0, (prev, p) => _players[p]!.bombs) == 0) {
      _status = GameStatus.isOver;
    }

    return _status == GameStatus.isOver;
  }

  ///
  /// Main interface for a user to reveal a tile from the grid
  RevealResult revealTile(String username,
      {required int row, required int col}) {
    if (isGameOver) return RevealResult.gameOver;
    // Safe guards so the player who tries to reveal is actually a player
    if (!players.containsKey(username)) return RevealResult.unrecognizedUser;
    // and doesn't throw outside of the grid
    if (!_isInsideGrid(row, col)) return RevealResult.outsideGrid;
    // and is still allowed to throw
    if (_players[username]!.bombs == 0) return RevealResult.noBombLeft;

    final index = gridIndex(row, col, nbCols);

    // Do not reveal a previously revealed tile
    if (_isRevealed[index]) return RevealResult.alreadyRevealed;

    // Start the recursive process of revealing all the required tiles
    _revealTile(index);

    // Remove a bomb from the user
    _players[username]!.bombs--;

    // Give points if necessary
    if (_grid[index] == -1) {
      _players[username]!.score += 1;
      return RevealResult.hit;
    } else {
      return RevealResult.miss;
    }
  }

  ///
  /// Reveal a tile. If it is a zero, it is recursively called to all its
  /// neighbourhood so it automatically reveals all the surroundings
  Future<void> _revealTile(int idx, {List<bool>? isChecked}) async {
    // If it is already open, do nothing
    if (_isRevealed[idx] || (isChecked != null && isChecked[idx])) return;

    // For each zeros encountered, we must check around if it is another zero
    // so it can be reveal. We must make sure we don't recheck a previously
    // checked tile though so we don't go in an infinite loop of checking.
    if (isChecked == null) {
      // Prepare the isChecked structure and launch the recursive procedure
      isChecked = List.filled(nbRows * nbCols, false);
      await _revealTile(idx, isChecked: isChecked);
      return;
    }

    // Reveal the current tile
    _isRevealed[idx] = true;

    // If the current tile is not zero, stop revealing, otherwise reveal the
    // tiles around
    if (_grid[idx] != 0) return;

    int currentTileRow = gridRow(idx, nbCols);
    int currentTileCol = gridCol(idx, nbCols);
    for (var j = -1; j < 2; j++) {
      for (var k = -1; k < 2; k++) {
        // Do not reveal itself
        if (j == 0 && k == 0) continue;

        final newRow = currentTileRow + j;
        final newCol = currentTileCol + k;

        // Do not try to reveal tile outside of the grid
        if (!_isInsideGrid(newRow, newCol)) continue;

        // Reveal the tile if it was not already revealed
        final newIndex = gridIndex(newRow, newCol, nbCols);
        if (!_isRevealed[newIndex]) {
          // If it was a zero reveal to tiles around
          await _revealTile(newIndex, isChecked: isChecked);
        }
      }
    }
  }

  ///
  /// Start the timer that calls the game loop
  void _startTimer() {
    // TODO allow to parametrize
    Timer(_gameSpeed, _gameLoop);
  }

  ///
  /// Internal loop that is called each time step. It advances the player
  /// towards their next position and check the state of the tiles
  void _gameLoop() {
    if (_status != GameStatus.isRunning) return;

    for (final p in _players.keys) {
      _players[p]!.march();
      revealTile(p, row: _players[p]!.x, col: _players[p]!.y);
    }

    // Notify the game interface of the new state of the game
    if (updateState != null) updateState!();
  }

  ///
  /// Get if a specific row/col pair is inside or outside the current grid
  bool _isInsideGrid(row, col) {
    // Do not check rows or column outside of the grid
    return (row >= 0 && col >= 0 && row < nbRows && col < nbCols);
  }

  ///
  /// Generate a new grid with randomly positionned bomb
  void _generateGrid() {
    // Create an empty grid
    _grid = List.filled(nbRows * nbCols, 0);
    _isRevealed = List.filled(nbRows * nbCols, false);

    // Populate it with bombs
    final rand = Random();
    for (var i = 0; i < nbBombs; i++) {
      var indexToBomb = -1;
      do {
        indexToBomb = rand.nextInt(nbRows * nbCols);
        // Make sure it was not already a bomb
      } while (_grid[indexToBomb] == -1);
      _grid[indexToBomb] = -1;
    }

    // Recalculae the value of each tile based on number of bombs around it
    for (var i = 0; i < nbRows * nbCols; i++) {
      // Do not recompute tile with a bomb in it
      if (_grid[i] < 0) continue;

      var nbBombsAroundTile = 0;

      final currentTileRow = gridRow(i, nbCols);
      final currentTileCol = gridCol(i, nbCols);
      // Check the previous row to next row
      for (var j = -1; j < 2; j++) {
        // Check the previous col to next col
        for (var k = -1; k < 2; k++) {
          // Do not check itself
          if (j == 0 && k == 0) continue;

          // Find the current checked tile
          final checkedTileRow = currentTileRow + j;
          final checkedTileCol = currentTileCol + k;

          if (!_isInsideGrid(checkedTileRow, checkedTileCol)) continue;

          // If there is a bomb, add it to the counter
          if (_grid[gridIndex(checkedTileRow, checkedTileCol, nbCols)] < 0) {
            nbBombsAroundTile++;
          }
        }
      }

      // Store the number in the tile
      _grid[i] = nbBombsAroundTile;
    }
  }
}
