import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:resonix/main.dart';
import 'package:resonix/pages/playlist.dart';
import 'package:resonix/pages/user/followers.dart';
import 'package:resonix/pages/user/following.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/skeleton_widget.dart';

class UserPage extends StatefulWidget {
  final String? id;

  const UserPage({super.key, this.id});

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  dynamic data;
  dynamic playlists;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadPlaylists();
  }

  Future<void> loadUser() async {
    var user = await ApiService.getPublicUser(
        widget.id == null || widget.id!.isEmpty ? "null" : widget.id!);
    if (!mounted) return;
    if (user != null) {
      if (user["error"] != null) {
        return ApiService.returnError(context, user["error"]);
      }
      setState(() {
        data = user["user"];
      });
    } else {
      await ApiService.returnTokenExpired(context);
    }
  }

  Future<void> loadPlaylists() async {
    var albums = await ApiService.getUserPlaylist(
        widget.id == null || widget.id!.isEmpty ? "null" : widget.id!);
    if (!mounted) return;
    if (albums != null) {
      if (albums["error"] != null) {
        return ApiService.returnError(context, albums["error"]);
      }
      setState(() {
        playlists = albums["playlists"];
      });
    } else {
      await ApiService.returnTokenExpired(context);
    }
  }

  void _handleTap(BuildContext context, dynamic item) {
    Haptics.vibrate(HapticsType.light);
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (ctx) => PlaylistPage(id: item["id"])),
    );
  }

  void _handleLongPress(BuildContext context, dynamic item) {
    Haptics.vibrate(HapticsType.medium);
    // TODO: implement playlist long press modal
  }

  void logout() {
    ApiService.logout(context);
  }

  void follow() async {
    if (widget.id == null) return;
    var response = await ApiService.followUser(widget.id!);
    if (!mounted) return;
    if (response != null) {
      if (response["error"] != null) {
        return ApiService.returnError(context, response["error"]);
      }
      setState(() {
        data["followed"] = response["followed"];
        data["followercount"] = response["followcount"];
      });
      if (response["followed"] == true) {
        Haptics.vibrate(HapticsType.success);
      } else {
        Haptics.vibrate(HapticsType.warning);
      }
    } else {
      await ApiService.returnTokenExpired(context);
    }
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
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
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
                                      '${ApiService
                                          .baseUrl}/storage/avatar/${data["avatarid"]}',
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
                                          GestureDetector(
                                            onTap: () {
                                              Haptics.vibrate(
                                                  HapticsType.light);
                                              Navigator.of(context)
                                                  .push(CupertinoPageRoute(
                                                  builder: (ctx) =>
                                                      UserFollowerPage(
                                                          userId: data["id"],
                                                          type: "user")));
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.group,
                                                    size: 14,
                                                    color: Colors.grey[400]),
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
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          GestureDetector(
                                            onTap: () {
                                              Haptics.vibrate(
                                                  HapticsType.light);
                                              Navigator.of(context)
                                                  .push(CupertinoPageRoute(
                                                  builder: (ctx) =>
                                                      UserFollowingPage(
                                                          userId: data["id"])));
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.group,
                                                    size: 14,
                                                    color: Colors.grey[400]),
                                                const SizedBox(width: 4),
                                                data == null
                                                    ? SkeletonContainer(
                                                    width: 40, height: 14)
                                                    : Text(
                                                  '${data["followingcount"]} following',
                                                  style: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                (data?["isself"] == true ?? true) ? IconButton(
                                  onPressed: () => logout(),
                                  icon: Icon(Icons.logout,
                                      color: Colors.white),
                                ) :
                                IconButton(
                                  onPressed: () => follow(),
                                  icon: Icon(
                                      data?["followed"] == true
                                          ? Icons.check_circle
                                          : Icons.add,
                                      color: data?["followed"] == true
                                          ? Colors.green
                                          : Colors.white),
                                ),
                              ],
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionTitle("Playlists"),
                                    playlists == null
                                        ? _buildSkeletonGrid()
                                        : _buildPlaylistGrid(context),
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
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: playlists.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        var album = playlists[index];
        return GestureDetector(
          onTap: () => _handleTap(context, album),
          onLongPress: () =>
              _handleLongPress(context, album),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.5).toInt()),
                    blurRadius: 8)
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl:
                    '${ApiService
                        .baseUrl}/storage/cover/playlist/${album["id"]}',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      if (downloadProgress.progress == null) {
                        return _buildSkeletonItem(
                            width: double.infinity, height: double.infinity);
                      }
                      return Container();
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        color: Colors.black.withAlpha((255 * 0.5).toInt()),
                        child: Center(
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha((255 * 0.8).toInt()),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Text(
                      album["name"],
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) =>
          _buildSkeletonItem(width: double.infinity, height: double.infinity),
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
