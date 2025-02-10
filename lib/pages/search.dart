import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:resonix/main.dart';
import 'package:resonix/pages/album.dart';
import 'package:resonix/services/api_service.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withAlpha(25),
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
      body: SearchStatefulPage(),
    );
  }
}

class SearchStatefulPage extends StatefulWidget {
  const SearchStatefulPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchStatefulPage> {
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

  // @override
  // void initState() {
  //   super.initState();
  //   setState(() {
  //     _searchQuery = "d";
  //   });
  //   _search();
  // }

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
      try {
        await audioState.play(
            audioState.buildTrack(data, "Search on $_searchQuery"), true);
      } catch (e) {}
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        height: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CupertinoSearchTextField(
                placeholder: 'Search',
                style: TextStyle(color: Colors.white),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: _searchQuery.isEmpty
                  ? Center(
                      child: Text('Start typing to search',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 16.0, right: 16.0, bottom: 120.0),
                      children: [
                        const Text("Tracks",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        _buildList(_trackData, "track",
                            (data) => onTap(data, "track")),
                        const SizedBox(height: 20),
                        const Text("Albums",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        _buildList(_albumData, "album",
                            (data) => onTap(data, "album")),
                        const SizedBox(height: 20),
                        const Text("Playlists",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        _buildList(_playlistData, "playlist",
                            (data) => onTap(data, "playlist")),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
      List<dynamic> data, String type, ValueChanged<dynamic> onTap) {
    return data.isEmpty
        ? Center(
            child:
                Text("No $type found", style: TextStyle(color: Colors.white)),
          )
        : Column(
            children: data.map((item) {
            return Container(
              color: Colors.transparent,
              margin: const EdgeInsets.only(bottom: 10),
              child: Ink(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A0E2E),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => onTap(item),
                  borderRadius: BorderRadius.circular(12.0),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              '${ApiService.baseUrl}/storage/cover/$type/${item["id"]}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item['artists']
                                        ?.map((artist) => artist.toString())
                                        .join(", ") ??
                                    "Unknown Artist",
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList());
  }
}
