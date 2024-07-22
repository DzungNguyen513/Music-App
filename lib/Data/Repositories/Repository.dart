
import 'package:music_app/Data/Models/Song.dart';
import 'package:music_app/Data/Source/Source.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
}

class DefaultRepository implements Repository {
  final localDataSource = LocalDataSource();
  final remoteDataSource = RemoteDataSource();
  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    await remoteDataSource.loadData().then((remoteSongs) {
      if(remoteSongs == null) {
        localDataSource.loadData().then((localSongs) {
          if(localSongs != null) {
            songs.addAll(localSongs);
          }
        });
      }
      else {
        songs.addAll(remoteSongs);
      }
    });
    return songs;
  }

}