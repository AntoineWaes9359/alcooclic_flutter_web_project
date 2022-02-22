import 'package:alcooclic/Screens/Fiches.dart';
import 'package:alcooclic/Screens/Reperer.dart';
import 'package:flutter/material.dart';
import 'package:alcooclic/constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Components/App_bar.dart';
import 'Orienter.dart';
import 'Reperer.dart';

class Accueil extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        child: Column(
          children: [
            CustomAppBar(
              isHovering: [true, false, false, false],
            ),
            Spacer(
              flex: 2,
            ),
            Image(
              image: AssetImage('images/Logo_alcooclic.png'),
              width: 400,
              height: 100,
            ),
            Container(
              padding: new EdgeInsets.all(40.0),
              child: Text(
                  "Outil d'aide au repérage et à l'orientation rapide des patients ethyliques chroniques à destination des médecins généralistes des Bouches-du-Rhône.",
                  style: GoogleFonts.raleway(
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black))),
            ),
            Spacer(
              flex: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(
                  flex: 5,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    primary: couleurBleu,
                    onPrimary: Colors.white,
                    fixedSize: const Size(240, 80),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, _, __) {
                        return Reperer();
                      },
                    ));
                  },
                  child: Text(
                    "Repérer",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    primary: couleurBleu,
                    onPrimary: Colors.white,
                    fixedSize: const Size(240, 80),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, _, __) {
                        return Orienter();
                      },
                    ));
                  },
                  child: Text(
                    "Orienter",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Spacer(
                  flex: 5,
                ),
              ],
            ),
            Spacer(
              flex: 1,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: couleurBeige,
                onPrimary: Colors.white,
                fixedSize: const Size(240, 80),
              ),
              onPressed: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, _, __) {
                    return Fiches();
                  },
                ));
              },
              child: Text(
                "Fiches de rappel",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Spacer(
              flex: 5,
            )
          ],
        ),
      ),
    );
  }
}





/*
import 'package:flutter/material.dart';
import 'package:alcooclic/constant.dart';

class Accueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(screenSize.width, 1000),
          child: Container(
            color: couleurBleu,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Alcooclic',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  Spacer(),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Accueil',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: screenSize.width / 20),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Repérer',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: screenSize.width / 20),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Orienter',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: screenSize.width / 20),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Fiches',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: screenSize.width / 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Spacer(
                flex: 2,
              ),
              Image(
                image: AssetImage('Alcooclic.png'),
                width: 400,
                height: 100,
              ),
              Container(
                padding: new EdgeInsets.all(40.0),
                child: Text(
                  "Outil d'aide au repérage et à l'orientation rapide des patients ethyliques chroniques à destination des médecins généralistes des Bouches-du-Rhône.",
                  style: TextStyle(color: couleurBleu),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(
                    flex: 5,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      primary: couleurBleu,
                      onPrimary: Colors.white,
                      fixedSize: const Size(240, 80),
                    ),
                    onPressed: () {
                      // Respond to button press
                    },
                    child: Text(
                      "Repérer",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      primary: couleurBleu,
                      onPrimary: Colors.white,
                      fixedSize: const Size(240, 80),
                    ),
                    onPressed: () {
                      // Respond to button press
                    },
                    child: Text(
                      "Orienter",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Spacer(
                    flex: 5,
                  ),
                ],
              ),
              Spacer(
                flex: 1,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: couleurBeige,
                  onPrimary: Colors.white,
                  fixedSize: const Size(240, 80),
                ),
                onPressed: () {
                  // Respond to button press
                },
                child: Text(
                  "Fiches de rappel",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Spacer(
                flex: 5,
              )
            ],
          ),
        ));
  }
}

*/