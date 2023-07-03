enum GameStatus {
  initial,
  isRunning,
  isOver,
}

enum AddPlayerStatus {
  success,
  registrationIsClosed,
  noMoreSpaceLeft,
}

enum RevealResult {
  hit,
  miss,
  outsideGrid,
  noEnergyLeft,
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
  starting,
}
