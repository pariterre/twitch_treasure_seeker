enum AddPlayerStatus {
  success,
  registrationIsClosed,
  noMoreSpaceLeft,
}

enum RevealResult {
  hit,
  miss,
  outsideGrid,
  noBombLeft,
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
  bomb,
  concealed,
}
