import 'dart:math';

class GameController {
  final int nbRows;
  final int nbCols;
  final int nbBombs;
  List<int> _grid = [];
  List<bool> _isOpen = [];

  GameController({
    required this.nbRows,
    required this.nbCols,
    required this.nbBombs,
  }) {
    _generateGrid();
  }

  void revealTile(int index) => _isOpen[index] = true;
  int getTile(int index) => _isOpen[index] ? _grid[index] : -2;

  int _index(int row, int col) => row * nbCols + col;
  int _row(int index) => index ~/ nbCols;
  int _col(int index) => index % nbCols;

  void _generateGrid() {
    // Create an empty grid
    _grid = List.filled(nbRows * nbCols, 0);
    _isOpen = List.filled(nbRows * nbCols, false);

    // Populate it with bombs
    final rand = Random();
    for (var i = 0; i < nbBombs; i++) {
      _grid[rand.nextInt(nbRows * nbCols)] = -1;
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

          // Do not check rows or column outside of the grid
          if (checkedTileRow < 0 ||
              checkedTileCol < 0 ||
              checkedTileRow >= nbRows ||
              checkedTileCol >= nbCols) {
            continue;
          }

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
