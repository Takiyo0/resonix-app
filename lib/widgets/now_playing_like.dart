import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resonix/services/api_service.dart';

class NowPlayingLike extends StatefulWidget {
  final String? trackId;

  const NowPlayingLike({super.key, required this.trackId});

  @override
  NowPlayingLikeState createState() => NowPlayingLikeState();
}

class NowPlayingLikeState extends State<NowPlayingLike> {
  bool? isLiked;

  @override
  void initState() {
    super.initState();
    _fetchLikeStatus();
  }

  Future<void> _fetchLikeStatus() async {
    if (widget.trackId == null) return;
    var response = await ApiService.trackLiked(widget.trackId!);
    if (!mounted) return;
    if (response != null) {
      if (response["error"] != null) {
        ApiService.returnError(context, response["error"]);
        return;
      }

      setState(() => isLiked = response["liked"] == true);
    } else {
      await ApiService.returnTokenExpired(context);
      return;
    }
  }

  Future<void> _toggleLike() async {
    if (widget.trackId == null) return;
    var response = await ApiService.likeTrack(widget.trackId!);
    if (!mounted) return;
    if (response != null) {
      if (response["error"] != null) {
        ApiService.returnError(context, response["error"]);
        return;
      }
      setState(() => isLiked = response["liked"] == true);
    } else {
      await ApiService.returnTokenExpired(context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isLiked == null ? null : _toggleLike,
      child: Icon(
        isLiked == true ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        size: 30,
        color: isLiked == true ? Colors.pinkAccent : Colors.white,
      ),
    );
  }
}
