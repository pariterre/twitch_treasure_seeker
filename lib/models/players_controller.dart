import 'player.dart';

class PlayersController {
  final List<Player> _players = [];
  List<Player> get players => _players;
  void addPlayer(String playerName) {
    if (_canRegister) _players.add(Player(username: playerName));
    if (onStateChanged != null) onStateChanged!();
  }

  bool _canRegister = true;
  void closeRegistration() => _canRegister = false;

  // This is a callback to current window that need to be redrawn when
  // the grid changes
  void Function()? onStateChanged;
}
