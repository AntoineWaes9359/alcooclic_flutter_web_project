import 'package:alcooclic/Screens/Fiches.dart';
import 'package:alcooclic/Screens/Reperer.dart';

import '../Orienter.dart';
import '/constant.dart';
import 'package:flutter/material.dart';
import '/Screens/Accueil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget {
  final List isHovering;
  const CustomAppBar({Key? key, required this.isHovering}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: couleurBleu,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, -2),
                blurRadius: 30,
                color: Colors.black.withOpacity(0.16))
          ]),
      child: Row(
        children: <Widget>[
          SizedBox(width: 5),
          Text("Alcooclic",
              style: GoogleFonts.raleway(
                  textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white))),
          Spacer(),
          MenuItem(
            title: "Accueil",
            press: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, _, __) {
                  return Accueil();
                },
              ));
            },
            isSelected: isHovering[0],
          ),
          MenuItem(
            title: "Repérer",
            press: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, _, __) {
                  return Reperer();
                },
              ));
            },
            isSelected: isHovering[1],
          ),
          MenuItem(
            title: "Orienter",
            press: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, _, __) {
                  return Orienter();
                },
              ));
            },
            isSelected: isHovering[2],
          ),
          MenuItem(
            title: "Fiches",
            press: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, _, __) {
                  return Fiches();
                },
              ));
            },
            isSelected: isHovering[3],
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final VoidCallback press;
  final bool isSelected;
  const MenuItem({
    Key? key,
    required this.title,
    required this.press,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(title,
                style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: isSelected ? couleurBeige : Colors.white,
                        //fontWeight: FontWeight.bold,
                        fontSize: 15))),
          ),
          SizedBox(height: 5),
          // For showing an underline on hover
          Visibility(
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
            visible: isSelected,
            child: Container(
              height: 2,
              width: 20,
              color: couleurBeige,
            ),
          )
        ],
      ),
    );
  }
}
