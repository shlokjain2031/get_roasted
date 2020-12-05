import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get Roasted',
      home: GetRoasted(),
    );
  }
}

class GetRoasted extends StatefulWidget {

  @override
  _GetRoastedState createState() => _GetRoastedState();
}

class _GetRoastedState extends State<GetRoasted> {
  File _image;
  var _picker = ImagePicker();

  PageController ctrl = PageController(initialPage: 0);
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDEDED),
      body: FutureBuilder(
        future: RoastedRepo().getRoasts(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            List roasts = snapshot.data;
            String roast = roasts[Random().nextInt(757)];
            if(roast.length > 85) {
              roast = roasts[Random().nextInt(757)];
            }
            return Screenshot(
              controller: screenshotController,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    _image != null ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Image(
                          image: FileImage(_image),
                          fit: BoxFit.fill
                      ),
                    ) : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Image(
                          image: AssetImage('images/banana.jpg'),
                          fit: BoxFit.fill
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(height: 42),
                        Center(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * .9,
                              height: 150,
                              child: Text(
                                roast,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFEDEDED),
                                    height: 1.2,
                                    shadows: _outlinedText(strokeColor: Colors.black)
                                ),
                              )
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * (525/900),),
                        SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  roast = roasts[Random().nextInt(757)];
                                });
                              },
                              child: Icon(
                                Icons.shuffle,
                                size: 32,
                                color: Color(0xFFEDEDED),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _pickImage();
                              },
                              child: Image(
                                image: AssetImage('images/Plus.png'),
                                width: 64,
                                fit: BoxFit.fill,
                                color: Color(0xFFEDEDED),

                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                screenshotController.capture().then((value) {
                                  Share.shareFiles([value.path], subject: "Yep, roasted 'em", text: "Hey I roasted this guy using Get Roasted! Download it now!\nhttps://play.google.com/store/apps/details?id=com.jain.get_roasted");
                                });                                        },
                              child: Image(
                                image: AssetImage('images/Send.png'),
                                width: 32,
                                fit: BoxFit.fill,
                                color: Color(0xFFEDEDED),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          else {
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.width * .2),
                Center(
                  child: Image(
                    image: AssetImage('images/swipe.png'),
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width * .9,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'LOADING',
                    style: GoogleFonts.montserrat(
                      color: Color(0xFF121212).withOpacity(.3),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 5
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: Text(
                    'click on shuffle to get\na random roast',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                        color: Color(0xFF121212).withOpacity(.7),
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                    ),
                  ),
                )
              ],
            );
          }
        }
      ),
    );
  }

  _pickImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  /// Outlines a text using shadows.
  static List<Shadow> _outlinedText({double strokeWidth = 2, Color strokeColor = Colors.black, int precision = 5}) {
    Set<Shadow> result = HashSet();
    for (int x = 1; x < strokeWidth + precision; x++) {
      for(int y = 1; y < strokeWidth + precision; y++) {
        double offsetX = x.toDouble();
        double offsetY = y.toDouble();
        result.add(Shadow(offset: Offset(-strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(-strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
      }
    }
    return result.toList();
  }

}

class RoastedRepo {

  Future<List> getRoasts() async {
    LineSplitter lineSplitter = LineSplitter();
    // https://evilinsult.com/generate_insult.php?lang=en&amp;type=json #1 quote
    // https://ron-swanson-quotes.herokuapp.com/v2/quotes/109 #1 list of quotes
    // https://friends-quotes-api.herokuapp.com/quotes list of map {quote: ~~~, character: ~~~}
    // https://seinfeld-quotes.herokuapp.com/quotes list of maps {quote: ~~~}
    // original roasts
    List roasts = List();
    print("start");

    Response evilInsult = await get('https://evilinsult.com/generate_insult.php?lang=en&amp;type=json');
    String evilInsultString = evilInsult.body;
    print("evilInsult");

    Response ronSwanson = await get('https://ron-swanson-quotes.herokuapp.com/v2/quotes/109');
    List ronSwansonConverted = json.decode(ronSwanson.body);
    print("ronSwansonConverted");

    Response friends = await get('https://friends-quotes-api.herokuapp.com/quotes');
    List<String> friendsList = List();
    (json.decode(friends.body)).forEach((element) {
      friendsList.add(element["quote"]);
    });
    print("friendsList");

    Response seinfeld = await get('https://seinfeld-quotes.herokuapp.com/quotes');
    List<String> seinfeldList = List();
    (((json.decode(seinfeld.body)) as Map)["quotes"] as List).forEach((element) {
      seinfeldList.add(element["quote"]);
    });
    print("seinfeldList");

    String content = await rootBundle.loadString('images/roasts.txt');
    List<String> originalRoasts = lineSplitter.convert(content);
    print("originalRoasts");

    roasts.add(evilInsultString);
    roasts.addAll(ronSwansonConverted);
    roasts.addAll(friendsList);
    roasts.addAll(seinfeldList);
    roasts.addAll(originalRoasts);
    print("finished");

    roasts.shuffle();
    print("roasts: " + roasts.length.toString());

    return roasts;
  }

}

