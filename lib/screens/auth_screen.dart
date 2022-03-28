import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/auth/auth_form.dart';
import '../widgets/design/frosted_glass_box.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 4, 6, 7).withOpacity(0.9),
                  const Color.fromARGB(255, 124, 17, 17).withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: SafeArea(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 94.0),
                        transform: Matrix4.rotationZ(-8 * pi / 180)
                          ..translate(-10.0),
                        // ..translate(-10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepOrange.shade900,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          'News List',
                          style: TextStyle(
                            color: Theme.of(context)
                                .accentTextTheme
                                .headline6!
                                .color,
                            fontSize: 38,
                            fontFamily: 'Anton',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: FrostedGlassBox(
                      child: AuthForm(),
                      width: deviceSize.width * 0.75,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
