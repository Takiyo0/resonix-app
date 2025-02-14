import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:resonix/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final baseUrl = 'http://192.168.1.2:6269';
  static final _dio = Dio(BaseOptions(baseUrl: baseUrl, headers: {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "User-Agent": "Resonix/1.0",
  }));

  static Dio get dio => _dio;

  static Future<String?> login(String query, String password) async {
    try {
      var response = await _dio.post(
        '/session/login',
        options: Options(headers: {"Content-Type": "application/json"}),
        data: {"query": query, "password": password},
      );

      if (response.statusCode == 200) {
        var token = response.data['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        return null;
      } else {
        return response.data['message'] ??
            response.data['error'] ??
            "Error ${response.statusCode}";
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data['message'] ??
            e.response!.data['error'] ??
            "Error ${e.response!.statusCode}";
      } else {
        return "Network error: ${e.message}";
      }
    } catch (e) {
      return "Unknown error occurred";
    }
  }

  static Future<String?> register(
      String username, String email, String password) async {
    try {
      var response = await _dio.post(
        '/session/register',
        data: {"username": username, "email": email, "password": password},
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return response.data['message'] ??
            response.data['error'] ??
            "Error ${response.statusCode}";
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data['message'] ??
            e.response!.data['error'] ??
            "Error ${e.response!.statusCode}";
      } else {
        return "Network error: ${e.message}";
      }
    } catch (e) {
      print(e);
      return "Unknown error occurred";
    }
  }

  static Future<Map<String, dynamic>?> getRecommendations() async {
    try {
      var response = await _dio.get(
        '/recommendation',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        return {
          "tracks": response.data['tracks'],
          "albums": response.data['albums'],
          "playlists": response.data['playlists'],
        };
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static void returnError(BuildContext context, String? error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? "Error fetching album tracks"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> returnTokenExpired(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Token expired, please login again"),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login()));
    }
  }

  static Future<Map<String, dynamic>?> getAlbumTracks(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.get(
        '/album/$id/tracks',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> getAlbum(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.get(
        '/album/$id',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> likeAlbum(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.post(
        '/activity/album/$id/like',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> likeTrack(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.post(
        '/activity/track/$id/like',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> getUserPlaylists(
      bool allowLiked, bool showFollowed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.get(
        "/playlist?includeLikedSongs=${allowLiked ? "true" : "false"}&includeFollowedPlaylists=${showFollowed ? "true" : "false"}",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> getPlaylist(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.get(
        "/playlist/$id",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> getPlaylistTracks(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.get(
        "/playlist/$id/tracks",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> followPlaylist(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.post(
        "/activity/playlist/$id/follow",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> createPlaylist(
      String name, String? baseTrackId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.post(
        "/playlist/",
        options: Options(headers: {"Authorization": "Bearer $token"}),
        data: {"name": name, "baseTrackId": baseTrackId},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      print(e);
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> addTrackToPlaylist(
      String playlistId, String trackId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    print("Adding track $trackId to playlist $playlistId");
    try {
      var response = await _dio.post(
        "/playlist/$playlistId/tracks",
        data: [trackId],
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      print(e);
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> removeTrackFromPlaylist(
      String playlistId, String trackId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.delete(
        "/playlist/$playlistId/tracks",
        data: [trackId],
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> getUserLibrary() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token");
    try {
      var response = await _dio.get(
        "/user/library",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> getArtist(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.get(
        "/artist/$id",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> getArtistAlbums(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.get(
        "/artist/$id/albums",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> getArtistTopTracks(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.get(
        "/artist/$id/tracks/top",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> getArtistTracks(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.get(
        "/artist/$id/tracks",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> followArtist(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.post(
        "/activity/artist/$id/follow",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<bool> isTokenValid(String token) async {
    try {
      var response = await _dio.get('/user',
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));

      return response.statusCode == 200;
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<dynamic> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    if (token == null) return null;

    try {
      var response = await _dio.get('/user',
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> getNextRecommendations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    if (token == null) return null;

    try {
      var response = await _dio.post('/recommendation/personalized/next',
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> sendPlaying(String trackId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    try {
      var response = await _dio.post(
        "/activity/playing?trackId=$trackId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }

  static Future<Map<String, dynamic>?> search(String query) async {
    try {
      var response = await _dio.get(
        '/search',
        queryParameters: {"query": query},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        return {
          "tracks": response.data['tracks'],
          "albums": response.data['albums'],
          "playlists": response.data['playlists'],
        };
      } else {
        return {
          "error": response.data['message'] ??
              response.data['error'] ??
              "Error ${response.statusCode}"
        };
      }
    } on DioException catch (e) {
      return {
        "error": e.response?.data['message'] ??
            e.response?.data['error'] ??
            "Error ${e.response?.statusCode}"
      };
    } catch (e) {
      print(e);
      return {"error": "Unknown error occurred"};
    }
  }
}
