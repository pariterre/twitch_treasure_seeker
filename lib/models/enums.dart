enum GameStatus {
  isRunning,
  isOver,
}

enum NeedRedraw {
  grid,
  score,
  playerList,
}

enum RevealResult {
  hit,
  miss,
  outsideGrid,
  alreadyRevealed,
  unrecognizedUser,
  gameOver,
}

enum Tile {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  treasure,
  concealed,
}
