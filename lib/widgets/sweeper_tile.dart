import 'package:flutter/material.dart';

class SweeperTile extends StatefulWidget {
  const SweeperTile({super.key, required this.number, required this.tileSize});

  final int number;
  final double tileSize;

  @override
  State<SweeperTile> createState() => _SweeperTileState();
}

class _SweeperTileState extends State<SweeperTile> {
  bool _isClose = true;
  bool get _isOpen => !_isClose;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => {_isClose = false}),
      child: Container(
        decoration: BoxDecoration(
          color:
              _isOpen ? const Color.fromARGB(255, 227, 224, 224) : Colors.grey,
          border: Border.all(width: 3),
        ),
        child: _isOpen
            ? Center(
                child: Text(
                widget.number.toString(),
                style: TextStyle(fontSize: widget.tileSize * 3 / 4),
              ))
            : null,
      ),
    );
  }
}
