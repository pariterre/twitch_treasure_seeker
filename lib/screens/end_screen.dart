import 'package:flutter/material.dart';
import 'package:twitch_treasure_seeker/models/minesweeper_theme.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  static const route = '/end-screen';

  Widget _buildCongratulation(context) {
    final smallPadding = ThemePadding.small(context);
    final titleSize = ThemeSize.title(context);

    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.main,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: EdgeInsets.all(smallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Félicitation!\n',
              style: TextStyle(color: Colors.white, fontSize: titleSize),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    final windowHeight = MediaQuery.of(context).size.height;

    final offsetFromBorder = windowHeight * 0.02;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: Stack(
          children: [
            SizedBox(
              width: windowWidth,
              height: windowHeight,
            ),
            Positioned(
                left: offsetFromBorder,
                top: offsetFromBorder,
                child: _buildCongratulation(context)),
          ],
        ),
      ),
    );
  }
}
