import 'package:flutter/material.dart';
import 'package:alcooclic/constant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_button/group_button.dart';
import 'Components/App_bar.dart';

class Reperer_Complet extends StatefulWidget {
  static const String route = '/overview';
  @override
  State<Reperer_Complet> createState() => _Reperer_CompletState();
}

class _Reperer_CompletState extends State<Reperer_Complet> {
  List<int> reponses = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

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

    var question3Reponses = [
      "1 ou 2",
      "3 ou 4",
      "5 ou 6",
      "7 à 9",
      "10 ou plus"
    ];
    var question3ReponsesScore = [0, 1, 2, 3, 4];

    var question4Reponses = [
      "Jamais",
      "Moins d’une fois par mois",
      "Une fois par mois",
      "Une fois par semaine",
      "Chaque jour ou presque"
    ];
    var question4ReponsesScore = [0, 1, 2, 3, 4];

    var question5Reponses = [
      "Jamais",
      "Moins d’une fois par mois",
      "Une fois par mois",
      "Une fois par semaine",
      "Chaque jour ou presque"
    ];
    var question5ReponsesScore = [0, 1, 2, 3, 4];

    var question6Reponses = [
      "Jamais",
      "Moins d’une fois par mois",
      "Une fois par mois",
      "Une fois par semaine",
      "Chaque jour ou presque"
    ];
    var question6ReponsesScore = [0, 1, 2, 3, 4];

    var question7Reponses = [
      "Jamais",
      "Moins d’une fois par mois",
      "Une fois par mois",
      "Une fois par semaine",
      "Chaque jour ou presque"
    ];
    var question7ReponsesScore = [0, 1, 2, 3, 4];

    var question8Reponses = [
      "Jamais",
      "Moins d’une fois par mois",
      "Une fois par mois",
      "Une fois par semaine",
      "Chaque jour ou presque"
    ];
    var question8ReponsesScore = [0, 1, 2, 3, 4];

    var question9Reponses = [
      "Non",
      "Oui, mais pas dans l’année passée",
      "Oui, au cours de l’année dernière"
    ];
    var question9ReponsesScore = [0, 1, 2];

    var question10Reponses = [
      "Non",
      "Oui, mais pas dans l’année passée",
      "Oui, au cours de l’année dernière"
    ];
    var question10ReponsesScore = [0, 1, 2];

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
                Text("Questionnaire AUDIT",
                    style: GoogleFonts.raleway(
                        textStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black))),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "1. À quelle fréquence vous arrive-t-il de consommer des boissons contenant de l’alcool ?",
                    question1Reponses,
                    question1ReponsesScore,
                    0),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "2. Combien de verres standard buvez-vous au cours d’une journée ordinaire où vous buvez de l’alcool ?",
                    question2Reponses,
                    question2ReponsesScore,
                    1),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "3. Au cours d'une même occasion, combien de fois vous arrive-t-il de boire six verres standard ou plus ?",
                    question3Reponses,
                    question3ReponsesScore,
                    2),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "4. Dans l'année écoulée, combien de fois avez-vous observé que vous n'étiez plus capable de vous arrêter de boire après avoir commencé ?",
                    question4Reponses,
                    question4ReponsesScore,
                    3),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "5. Dans l'année écoulée, combien de fois, parce que vous avez bu, n'avez-vous pu faire ce que vous aviez à faire ?",
                    question5Reponses,
                    question5ReponsesScore,
                    4),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "6. Dans l'année écoulée, combien de fois, après une période de forte consommation, avez-vous dû boire de l'alcool dès le matin pour vous remettre en forme ?",
                    question6Reponses,
                    question6ReponsesScore,
                    5),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "7. Dans l'année écoulée, combien de fois avez-vous eu un sentiment de culpabilité ou de regret après avoir bu ?",
                    question7Reponses,
                    question7ReponsesScore,
                    6),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "8. Dans l'année écoulée, combien de fois avez-vous été incapable de vous souvenir de ce qui s'était passé la nuit précédente parce que vous aviez bu ?",
                    question8Reponses,
                    question8ReponsesScore,
                    7),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "9. Vous êtes-vous blessé ou avez-vous blessé quelqu'un parce que vous aviez bu ?",
                    question9Reponses,
                    question9ReponsesScore,
                    8),
                SizedBox(
                  height: 20,
                ),
                carteQuestion(
                    "10. Est-ce qu'un ami, un médecin ou un autre professionnel de santé s'est déjà préoccupé de votre consommation d'alcool et vous a conseillé de la diminuer ?",
                    question10Reponses,
                    question10ReponsesScore,
                    9),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 500,
                  child: Divider(
                    height: 30,
                    thickness: 2,
                    color: couleurBeige,
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
                    Text((reponses[0] +
                            reponses[1] +
                            reponses[2] +
                            reponses[3] +
                            reponses[4] +
                            reponses[5] +
                            reponses[6] +
                            reponses[7] +
                            reponses[8] +
                            reponses[9])
                        .toString()),
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
                        "Un score >9 dans les deux sexes doit faire évoquer une dépendance")
                  ],
                ),
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
      width: 1000,
      child: Column(
        children: [
          Text(
            question1Titre,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          GroupButton(
            isRadio: true,
            options: GroupButtonOptions(
                mainGroupAlignment: MainGroupAlignment.spaceEvenly,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                spacing: 10,
                selectedColor: couleurBeige,
                buttonHeight: 40,
                textPadding: EdgeInsets.all(10)),
            onSelected: (index, isSelected) {
              setState(() {
                reponses[numeroQuestion] = question1ReponsesScores[index];
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

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Simple Alert"),
    content: Text(text),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
