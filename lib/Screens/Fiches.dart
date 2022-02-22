import 'package:flutter/material.dart';
import 'package:alcooclic/constant.dart';
import 'Components/App_bar.dart';

class Fiches extends StatelessWidget {
  static const String route = '/overview';

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        child: ListView(
          children: [
            CustomAppBar(
              isHovering: [false, false, false, true],
            ),
            Column(
              children: [
                Text("test"),
                SizedBox(
                  width: 200,
                  height: 400,
                ),
                Text("test"),
                SizedBox(
                  width: 200,
                  height: 400,
                ),
                Text("test"),
                SizedBox(
                  width: 200,
                  height: 400,
                )
              ],
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}
