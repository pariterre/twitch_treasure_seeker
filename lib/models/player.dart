class Player {
  final String username;
  int score = 0;
  int bombs = 0;

  void reset({required int bombs}) {
    score = 0;
    this.bombs = bombs;
  }

  Player({required this.username});
}
