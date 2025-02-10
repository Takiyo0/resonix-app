import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resonix/services/api_service.dart';

class NewPlaylistModal {
  static Future<void> show(
      BuildContext currentContext, Function(String) onDone) async {
    TextEditingController controller = TextEditingController();

    Future<void> createPlaylist(String name, BuildContext context) async {
      var response = await ApiService.createPlaylist(name, null);
      if (!currentContext.mounted) return;
      if (context.mounted) Navigator.pop(context);
      if (response != null) {
        if (response["error"] != null) {
          return ApiService.returnError(currentContext, response["error"]);
        }
        onDone(response["playlistid"]);
      } else {
        await ApiService.returnTokenExpired(currentContext);
      }
    }

    showModalBottomSheet<void>(
      context: currentContext,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF150825),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((255 * 0.3).toInt()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Text(
                    "New Playlist",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: controller,
                    maxLength: 50,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    placeholder: "Playlist name",
                    placeholderStyle: TextStyle(
                        color: Colors.white.withAlpha((255 * 0.5).toInt())),
                    style: const TextStyle(color: Colors.white),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((255 * 0.1).toInt()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          color: Colors.white.withAlpha((255 * 0.2).toInt()),
                          borderRadius: BorderRadius.circular(10),
                          onPressed: () =>
                              createPlaylist(controller.text, context),
                          child: const Text(
                            "Create",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CupertinoButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
