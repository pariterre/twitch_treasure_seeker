import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/managers/game_manager.dart';
import 'package:twitch_treasure_seeker/managers/words_manager.dart';
import 'package:twitch_treasure_seeker/models/enums.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late final List<String> _letters =
      List.generate(WordsManager.instance.current.length, (_) => '_');

  @override
  void initState() {
    super.initState();

    final gm = GameManager.instance;
    gm.onClockTicked.listen(_onClockTicked);
    gm.onTileRevealed.listen(_onTileRevealed);
    gm.onTreasureFound.listen(_onTreasureFound);
  }

  @override
  void dispose() {
    final gm = GameManager.instance;
    gm.onClockTicked.cancel(_onClockTicked);
    gm.onTileRevealed.cancel(_onTileRevealed);
    gm.onTreasureFound.cancel(_onTreasureFound);

    super.dispose();
  }

  void _onClockTicked(Duration timeRemaining) {
    setState(() {});
  }

  void _onTileRevealed() {
    setState(() {});
  }

  void _onTreasureFound(Tile tile) {
    if (tile != Tile.letter) return;
    // Transfer the letters found to the header
    final lettersFound = GameManager.instance.getLettersFoundIndices.toList();
    final currentWord = WordsManager.instance.current;
    for (int i = 0; i < lettersFound.length; i++) {
      if (lettersFound[i]) _letters[i] = currentWord[i];
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Temps restant: ${GameManager.instance.timeRemaining.inSeconds}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Essais restants: ${GameManager.instance.triesRemaining}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_letters.length, (index) {
            return Text(
              _letters[index],
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            );
          }),
        ),
      ],
    );
  }
}
