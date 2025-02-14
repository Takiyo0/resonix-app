import 'package:flutter/cupertino.dart';
import 'package:resonix/modals/playlists_modal.dart';
import 'package:resonix/pages/album.dart';
import 'package:resonix/pages/user.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/state/audio_state.dart';
import 'package:resonix/widgets/custom_image.dart';

enum TrackModalAction {
  favorite,
  queue,
  playlistAdd,
  playlistRemove,
  album,
  artist,
}

class TrackModal {
  static void show(
      BuildContext currentContext,
      List<TrackModalAction> actions,
      Map<String, dynamic> track,
      AudioState audioState,
      Function? refresh,
      String? playlistId) {
    Future<void> likeTrack(Function updateState) async {
      var response = await ApiService.likeTrack(track["id"]);
      if (!currentContext.mounted) return;
      if (response != null) {
        if (response["error"] != null) {
          return ApiService.returnError(currentContext, response["error"]);
        }
        updateState(() {
          track["liked"] = response["liked"];
        });
      } else {
        await ApiService.returnTokenExpired(currentContext);
      }
    }

    Future<void> removeTrackFromPlaylist(BuildContext context) async {
      if (playlistId == null) return;
      var response =
          await ApiService.removeTrackFromPlaylist(playlistId, track["id"]);
      if (!currentContext.mounted) return;
      if (context.mounted) Navigator.pop(context);
      if (response != null) {
        if (response["error"] != null) {
          return ApiService.returnError(currentContext, response["error"]);
        }
      } else {
        await ApiService.returnTokenExpired(currentContext);
      }
    }

    showModalBottomSheet<void>(
      context: currentContext,
      useRootNavigator: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(currentContext).size.height * 0.7),
      backgroundColor: const Color(0xFF150825),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255 * 0.3).toInt()),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        CustomImage(
                            imageUrl:
                                '${ApiService.baseUrl}/storage/cover/track/${track["id"]}',
                            height: 100,
                            width: 100),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Track",
                                    softWrap: true,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                        fontSize: 12)),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(track["name"],
                                    softWrap: true,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontSize: 20)),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  track["artists"]
                                      ?.map((artist) => artist.toString())
                                      .join(", "),
                                  softWrap: true,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Column(
                    children: [
                      if (actions.contains(TrackModalAction.favorite))
                        _buildOptionTile(
                          icon: track["liked"] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          iconColor: const Color(0xFFFF77A8),
                          title: "Favorite",
                          onTap: () => likeTrack(setState),
                        ),
                      if (actions.contains(TrackModalAction.queue))
                        _buildOptionTile(
                          icon: Icons.queue_music,
                          title: "Add to queue",
                          onTap: () => audioState.addTracks(
                              [audioState.buildTrack(track, "Recommendation")],
                              false),
                        ),
                      if (actions.contains(TrackModalAction.playlistAdd) ||
                          actions.contains(TrackModalAction.playlistRemove))
                        _buildOptionTile(
                          icon: Icons.playlist_add,
                          title:
                              actions.contains(TrackModalAction.playlistRemove)
                                  ? "Remove from Playlist"
                                  : "Add to Playlist",
                          onTap: () =>
                              actions.contains(TrackModalAction.playlistRemove)
                                  ? refresh != null
                                      ? () async {
                                          await removeTrackFromPlaylist(ctx);
                                          refresh();
                                        }()
                                      : null
                                  : PlaylistsModal.show(
                                      currentContext, track["id"]),
                        ),
                      if (actions.contains(TrackModalAction.album))
                        _buildOptionTile(
                          icon: Icons.album,
                          title: "Go to album",
                          onTap: () async {
                            Navigator.pop(context);
                            await Future.delayed(
                                const Duration(milliseconds: 400));
                            if (!currentContext.mounted) return;
                            Navigator.of(currentContext).push(
                              CupertinoPageRoute(
                                builder: (ctx) =>
                                    AlbumPage(id: track["albumid"]),
                              ),
                            );
                          },
                        ),
                      if (track["artists"] != null &&
                          actions.contains(TrackModalAction.artist))
                        ...track["artists"].asMap().entries.take(3).map(
                          (entry) {
                            int index = entry.key;
                            String artist = entry.value;

                            return _buildOptionTile(
                              icon: Icons.person,
                              title: "Go to $artist",
                              onTap: () async {
                                Navigator.pop(context);
                                await Future.delayed(
                                    const Duration(milliseconds: 400));
                                if (!currentContext.mounted) return;
                                Navigator.of(currentContext).push(
                                  CupertinoPageRoute(
                                    builder: (ctx) => UserPage(
                                      id: track["artistids"]?[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildOptionTile({
    required IconData icon,
    required String title,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              dense: true,
              leading: Icon(icon, color: iconColor, size: 24),
              title: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
        Divider(
          color: Colors.white.withAlpha((255 * 0.1).toInt()),
          thickness: 0.3,
          indent: 12,
          endIndent: 12,
          height: 4,
        ),
      ],
    );
  }
}
