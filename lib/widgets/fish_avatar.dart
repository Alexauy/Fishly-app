import 'package:flutter/material.dart';

class FishAvatar extends StatelessWidget {
  const FishAvatar({
    super.key,
    this.size = 102,
    this.gold = false,
    this.flipHorizontally = false,
    this.assetPath,
  });

  final double size;
  final bool gold;
  final bool flipHorizontally;
  final String? assetPath;

  static const _assetPath = 'assets/hand_drawn/gubby.png';
  static const _scaleFactor = 1.2;

  @override
  Widget build(BuildContext context) {
    final frameSize = size * _scaleFactor;

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: Padding(
        padding: EdgeInsets.all(frameSize * 0.03),
        child: Transform.flip(
          flipX: flipHorizontally,
          child: Image.asset(
            assetPath ?? _assetPath,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
