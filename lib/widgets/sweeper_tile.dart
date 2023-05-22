import 'package:flutter/material.dart';
import 'package:twitched_minesweeper/models/game_controller.dart';

class SweeperTile extends StatefulWidget {
  const SweeperTile({
    super.key,
    required this.gameController,
    required this.tileIndex,
    required this.tileSize,
  });

  final GameController gameController;
  final int tileIndex;
  final double tileSize;

  @override
  State<SweeperTile> createState() => _SweeperTileState();
}

class _SweeperTileState extends State<SweeperTile> {
  @override
  Widget build(BuildContext context) {
    final nbBombAround = widget.gameController.getTile(widget.tileIndex);

    return InkWell(
      onTap: () =>
          setState(() => widget.gameController.revealTile(widget.tileIndex)),
      child: Container(
        decoration: BoxDecoration(
          color: widget.gameController.getTile(widget.tileIndex) > -2
              ? const Color.fromARGB(255, 227, 224, 224)
              : Colors.grey,
          border: Border.all(width: 3),
        ),
        child: widget.gameController.getTile(widget.tileIndex) > -2
            ? Center(
                child: nbBombAround < 0
                    ? Text('\u2600',
                        style: TextStyle(fontSize: widget.tileSize * 3 / 4))
                    : Text(
                        nbBombAround > 0 ? nbBombAround.toString() : '',
                        style: TextStyle(fontSize: widget.tileSize * 3 / 4),
                      ))
            : null,
      ),
    );
  }
}
