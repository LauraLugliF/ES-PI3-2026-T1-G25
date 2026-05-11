import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final BoxFit fit;
  final String assetPath;

  const AppLogo({
    super.key,
    this.height = 120,
    this.fit = BoxFit.contain,
    this.assetPath = 'lib/screens/assets/Logo1.png',
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheHeight = (height * dpr).round();
    return Image.asset(
      assetPath,
      height: height,
      fit: fit,
      cacheHeight: cacheHeight,
      errorBuilder: (c, e, st) => Container(
        width: height * 0.87,
        height: height * 0.87,
        decoration: BoxDecoration(
          color: const Color(0xFF2DBE9D).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.trending_up, size: 56, color: Color(0xFF2DBE9D)),
      ),
    );
  }
}
