import 'dart:math';

class GameController {
  final int nbRows;
  final int nbCols;
  final int nbBombs;
  List<int> _grid = [];
  List<bool> _isRevealed = [];
  void Function(void Function())? mainWindowSetState;

  GameController({
    required this.nbRows,
    required this.nbCols,
    required this.nbBombs,
  }) {
    _generateGrid();
  }

  void reset() {
    _generateGrid();
    if (mainWindowSetState != null) mainWindowSetState!(() {});
  }

  bool _isInsideGrid(row, col) {
    // Do not check rows or column outside of the grid
    return (row >= 0 && col >= 0 && row < nbRows && col < nbCols);
  }

  int getTile(int index) => _isRevealed[index] ? _grid[index] : -2;
  void revealTile(int index, {List<bool>? isChecked}) {
    // If it is already open, do nothing
    if (_isRevealed[index] || (isChecked != null && isChecked[index])) return;

    // For each zeros encountered, we must check around if it is another zero
    // so it can be reveal. We must make sure we don't recheck a previously
    // checked tile though so we don't go in an infinite loop of checking.
    if (isChecked == null) {
      // Prepare the isChecked structure and launch the recursive procedure
      isChecked = List.filled(nbRows * nbCols, false);
      revealTile(index, isChecked: isChecked);
      if (mainWindowSetState != null) mainWindowSetState!(() {});
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
          revealTile(newIndex, isChecked: isChecked);
        }
      }
    }
  }

  int _index(int row, int col) => row * nbCols + col;
  int _row(int index) => index ~/ nbCols;
  int _col(int index) => index % nbCols;

  void _generateGrid() {
    // Create an empty grid
    _grid = List.filled(nbRows * nbCols, 0);
    _isRevealed = List.filled(nbRows * nbCols, false);

    // Populate it with bombs
    final rand = Random();
    for (var i = 0; i < nbBombs; i++) {
      var indexToBomb = rand.nextInt(nbRows * nbCols);
      while (_grid[indexToBomb] == -1) {
        indexToBomb = rand.nextInt(nbRows * nbCols);
      }
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
