import 'package:flutter/material.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/custom_image.dart';

enum PlaylistModalType { add, remove }

class PlaylistsModal {
  static Future<void> show(BuildContext currentContext, String trackId) async {
    Future<Map<String, dynamic>?> load() async {
      var response = await ApiService.getUserPlaylists(false);
      if (!currentContext.mounted) return null;
      if (response != null && response["error"] != null) {
        ApiService.returnError(currentContext, response["error"]);
        return null;
      } else if (response == null) {
        await ApiService.returnTokenExpired(currentContext);
        return null;
      }
      return response;
    }

    Future<void> modifyTrackOnPlaylist(
      BuildContext context,
      String playlistId,
      PlaylistModalType actionType,
      Function(bool) isInPlaylist,
    ) async {
      var response = await (actionType == PlaylistModalType.add
          ? ApiService.addTrackToPlaylist(playlistId, trackId)
          : ApiService.removeTrackFromPlaylist(playlistId, trackId));

      if (!context.mounted) return;
      if (response != null) {
        if (response["error"] != null) {
          return ApiService.returnError(context, response["error"]);
        }
        if (response["tracks"] != null) {
          isInPlaylist(
              response["tracks"].any((track) => track["id"] == trackId));
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
        maxHeight: MediaQuery.of(currentContext).size.height * 0.5,
        minWidth: MediaQuery.of(currentContext).size.width,
      ),
      backgroundColor: const Color(0xFF150825),
      builder: (BuildContext ctx) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: load(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text("Failed to load playlists"));
            }

            var playlists = snapshot.data!["playlists"] as List?;

            if (playlists == null || playlists.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No playlists found",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            List<List<String>> trackIds = playlists
                .map((playlist) =>
                    List<String>.from(playlist["trackids"] as List))
                .toList();

            return StatefulBuilder(builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar for modal
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((255 * 0.3).toInt()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Select playlist",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          var playlistId = playlists[index]["id"];
                          var playlistName = playlists[index]["name"];

                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            leading: CustomImage(
                              imageUrl:
                                  '${ApiService.baseUrl}/storage/cover/playlist/$playlistId',
                              height: 60,
                              width: 60,
                            ),
                            title: Text(
                              playlistName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                trackIds[index].contains(trackId)
                                    ? Icons.check_circle
                                    : Icons.add_circle,
                                color: Colors.white,
                                key:
                                    ValueKey(trackIds[index].contains(trackId)),
                              ),
                            ),
                            onTap: () async {
                              PlaylistModalType actionType =
                                  trackIds[index].contains(trackId)
                                      ? PlaylistModalType.remove
                                      : PlaylistModalType.add;

                              await modifyTrackOnPlaylist(
                                  context, playlistId, actionType,
                                  (inPlaylist) {
                                setState(() {
                                  if (inPlaylist) {
                                    trackIds[index].add(trackId);
                                  } else {
                                    trackIds[index].remove(trackId);
                                  }
                                });
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }
}
