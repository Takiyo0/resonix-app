import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:resonix/main.dart';
import 'package:resonix/pages/album.dart';
import 'package:resonix/services/api_service.dart';
import 'package:resonix/widgets/custom_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  Timer? _throttle;
  var _searchQuery = "";
  bool error = false;

  dynamic _trackData = [];
  dynamic _albumData = [];
  dynamic _playlistData = [];

  void _onSearchChanged(String value) {
    if (_throttle?.isActive ?? false) _throttle!.cancel();
    _throttle = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
      });
      _search();
    });
  }

  Future<void> _search() async {
    if (_searchQuery.trim().isEmpty) return;
    var data = await ApiService.search(_searchQuery);
    if (!mounted || _searchQuery.isEmpty) return;
    if (data != null && data.containsKey("error")) {
      setState(() {
        error = true;
      });
    } else if (data != null) {
      setState(() {
        _trackData = data["tracks"] ?? [];
        _albumData = data["albums"] ?? [];
        _playlistData = data["playlists"] ?? [];
      });
    }
  }

  @override
  void dispose() {
    _throttle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = context.watch<AudioState>();

    Future<void> onTap(dynamic data, String type) async {
      FocusScope.of(context).unfocus();
      if (type == "album") {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) => AlbumPage(id: data["id"])),
        );
      }
      if (type != "track") return;
      await audioState.play(
          audioState.buildTrack(data, "Search on $_searchQuery"), true);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Search', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        leading: const Icon(Icons.search, color: Colors.white, size: 32),
        titleSpacing: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withAlpha(0),
            ),
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            _buildBackground(),
            Column(
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CupertinoSearchTextField(
                    placeholder: 'Search something...',
                    style: TextStyle(color: Colors.white),
                    onChanged: _onSearchChanged,
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _searchQuery.isEmpty
                        ? _buildEmptyState()
                        : _buildSearchResults(onTap),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF1A0E2E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 50, color: Colors.grey[700]),
          const SizedBox(height: 10),
          Text(
            'Start typing to search',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(Function onTap) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildSection("Tracks", _trackData, "track", onTap),
        _buildSection("Albums", _albumData, "album", onTap),
        _buildSection("Playlists", _playlistData, "playlist", onTap),
      ],
    );
  }

  Widget _buildSection(
      String title, List<dynamic> data, String type, Function onTap) {
    if (data.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        ...data.map((item) => _buildListItem(item, type, onTap)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildListItem(dynamic item, String type, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(item, type),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        decoration: BoxDecoration(
          color: Color(0xFF28123E),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.2).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Row(
            children: [
              _buildItemImage(item, type),
              const SizedBox(width: 10),
              _buildItemInfo(item),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(dynamic item, String type) {
    return CustomImage(
      imageUrl: '${ApiService.baseUrl}/storage/cover/$type/${item["id"]}',
      height: 55,
      width: 55,
    );
  }

  Widget _buildItemInfo(dynamic item) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item["name"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            item["artists"]?.map((artist) => artist.toString()).join(", ") ??
                "Unknown Artist",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
