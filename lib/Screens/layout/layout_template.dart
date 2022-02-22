import 'package:alcooclic/Screens/Components/App_bar.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';

class LayoutTemplate extends StatelessWidget {
  const LayoutTemplate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
