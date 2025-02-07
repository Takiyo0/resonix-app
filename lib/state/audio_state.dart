import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

export 'package:flutter/material.dart';
export 'package:just_audio/just_audio.dart';
export 'package:just_audio_background/just_audio_background.dart';
export 'package:provider/provider.dart';
export 'package:resonix/state/audio_state.dart';

class AudioState extends ChangeNotifier {
  late AudioPlayer player;

  AudioState() {
    _init();
  }

  Future<void> _init() async {
    player = AudioPlayer();
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }
}
