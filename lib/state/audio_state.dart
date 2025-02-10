import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:resonix/services/api_service.dart';

export 'package:flutter/material.dart';
export 'package:just_audio/just_audio.dart';
export 'package:just_audio_background/just_audio_background.dart';
export 'package:provider/provider.dart';
export 'package:resonix/state/audio_state.dart';

class AudioState extends ChangeNotifier {
  late AudioPlayer player;
  ConcatenatingAudioSource? playlist;

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

  Future<void> play(UriAudioSource track, bool replace) async {
    if (playlist == null || replace) {
      playlist = ConcatenatingAudioSource(children: [track]);
      await player.setAudioSource(track);
    } else {
      playlist!.add(track);
    }
    player.play();
    notifyListeners();
  }

  Future<void> playAll(
      List<UriAudioSource> tracks, bool replace, int? index) async {
    if (playlist == null || replace) {
      playlist = ConcatenatingAudioSource(children: tracks);
      if (index != null) {
        await player.setAudioSource(playlist!, initialIndex: index);
      } else {
        await player.setAudioSource(playlist!);
      }
    } else {
      playlist!.addAll(tracks);
    }
    player.play();
    notifyListeners();
  }

  Future<void> addTracks(List<UriAudioSource> tracks) async {
    if (playlist == null) {
      playlist = ConcatenatingAudioSource(children: tracks);
      player.setAudioSource(playlist!);
      player.play();
    } else {
      playlist!.addAll(tracks);
    }

    notifyListeners();
  }

  UriAudioSource buildTrack(dynamic track, String source) {
    return AudioSource.uri(
      Uri.parse('${ApiService.baseUrl}/storage/track/${track["id"]}'),
      tag: MediaItem(
        id: track["id"].toString(),
        album: track['albumname'] ?? 'Unknown Album',
        artist: (track['artists'] as List?)
                ?.map((artist) => artist.toString())
                .join(", ") ??
            'Unknown Artist',
        title: track['name'] ?? 'Unknown Title',
        extras: {"albumId": track["albumid"], "source": source},
        artUri: Uri.parse(
            '${ApiService.baseUrl}/storage/cover/track/${track["id"]}'),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }
}
