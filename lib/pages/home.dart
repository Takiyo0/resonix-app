import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:resonix/main.dart';
import 'package:resonix/modals/album_modal.dart';
import 'package:resonix/modals/track_modal.dart';
import 'package:resonix/pages/album.dart';
import 'package:resonix/pages/playlist.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/custom_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomeStatefulPage();
}

class HomeStatefulPage extends State<HomePage> {
  dynamic _trackData;
  dynamic _albumData;
  dynamic _playlistData;
  bool error = false;
  dynamic nowPlaying;
  dynamic user;

  Future<void> getUser() async {
    final response = await ApiService.getUser();
    if (response != null) {
      setState(() {
        user = response?["user"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    getUser();
  }

  Future<void> _fetchData() async {
    var data = await ApiService.getRecommendations();
    if (!mounted) return;
    if (data != null && data.containsKey("error")) {
      setState(() {
        error = true;
      });
    } else if (data != null) {
      setState(() {
        _trackData = data["tracks"];
        _albumData = data["albums"];
        _playlistData = data["playlists"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = context.watch<AudioState>();

    audioState.player.playerStateStream.distinct().listen((state) {
      final currentTrack = audioState.player.sequenceState?.currentSource?.tag;

      if (nowPlaying?.title != currentTrack?.title) {
        setState(() {
          nowPlaying = currentTrack;
        });
      }
    });

    Future onTap(dynamic data, String type) async {
      if (type == "album") {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) => AlbumPage(id: data["id"])),
        );
      } else if (type == "playlist") {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) => PlaylistPage(id: data["id"])),
        );
      }
      if (type != "track") return;
      try {
        await audioState.play(audioState.buildTrack(data, "home"), true);
      } catch (e, stack) {}
    }

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
              'Hello, ${user?["nickname"] ?? user?["username"] ?? "User"}',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          centerTitle: false,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        body: Container(
          child: error
              ? Center(
                  child: const Text('Error fetching data',
                      style: TextStyle(color: Colors.red)))
              : (_trackData == null ||
                      _albumData == null ||
                      _playlistData == null)
                  ? Center(child: const CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 16.0, right: 16.0, bottom: 80.0),
                      children: [
                        const Text("Tracks",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        _buildList(_trackData, "track", nowPlaying,
                            (item) => onTap(item, "track"), audioState),
                        const SizedBox(height: 20),
                        const Text("Albums",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        _buildList(_albumData, "album", nowPlaying,
                            (item) => onTap(item, "album"), audioState),
                        const SizedBox(height: 20),
                        const Text("Playlists",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        _buildList(_playlistData, "playlist", nowPlaying,
                            (item) => onTap(item, "playlist"), audioState),
                      ],
                    ),
        ));
  }
}

Widget _buildList(List<dynamic> data, String type, dynamic nowPlaying,
    ValueChanged<dynamic> onTap, AudioState audioState) {
  return SizedBox(
    height: 210,
    child: data.isEmpty
        ? Center(
            child:
                Text("No $type found", style: TextStyle(color: Colors.white)),
          )
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              var item = data[index];
              return Container(
                  width: 150,
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Color(0xFF28123E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                        onTap:
                            nowPlaying != null && nowPlaying?.id == item["id"]
                                ? null
                                : () => onTap(item),
                        onLongPress: () {
                          if (type == "track") {
                            TrackModal.show(
                                context,
                                [
                                  TrackModalAction.favorite,
                                  TrackModalAction.queue,
                                  TrackModalAction.playlistAdd,
                                  TrackModalAction.album,
                                  TrackModalAction.artist
                                ],
                                item,
                                audioState,
                                null,
                                null);
                          } else if (type == "album") {
                            AlbumModal.show(
                                context,
                                [
                                  AlbumModalAction.favorite,
                                  AlbumModalAction.queue,
                                  AlbumModalAction.artist
                                ],
                                item,
                                audioState,
                                null,
                                null);
                          }
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        splashColor: Colors.white.withOpacity(0.2),
                        highlightColor: Colors.white.withOpacity(0.1),
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      CustomImage(
                                          imageUrl:
                                              '${ApiService.baseUrl}/storage/cover/$type/${item["id"]}',
                                          height: 150,
                                          width: 150),
                                      Visibility(
                                          visible: nowPlaying != null &&
                                              (nowPlaying?.extras?["albumId"] ==
                                                      item["id"] ||
                                                  nowPlaying?.id == item["id"]),
                                          child: Positioned(
                                              bottom: 7,
                                              right: 7,
                                              child: Container(
                                                width: 35,
                                                height: 35,
                                                decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: SpinKitWave(
                                                  color: Colors.white,
                                                  size: 15.0,
                                                  type: SpinKitWaveType.center,
                                                ),
                                              )))
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(item["name"],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  item["artists"]
                                          ?.map((artist) => artist.toString())
                                          .join(", ") ??
                                      item["ownername"] ??
                                      "Unknown",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 12)),
                            ],
                          ),
                        )),
                  ));
            },
          ),
  );
}
