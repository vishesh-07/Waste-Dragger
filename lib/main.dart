import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:waste_dragger/data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste Dragger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WasteDragger(),
    );
  }
}

class WasteDragger extends StatefulWidget {
  const WasteDragger({Key? key}) : super(key: key);

  @override
  _WasteDraggerState createState() => _WasteDraggerState();
}

class _WasteDraggerState extends State<WasteDragger> {
  int score = 0, chances = 3;
  final List<Waste> wasteProducts = wasteProductList..shuffle();
  final List lifes = List.filled(3, 'assets/heart.png');
  late AudioPlayer player;
  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Waste Dragger',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, right: 4.0, bottom: 8.0, left: 8.0),
                      child: SizedBox(
                          width: _size.width * .1,
                          height: _size.height * .1,
                          child: Image.asset('assets/heart.png')),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, right: 8.0, bottom: 8.0, left: 4.0),
                      child: Text(
                        '$chances',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, right: 4.0, bottom: 8.0, left: 8.0),
                      child: SizedBox(
                          width: _size.width * .1,
                          height: _size.height * .1,
                          child: Image.asset('assets/points.png')),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, right: 8.0, bottom: 8.0, left: 4.0),
                      child: Text(
                        '$score',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // animatedText()
            wasteProducts.isNotEmpty
                ? Stack(
                    alignment: Alignment.center,
                    children: wasteProducts
                        .map((waste) => DraggableWidget(waste: waste))
                        .toList(),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * .3,
                    width: MediaQuery.of(context).size.width * .95,
                  ),
            const Spacer(),
            buildTargets(context),
          ],
        ),
      ),
    );
  }

  Widget buildTargets(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildTarget(context,
              text: 'assets/dry.png', acceptType: wasteTypes.dry),
          buildTarget(context,
              text: 'assets/wet.png', acceptType: wasteTypes.wet),
          buildTarget(context,
              text: 'assets/e.png', acceptType: wasteTypes.ewaste),
        ],
      );
  animatedText(BuildContext context, lst) => Center(
        child: DefaultTextStyle(
          style: GoogleFonts.stylish(fontSize: 70.0, color: Colors.blue),
          child: AnimatedTextKit(
            animatedTexts: [
              for (var i in lst) (WavyAnimatedText(i)),
            ],
            repeatForever: true,
          ),
        ),
      );
  Widget buildTarget(BuildContext context,
          {required String text, required wasteTypes acceptType}) =>
      DragTarget<Waste>(
        builder: (context, acceptedData, rejectedData) => SizedBox(
          width: MediaQuery.of(context).size.width * .2,
          height: MediaQuery.of(context).size.height * .3,
          child: Image.asset(text),
        ),
        onWillAccept: (data) =>
            chances != 0 || wasteProducts.isNotEmpty ? true : false,
        onAccept: (data) {
          if (data.wt == acceptType) {
            player.setAsset('assets/audio/correct.mp3');
            player.play();
            setState(() {
              score += 10;
              wasteProducts
                  .removeWhere((element) => element.imageURL == data.imageURL);
            });
            if (wasteProducts.isEmpty) {
              showAlertDialog(context, true);
            }
          } else {
            player.setAsset('assets/audio/wrong.mp3');
            player.play();
            setState(() {
              score -= 5;
              chances--;
            });
            // animatedText(context);
            if (chances == 0) {
              showAlertDialog(context, false);
            }
          }
        },
      );
  showAlertDialog(BuildContext context, won) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Quit"),
      onPressed: () {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
      },
    );
    AlertDialog alert = AlertDialog(
      title: won
          ? animatedText(context, ['You', 'Won', 'The', 'Game'])
          : animatedText(context, ['You', 'Lost']),
      actions: [
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class DraggableWidget extends StatelessWidget {
  final Waste waste;
  const DraggableWidget({Key? key, required this.waste}) : super(key: key);
  @override
  Widget build(BuildContext context) => Draggable<Waste>(
        child: getWasteImage(MediaQuery.of(context).size.height * .3,
            MediaQuery.of(context).size.width * .95),
        feedback: getWasteImage(MediaQuery.of(context).size.height * .2,
            MediaQuery.of(context).size.width * .4),
        data: waste,
        childWhenDragging: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * .3,
        ),
      );
  Widget getWasteImage(height, width) => Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Image.asset(
          waste.imageURL,
          fit: BoxFit.cover,
          height: height,
          width: width,
        ),
      );
}
