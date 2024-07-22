import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class DurationState {
  final Duration progress;
  final Duration buffered;
  final Duration? total;

  const DurationState(
      {required this.progress, required this.buffered, this.total});
}

class AudioPlayerManager {
  AudioPlayerManager._internal();
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;
  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  String songUrl = "";

  void prepare({bool isNewSong = false}) {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
        (position, playbackEvent) => DurationState(
            progress: position,
            buffered: playbackEvent.bufferedPosition,
            total: playbackEvent.duration));
    if (isNewSong) {
      player.setUrl(songUrl);
    }
  }

  void updateSong(String url) {
    songUrl = url;
    prepare();
  }

  void dispose() {
    player.dispose();
  }
}
