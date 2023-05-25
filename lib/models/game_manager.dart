import 'dart:math';

import 'package:twitched_minesweeper/models/enums.dart';

import 'player.dart';

class GameManager {
  final Map<String, Player> _players = {};

  int _nbRows = 20;
  int get nbRows => _nbRows;

  int _nbCols = 10;
  int get nbCols => _nbCols;

  int _nbBombs = 10;
  int get nbBombs => _nbBombs;

  List<int> _grid = [];
  List<bool> _isRevealed = [];

  Map<String, Player> get players => _players;
  bool _canRegister = true;
  bool get registrationIsOpen => _canRegister;
  void closeRegistration() => _canRegister = false;

  // This is a callback to current window that need to be redrawn when
  // the grid changes
  void Function()? _onStateChanged;
  set onStateChanged(void Function()? value) {
    _onStateChanged = value;
  }

  GameManager() {
    _generateGrid();
  }

  void setGameParameters(int nbRows, int nbCols, int nbBombs) {
    _nbRows = nbRows;
    _nbCols = nbCols;
    _nbBombs = nbBombs;
    if (_nbBombs > _nbRows * _nbCols) {
      throw 'Too many bombs for the number of tiles';
    }
  }

  ///
  /// Reset the board to initial and call the refresh the draw
  void newGame() {
    _generateGrid();
    for (final player in _players.keys) {
      _players[player]!.reset(bombs: _nbBombs);
    }
    if (_onStateChanged != null) _onStateChanged!();
  }

  ///
  /// Add a new player to the player pool
  void addPlayer(String username) {
    if (!_canRegister) return;

    _players[username] = Player(username: username);

    if (_onStateChanged != null) _onStateChanged!();
    return;
  }

  ///
  /// Get the value of a tile of a specific [index]. If the tile is not
  /// revealed yet, this method returns -2; if the tile is a bomb, then it
  /// returns -1, otherwise it returns the number of bomb around it.
  Tile tile(int index) => _isRevealed[index]
      ? (_grid[index] < 0 ? Tile.bomb : Tile.values[_grid[index]])
      : Tile.concealed;

  ///
  /// Main interface for a user to reveal a tile from the grid
  RevealResult revealTile(String username,
      {required int row, required int col}) {
    // Safe guards so the player who tries to reveal is actually a player
    if (!players.containsKey(username)) return RevealResult.unrecognizedUser;
    // and doesn't throw outside of the grid
    if (!_isInsideGrid(row, col)) return RevealResult.outsideGrid;
    // and is still allowed to throw
    if (_players[username]!.bombs == 0) return RevealResult.noBombLeft;

    final index = _index(row, col);

    // Do not reveal a previously revealed tile
    if (_isRevealed[index]) return RevealResult.alreadyRevealed;

    // Start the recursive process of revealing all the required tiles
    _revealTile(index);
    _players[username]!.bombs--;
    if (_grid[index] == -1) {
      _players[username]!.score += 100;
      return RevealResult.hit;
    } else {
      _players[username]!.score += _grid[index] * 10;
      return RevealResult.miss;
    }
  }

  ///
  /// Reveal a tile. If it is a zero, it is recursively called to all its
  /// neighbourhood so it automatically reveals all the surroundings
  Future<void> _revealTile(int index, {List<bool>? isChecked}) async {
    // If it is already open, do nothing
    if (_isRevealed[index] || (isChecked != null && isChecked[index])) return;

    // For each zeros encountered, we must check around if it is another zero
    // so it can be reveal. We must make sure we don't recheck a previously
    // checked tile though so we don't go in an infinite loop of checking.
    if (isChecked == null) {
      // Prepare the isChecked structure and launch the recursive procedure
      isChecked = List.filled(nbRows * nbCols, false);
      await _revealTile(index, isChecked: isChecked);
      if (_onStateChanged != null) _onStateChanged!();
      return;
    }

    // Reveal the current tile
    _isRevealed[index] = true;

    // If the current tile is not zero, stop revealing, otherwise reveal the
    // tiles around
    if (_grid[index] != 0) return;

    int currentTileRow = _row(index);
    int currentTileCol = _col(index);
    for (var j = -1; j < 2; j++) {
      for (var k = -1; k < 2; k++) {
        // Do not reveal itself
        if (j == 0 && k == 0) continue;

        final newRow = currentTileRow + j;
        final newCol = currentTileCol + k;

        // Do not try to reveal tile outside of the grid
        if (!_isInsideGrid(newRow, newCol)) continue;

        // Reveal the tile if it was not already revealed
        final newIndex = _index(newRow, newCol);
        if (!_isRevealed[newIndex]) {
          // If it was a zero reveal to tiles around
          await _revealTile(newIndex, isChecked: isChecked);
        }
      }
    }
  }

  ///
  /// Easy accessors translating index into row/col pair or row/col pair into
  /// index
  int _index(int row, int col) => row * nbCols + col;
  int _row(int index) => index ~/ nbCols;
  int _col(int index) => index % nbCols;

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

      final currentTileRow = _row(i);
      final currentTileCol = _col(i);
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
          if (_grid[_index(checkedTileRow, checkedTileCol)] < 0) {
            nbBombsAroundTile++;
          }
        }
      }

      // Store the number in the tile
      _grid[i] = nbBombsAroundTile;
    }
  }
}
