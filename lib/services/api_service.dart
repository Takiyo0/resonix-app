import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final baseUrl = 'http://192.168.1.3:6269';
  static final _dio = Dio(BaseOptions(baseUrl: baseUrl));

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
        options: Options(headers: {"Content-Type": "application/json"}),
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

  static Future<Map<String, dynamic>?> getAlbumTracks(String id) async {
    try {
      var response = await _dio.get(
        '/album/$id/tracks',
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      print("hmm");

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
