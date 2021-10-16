import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped }

class SpeechSingleton {
  static final SpeechSingleton _singleton = SpeechSingleton._internal();

  FlutterTts flutterTts;
  int unfinished = 0;

  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;

  factory SpeechSingleton() {
    return _singleton;
  }

  SpeechSingleton._internal() {
    _initTts();
  }

  void _initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-Us");
    //flutterTts.setVoice("en-us-x-sfg#male_1-local");

    flutterTts.setStartHandler(() {
      ttsState = TtsState.playing;
    });

    flutterTts.setCompletionHandler(() {
      ttsState = TtsState.stopped;
    });

    flutterTts.setErrorHandler((msg) {
      ttsState = TtsState.stopped;
    });
  }

  Future<dynamic> setVolume(newVolume) async => flutterTts.setVolume(newVolume);

  Future<dynamic> setSpeechRate(newRate) async =>
      flutterTts.setSpeechRate(newRate);

  Future<dynamic> setPitch(newPitch) async => flutterTts.setPitch(newPitch);

  void speak(sentence) async {
    if (unfinished > 2) return;

    if (sentence != null && sentence.isNotEmpty) {
      unfinished++;
      var result = await flutterTts.speak(sentence);
      if (result == 1) {
        ttsState = TtsState.playing;
      }
    }

    flutterTts.setCompletionHandler(() async {
      unfinished--;
    });
  }

  void stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      ttsState = TtsState.stopped;
    }
  }
}
