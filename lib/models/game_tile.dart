class GameTile {
  final int row;
  final int col;

  @override
  bool operator ==(other) =>
      other is GameTile && row == other.row && col == other.col;

  GameTile(this.row, this.col);
  GameTile.none()
      : row = -1,
        col = -1;

  GameTile get copy => GameTile(row, col);

  @override
  int get hashCode => row.hashCode + col.hashCode;
}
