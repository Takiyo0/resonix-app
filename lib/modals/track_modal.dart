import 'package:flutter/cupertino.dart';
import 'package:resonix/modals/playlists_modal.dart';
import 'package:resonix/pages/album.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/state/audio_state.dart';
import 'package:resonix/widgets/custom_image.dart';

class TrackModal {
  static void show(BuildContext currentContext, Map<String, dynamic> track,
      AudioState audioState, bool hideAlbum) {
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
                      _buildOptionTile(
                        icon: track["liked"] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        iconColor: const Color(0xFFFF77A8),
                        title: "Favorite",
                        onTap: () => likeTrack(setState),
                      ),
                      _buildOptionTile(
                        icon: Icons.queue_music,
                        title: "Add to queue",
                        onTap: () => audioState.addTracks(
                            [audioState.buildTrack(track, "Recommendation")]),
                      ),
                      _buildOptionTile(
                        icon: Icons.playlist_add,
                        title: "Add to Playlist",
                        onTap: () =>
                            PlaylistsModal.show(currentContext, track["id"]),
                      ),
                      if (!hideAlbum) _buildOptionTile(
                        icon: Icons.album,
                        title: "Go to album",
                        onTap: () async {
                          Navigator.pop(context);
                          await Future.delayed(
                              const Duration(milliseconds: 400));
                          if (!currentContext.mounted) return;
                          Navigator.of(currentContext).push(
                            CupertinoPageRoute(
                              builder: (ctx) => AlbumPage(id: track["albumid"]),
                            ),
                          );
                        },
                      ),
                      if (track["artists"] != null)
                        ...track["artists"]
                            .take(3)
                            .map((artist) => _buildOptionTile(
                                  icon: Icons.person,
                                  title: "Go to $artist",
                                  onTap: () {},
                                )),
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
          color: Colors.white.withOpacity(0.1),
          thickness: 0.3,
          indent: 12,
          endIndent: 12,
          height: 4, // Kurangi tinggi Divider agar lebih rapat
        ),
      ],
    );
  }
}
