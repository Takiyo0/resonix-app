import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:intl/intl.dart';
import 'package:resonix/main.dart';
import 'package:resonix/modals/track_modal.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/services/helper.dart';
import 'package:resonix/widgets/custom_image.dart';
import 'package:resonix/widgets/skeleton_widget.dart';

class ArtistTracks extends StatefulWidget {
  final String artistId;

  const ArtistTracks({super.key, required this.artistId});

  @override
  ArtistTracksState createState() => ArtistTracksState();
}

class ArtistTracksState extends State<ArtistTracks> {
  dynamic data;
  dynamic tracks;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadTracks();
  }

  Future<void> loadUser() async {
    var artist = await ApiService.getArtist(widget.artistId);
    if (!mounted) return;
    if (artist != null) {
      if (artist["error"] != null) {
        return ApiService.returnError(context, artist["error"]);
      }
      setState(() {
        data = artist["artist"];
      });
    } else {
      await ApiService.returnTokenExpired(context);
    }
  }

  Future<void> loadTracks() async {
    var trackList = await ApiService.getArtistTracks(widget.artistId);
    if (!mounted) return;
    if (trackList != null) {
      if (trackList["error"] != null) {
        return ApiService.returnError(context, trackList["error"]);
      }
      setState(() {
        tracks = trackList["tracks"];
      });
    } else {
      await ApiService.returnTokenExpired(context);
    }
  }

  void _handleTap(BuildContext context, dynamic item, AudioState audioState) {
    Haptics.vibrate(HapticsType.light);

    int index = tracks.indexWhere((track) => track["id"] == item["id"]);
    if (index == -1) index = 0;
    var tracks0 = tracks
        .map((e) => audioState.buildTrack(
            e, data?["nickname"] ?? data?["username"] ?? "Artist"))
        .toList()
        .cast<UriAudioSource>();
    audioState.playAll(tracks0, true, index);
  }

  void _handleLongPress(
      BuildContext context, dynamic item, AudioState audioState) {
    Haptics.vibrate(HapticsType.medium);

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              return true;
            },
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF4A236F),
                        Color(0xFF321C4C),
                        Color(0xFF1A0E2E),
                        Color(0xFF12071B),
                      ],
                      stops: [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[800],
                                  ),
                                  child: ClipOval(
                                    child: data == null
                                        ? SkeletonContainer(
                                            width: 50,
                                            height: 50,
                                            shape: BoxShape.circle)
                                        : (data["avatarid"] != null
                                            ? Image.network(
                                                '${ApiService.baseUrl}/storage/avatar/${data["avatarid"]}',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Icon(
                                                  Icons.person,
                                                  color: Colors.white54,
                                                  size: 30,
                                                ),
                                              )
                                            : Icon(Icons.person,
                                                color: Colors.white54,
                                                size: 30)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    data == null
                                        ? SkeletonContainer(
                                            width: 120, height: 20)
                                        : Text(
                                            data["nickname"] ??
                                                data["username"] ??
                                                "Unknown User",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.group,
                                            size: 14, color: Colors.grey[400]),
                                        const SizedBox(width: 4),
                                        data == null
                                            ? SkeletonContainer(
                                                width: 40, height: 14)
                                            : Text(
                                                '${data["followercount"]} followers',
                                                style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 14),
                                              ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.library_music,
                                            size: 14, color: Colors.grey[400]),
                                        const SizedBox(width: 4),
                                        data == null
                                            ? SkeletonContainer(
                                                width: 40, height: 14)
                                            : Text(
                                                '${data["trackcount"]} tracks',
                                                style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 14),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionTitle("Tracks"),
                                    tracks == null
                                        ? _buildSkeletonList()
                                        : _buildTrackList(context),
                                    const SizedBox(height: 90),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTrackList(BuildContext context) {
    final audioState = context.watch<AudioState>();
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        var track = tracks[index];

        return StreamBuilder(
          stream: audioState.player.sequenceStateStream,
          builder: (ctx, snapshot) {
            final nowPlaying = snapshot.data?.currentSource?.tag as MediaItem?;
            final isThis = nowPlaying?.id == track["id"];
            return GestureDetector(
              onTap: () =>
                  isThis ? null : _handleTap(context, track, audioState),
              onLongPress: () => _handleLongPress(context, track, audioState),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF28123E),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.3).toInt()),
                        blurRadius: 4)
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImage(
                        imageUrl:
                            '${ApiService.baseUrl}/storage/cover/track/${track["id"]}',
                        height: 60,
                        width: 60,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(track["name"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              if (track["explicit"] == true) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.explicit,
                                    color: Colors.red, size: 18),
                              ],
                            ],
                          ),
                          Text(track["artists"].join(", "),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 12)),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                  Helper.formatDuration(
                                      (track?["durationms"] ?? 0).round()),
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 12)),
                              const SizedBox(width: 12),
                              Icon(Icons.headset, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                NumberFormat.compact()
                                    .format(track["listencount"]),
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isThis
                        ? SpinKitWave(
                            color: Colors.green,
                            size: 15.0,
                            type: SpinKitWaveType.center,
                          )
                        : Icon(Icons.more_vert, color: Colors.white70),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    return Column(
      children: List.generate(
          5, (index) => _buildSkeletonItem(width: double.infinity, height: 60)),
    );
  }

  Widget _buildSkeletonItem({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
