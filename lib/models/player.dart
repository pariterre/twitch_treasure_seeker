class Player {
  final String username;
  int score = 0;
  int bombs = 0;

  // Current position of the player
  int x = -1;
  int y = -1;
  final List<List> _nextPosition = [];

  // Constructor
  Player({required this.username});

  // Reset player (usually for a new game)
  void reset({required int bombs}) {
    score = 0;
    this.bombs = bombs;

    x = -1;
    y = -1;
  }

  ///
  /// Advance the current position to next position in the queue
  void march() {
    final newPosition = _nextPosition.removeAt(0);
    x = newPosition[0];
    y = newPosition[1];
  }

  ///
  /// Add a target path to the position queue
  void addTarget(int x, int y) {
    _computePath(x, y);
  }

  ///
  /// Computes the path to get from current
  /// position to target and adds the re
  void _computePath(int xTarget, int yTarget) {
    int xNew = x;
    int yNew = y;

    // Perform a march toward the target x or y at a time
    while (xNew != xTarget || yNew != yTarget) {
      int xError = xTarget - xNew;
      int yError = yTarget - yNew;
      if ((xError.abs() > yError.abs())) {
        xNew += xError.sign;
      } else {
        yNew += yError.sign;
      }
      _nextPosition.add([xNew, yNew]);
    }
  }
}
