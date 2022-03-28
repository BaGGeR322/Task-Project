import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedGlassBox extends StatelessWidget {
  final double width;
  final Widget child;

  FrostedGlassBox({
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: SizedBox(
        width: width,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7.0,
                sigmaY: 7.0,
              ),
              child:
                  SizedBox(width: width, child: const Text('')),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                    color: Colors.white.withOpacity(0.2), width: 1.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.05),
                  ],
                  stops: const [
                    0.0,
                    1.0,
                  ],
                ),
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
