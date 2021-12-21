import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../utilities/keys.dart';

class APIService {
  APIService._instantiate();

  final _playlistId = "PLBRObSmbZluSo6h0AySyeZRdlQzEhr2XL";

  static final APIService instance = APIService._instantiate();
  final String _baseUrl = "www.googleapis.com";
  String _nextPageToken = '';

  Future<List<Video>> fetchVideosFromPlaylist() async {
    Map<String, String> params = {
      'part': 'snippet',
      'playlistId': _playlistId,
      'max_Results': '8',
      'pageToken': _nextPageToken,
      'key': API_KEY
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/playlistItems',
      params,
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Playlist Videos

    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      _nextPageToken = data["nextPageToken"] ?? "";
      List<dynamic> videosJson = data["items"];

      print("From api service ${videosJson[2]}");

      print("From api service ${videosJson[3]}");

      List<Video> videos = [];
      videosJson.forEach(
        (video) => videos.add(
          Video.fromMap(
            video['snippet'],
          ),
        ),
      );
      return videos;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }
}


// playlist ID: 

