import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vision_aid/ui/home_view.dart';
import 'settings.dart';

class SpeechRecognitionPage extends StatefulWidget {
  SpeechRecognitionPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _SpeechRecognitionPageState createState() => _SpeechRecognitionPageState();
}

class _SpeechRecognitionPageState extends State<SpeechRecognitionPage> {
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  bool _hasSpeech = false;

  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = '';
  final SpeechToText speech = SpeechToText();

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);

    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void startListening() {
    _text = "started";
    lastError = "";
    speech.listen(onResult: resultListener);
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);

    setState(() {
      _isListening = true;
    });
  }

  void stopListening() {
    speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      if (result.recognizedWords == _text) {
        return;
      }

      _text = result.recognizedWords;
      var tmp = _text.toLowerCase();
      if (tmp.contains("object") &&
          (tmp.contains("detection") ||
              tmp.contains("recognition") ||
              tmp.contains("detect") ||
              tmp.contains("recognizer"))) {
        stopListening();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeView()));
      }

      if (tmp.contains("settings")) {
        stopListening();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SettingPage(title: "Settings")));
      }

      _confidence = result.confidence;

      if (result.finalResult) {
        _isListening = false;
      }
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = "$status";
    });
  }

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  //static AudioCache player = new AudioCache();
  FlutterTts tts = FlutterTts();
  var speech_input = "Hello, how can I help?";

  Map<String, HighlightedWord> words = {
    'Object Detector': HighlightedWord(
      onTap: () {
        print('Object Detector');
      },
      textStyle: TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'Object Recognition': HighlightedWord(
      onTap: () {
        print('Object Recognition');
      },
      textStyle: TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'Text Recognition': HighlightedWord(
      onTap: () {
        print('Text Recognition');
      },
      textStyle: TextStyle(
        color: Colors.indigoAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'Letter Recognition': HighlightedWord(
      onTap: () {
        print('Letter Recognition');
      },
      textStyle: TextStyle(
        color: Colors.indigoAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'Settings': HighlightedWord(
      onTap: () {
        print('Settings');
      },
      textStyle: TextStyle(
        color: Colors.deepPurpleAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  double _confidence = 1.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${lastStatus} [${(_confidence * 100.0).toStringAsFixed(1)}%]'),
      ),

      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //floatingActionButton: AvatarGlow(
      //animate: _isListening,
      //glowColor: Theme.of(context).primaryColor,
      //endRadius: 75.0,
      //duration: const Duration(milliseconds: 2000),
      //repeatPauseDuration: const Duration(milliseconds: 100),
      //repeat: true,
      //child: FloatingActionButton(
      //onPressed: _listen,
      //child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      //),
      //),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 70,
              child: Container(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
                    child: TextHighlight(
                      text: _text,
                      words: words,
                      textStyle: TextStyle(
                        fontSize: 32.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 30,
                child: Container(
                  //width: double.infinity,
                  margin:
                      EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 35),
                  child: SizedBox(
                      height: 125, //height of button
                      width: 400, //width of button
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary:
                                Colors.blueAccent, //background color of button
                            side: BorderSide(
                                width: 3,
                                color:
                                    Colors.lightBlue), //border width and color
                            elevation: 10, //elevation of button
                            shape: RoundedRectangleBorder(
                                //to set border radius to button
                                borderRadius: BorderRadius.circular(30)),
                            padding: EdgeInsets.all(
                                20) //content padding inside button
                            ),
                        onPressed: () async {
                          //playAudio();
                          //_listen();
                          if (!_isListening) {
                            startListening();
                          } else {
                            stopListening();
                          }
                        },
                        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      )),
                )),
          ],
        ),
      ),
    );
  }

  //void playAudio() {
  //player.play(listeningPath);
  //}

}
