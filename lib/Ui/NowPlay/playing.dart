import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/Data/Models/Song.dart';
import 'package:music_app/Ui/NowPlay/audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});
  final List<Song> songs;
  final Song playingSong;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(songs: songs, playingSong: playingSong);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.songs, required this.playingSong});
  final List<Song> songs;
  final Song playingSong;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;
  late int selectedItemIndex;
  late Song _song;
  late double _currentAnimationPosition;
  late bool _isShuffe;
  late LoopMode _loopMode;
  @override
  void initState() {
    super.initState();
    _currentAnimationPosition = 0.0;
    _song = widget.playingSong;
    _isShuffe = false;
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager();
    if (_audioPlayerManager.songUrl.compareTo(_song.source) != 0) {
      _audioPlayerManager.updateSong(_song.source);
      _audioPlayerManager.prepare(isNewSong: true);
    } else {
      _audioPlayerManager.prepare(isNewSong: false);
    }
    selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    _loopMode = LoopMode.off;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Now Playing'),
          trailing:
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ),
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(_song.album),
                const SizedBox(
                  height: 16,
                ),
                const Text('_ ___ _'),
                const SizedBox(height: 48),
                RotationTransition(
                  turns:
                      Tween(begin: 0.0, end: 1.0).animate(_imageAnimController),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/ITunes_12.2_logo.png',
                      image: _song.image,
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/ITunes_12.2_logo.png',
                          height: screenWidth - delta,
                          width: screenWidth - delta,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 64,
                    bottom: 16,
                  ),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Column(
                          children: [
                            Text(
                              _song.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              _song.artist,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_outline_sharp),
                          color: Theme.of(context).colorScheme.primary,
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 32, left: 24, right: 24, bottom: 16),
                  child: _progressBar(),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 32, left: 24, right: 24, bottom: 16),
                  child: _mediaButton(),
                )
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _imageAnimController.dispose();
    super.dispose();
  }

  Widget _mediaButton() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
            function: setShuffle,
            icon: Icons.shuffle,
            color: _getShuffleColor(),
            size: 24,
          ),
          MediaButtonControl(
            function: _setPreSong,
            icon: Icons.skip_previous,
            color: Colors.deepPurple,
            size: 36,
          ),
          _playButton(),
          MediaButtonControl(
            function: _setNextSong,
            icon: Icons.skip_next,
            color: Colors.deepPurple,
            size: 36,
          ),
          MediaButtonControl(
            function: _setRepeatOtion,
            icon: _repeatIcon(),
            color: _getRepeatingIconColor(),
            size: 24,
          ),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: _audioPlayerManager.player.seek,
            barHeight: 5.0,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.grey.withOpacity(0.3),
            progressBarColor: Colors.green,
            bufferedBarColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.deepPurple,
            thumbGlowColor: Colors.green.withOpacity(0.3),
            thumbRadius: 10.0,
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState = snapshot.data;
          final processingState = playState?.processingState;
          final playing = playState?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pauseRotationAnim();
            });
            return Container(
              margin: const EdgeInsets.all(8),
              height: 48,
              width: 48,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.play();
              },
              icon: Icons.play_arrow_sharp,
              color: null,
              size: 48,
            );
          } else if (processingState != ProcessingState.completed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _playRotationAnim();
            });
            return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.pause();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _pauseRotationAnim();
                });
              },
              icon: Icons.pause,
              color: null,
              size: 48,
            );
          } else {
            if (processingState == ProcessingState.completed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _stopRotationAnim();
                _resetRotationAnim();
              });
            }
            return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.seek(Duration.zero);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _resetRotationAnim();
                  _playRotationAnim();
                });
              },
              icon: Icons.replay,
              color: null,
              size: 48,
            );
          }
        });
  }

  void setShuffle() {
    setState(() {
      _isShuffe = !_isShuffe;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffe ? Colors.deepPurple : Colors.grey;
  }

  void _setNextSong() {
    if (_isShuffe) {
      var random = Random();
      selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (selectedItemIndex < widget.songs.length - 1) {
      ++selectedItemIndex;
    } else if (_loopMode == LoopMode.all &&
        selectedItemIndex == widget.songs.length - 1) {
      selectedItemIndex = 0;
    }

    if (selectedItemIndex >= widget.songs.length) {
      selectedItemIndex = selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[selectedItemIndex];
    _audioPlayerManager.updateSong(nextSong.source);
    _resetRotationAnim();
    setState(() {
      _song = nextSong;
    });
  }

  void _setPreSong() {
    if (_isShuffe) {
      var random = Random();
      selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (selectedItemIndex > 0) {
      --selectedItemIndex;
    } else if (_loopMode == LoopMode.all && selectedItemIndex == 0) {
      selectedItemIndex = widget.songs.length - 1;
    }
    if (selectedItemIndex < 0) {
      selectedItemIndex = (-1 * selectedItemIndex) % widget.songs.length;
    }
    final preSong = widget.songs[selectedItemIndex];
    _audioPlayerManager.updateSong(preSong.source);
    _resetRotationAnim();
    setState(() {
      _song = preSong;
    });
  }

  void _setRepeatOtion() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  IconData _repeatIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  Color? _getRepeatingIconColor() {
    return _loopMode == LoopMode.off ? Colors.grey : Colors.deepPurple;
  }

  void _playRotationAnim() {
    _imageAnimController.forward(from: _currentAnimationPosition);
    _imageAnimController.repeat();
  }

  void _stopRotationAnim() {
    _imageAnimController.stop();
  }

  void _pauseRotationAnim() {
    _stopRotationAnim();
    _currentAnimationPosition = _imageAnimController.value;
  }

  void _resetRotationAnim() {
    _currentAnimationPosition = 0.0;
    _imageAnimController.value = _currentAnimationPosition;
  }
}

class MediaButtonControl extends StatefulWidget {
  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    this.size,
    this.color,
  });

  @override
  State<StatefulWidget> createState() {
    return _MediaButtonControlState();
  }
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      color: widget.color ?? Theme.of(context).colorScheme.primary,
      iconSize: widget.size,
    );
  }
}
