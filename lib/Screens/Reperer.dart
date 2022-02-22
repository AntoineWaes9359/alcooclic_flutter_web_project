import 'package:alcooclic/Screens/Orienter.dart';
import 'package:alcooclic/Screens/Reperer_Complet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:alcooclic/constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_button/group_button.dart';
import 'Components/App_bar.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:collection/collection.dart';

class Reperer extends StatefulWidget {
  static const String route = '/overview';
  @override
  State<Reperer> createState() => _RepererState();
}

class _RepererState extends State<Reperer> {
  List<int> reponses = [0, 0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 20.0);
    TextStyle linkStyle = TextStyle(color: couleurBeige);

    var question1Reponses = [
      "Jamais",
      "Une fois par mois ou moins",
      "2 à 4 fois par mois",
      "2 à 3 fois par semaine",
      "4 fois ou plus par semaine"
    ];
    var question1ReponsesScore = [0, 1, 2, 3, 4];

    var question2Reponses = [
      "1 ou 2",
      "3 ou 4",
      "5 ou 6",
      "7 à 9",
      "10 ou plus"
    ];
    var question2ReponsesScore = [0, 1, 2, 3, 4];

    var question3Reponses = ["Non", "Oui"];
    var question3ReponsesScore = [0, 4];

    var question4Reponses = ["Non", "Oui"];
    var question4ReponsesScore = [0, 4];

    var question5Reponses = ["Non", "Oui"];
    var question5ReponsesScore = [0, 4];

    return Scaffold(
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        child: ListView(
          children: [
            CustomAppBar(
              isHovering: [false, true, false, false],
            ),
            Column(
              children: [
                SizedBox(height: 20),
                Text("Questionnaire FACE",
                    style: GoogleFonts.raleway(
                        textStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: couleurBeige))),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "1. À quelle fréquence vous arrive-t-il de consommer des boissons contenant de l’alcool ?",
                    question1Reponses,
                    question1ReponsesScore,
                    0),
                SizedBox(
                  height: 30,
                ),
                carteQuestion(
                    "2. Combien de verres standard buvez-vous au cours d’une journée ordinaire où vous buvez de l’alcool ?",
                    question2Reponses,
                    question2ReponsesScore,
                    1),
                SizedBox(
                  height: 30,
                ),
                carteQuestion(
                    "3. Votre entourage vous a-t-il déjà fait des remarques au sujet de votre consommation d’alcool ?",
                    question3Reponses,
                    question3ReponsesScore,
                    2),
                SizedBox(
                  height: 30,
                ),
                carteQuestion(
                    "4. Avez-vous déjà eu besoin d’alcool le matin pour vous sentir en forme ?",
                    question4Reponses,
                    question4ReponsesScore,
                    3),
                SizedBox(
                  height: 30,
                ),
                carteQuestion(
                    "5. Vous arrive-t-il de boire et de ne plus vous souvenir ensuite de ce que vous avez pu dire ou faire ?",
                    question5Reponses,
                    question5ReponsesScore,
                    4),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 500,
                  child: Divider(
                    height: 30,
                    thickness: 2,
                    color: couleurBleu,
                    indent: 100,
                    endIndent: 100,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Score du patient : ",
                        style: GoogleFonts.raleway(
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black))),
                    Text(
                      (reponses.sum).toString(),
                      style: TextStyle(
                          color: couleurBeige, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Un score >4 chez la femme et >5 chez l'homme doit faire suspecter un mésusage."),
                    Text(
                        "Un score >9 dans les deux sexes doit faire évoquer une dépendance"),
                    RichText(
                        text: TextSpan(children: <TextSpan>[
                      TextSpan(text: "En cas de suspicion de mésusage, "),
                      TextSpan(
                          style: linkStyle,
                          text: "le questionnaire AUDIT complet ",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (context, _, __) {
                                  return Reperer_Complet();
                                },
                              ));
                            }),
                      TextSpan(
                          text:
                              "permet de différencier usage à risque et usage nocif voir dépendance."),
                    ])),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, _, __) {
                          return Orienter();
                        },
                      ));
                    },
                    child: Text(
                        "Trouver les structures de soins spécialisées en addictologie autour de vous")),
                SizedBox(
                  height: 40,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  SizedBox carteQuestion(String question1Titre, List<String> question1Reponses,
      List<int> question1ReponsesScores, int numeroQuestion) {
    return SizedBox(
      width: 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question1Titre,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          GroupButton(
            isRadio: true,
            options: GroupButtonOptions(
                mainGroupAlignment: MainGroupAlignment.spaceEvenly,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                spacing: 10,
                unselectedTextStyle: TextStyle(color: couleurBeige),
                selectedColor: couleurBeige,
                buttonHeight: 40,
                textPadding: EdgeInsets.all(10)),
            onSelected: (index, isSelected) {
              setState(() {
                reponses[numeroQuestion] = question1ReponsesScores[index];
                if (reponses.sum > 9) {
                  showAlertDialog(context, reponses.sum.toString());
                }
              });
            },
            buttons: question1Reponses,
          ),
        ],
      ),
    );
  }
}

showAlertDialog(BuildContext context, String text) {
  // Create button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget audit = FlatButton(
    child: Text(
      "AUDIT",
      style: TextStyle(color: couleurBeige),
    ),
    onPressed: () {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, _, __) {
          return Reperer_Complet();
        },
      ));
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Suspicion de mésusage"),
    content: Text(
        "Le score du patient (" + text + ") indique certainement un risque."),
    actions: [okButton, audit],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
