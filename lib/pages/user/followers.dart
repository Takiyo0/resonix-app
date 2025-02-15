import 'package:flutter/cupertino.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:resonix/main.dart';
import 'package:resonix/pages/artist.dart';
import 'package:resonix/pages/user.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/custom_image.dart';
import 'package:resonix/widgets/skeleton_widget.dart';

class UserFollowerPage extends StatefulWidget {
  final String userId;
  final String type;

  const UserFollowerPage({super.key, required this.userId, required this.type});

  @override
  UserFollowerPageState createState() => UserFollowerPageState();
}

class UserFollowerPageState extends State<UserFollowerPage> {
  dynamic data;
  dynamic follower;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadFollower();
  }

  void _handleTap(BuildContext context, dynamic item) {
    Haptics.vibrate(HapticsType.light);
    if (item["accountType"] == 2) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (ctx) => ArtistPage(id: item["id"]),
        ),
      );
    } else {
      Navigator.of(context).push(
        CupertinoPageRoute(builder: (ctx) => UserPage(id: item["id"])),
      );
    }
  }

  Future<void> loadUser() async {
    var user = await ApiService.getPublicUser(widget.userId);
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

  Future<void> loadFollower() async {
    var follower = await ApiService.getFollowers(widget.userId);
    if (!mounted) return;
    if (follower != null) {
      if (follower["error"] != null) {
        return ApiService.returnError(context, follower["error"]);
      }
      setState(() {
        this.follower = follower["followers"];
      });
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
                                          const SizedBox(width: 12),
                                          if (widget.type != "artist") ...[
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
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _sectionTitle(((data?["nickname"] == null
                                                ? null
                                                : (data["nickname"] + "'s ")) ??
                                            (data?["username"] == null
                                                ? null
                                                : (data["username"] + "'s ")) ??
                                            "") +
                                        "Followers"),
                                    follower == null
                                        ? _buildSkeletonList()
                                        : _buildFollowingList(context),
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

  Widget _buildFollowingList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: follower.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        var user = follower[index];

        return GestureDetector(
          onTap: () => _handleTap(context, user),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF28123E),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.3).toInt()),
                  blurRadius: 4,
                )
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: user["avatarId"] != null
                      ? CustomImage(
                          imageUrl:
                              '${ApiService.baseUrl}/storage/avatar/${user["avatarId"]}',
                          height: 50,
                          width: 50,
                        )
                      : Container(
                          height: 50,
                          width: 50,
                          color: Colors.grey[800],
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user["nickname"] ?? user["username"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text('@${user["username"]}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12)),
                      Row(
                        children: [
                          Icon(Icons.people, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${user["followercount"]} Followers',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.grey[800],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 100,
                      color: Colors.grey[800],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
