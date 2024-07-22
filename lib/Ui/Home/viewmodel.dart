import 'dart:async';

import 'package:music_app/Data/Repositories/Repository.dart';

class MusicAppViewModel {
  StreamController songStream = StreamController();

  void loadSong() {
    final repository = DefaultRepository();

    repository.loadData().then((value) => songStream.add(value!));
  }
}
