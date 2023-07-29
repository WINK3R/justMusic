import 'dart:convert';

import 'package:justmusic/view_model/TokenSpotify.dart';
import 'package:http/http.dart' as http;
import '../model/Artist.dart';
import '../model/Music.dart';

class MusicViewModel {
  final String API_URL = "https://api.spotify.com/v1";
  late TokenSpotify _token;

  MusicViewModel() {
    _token = new TokenSpotify();
  }

  // Methods
  Future<Music> getMusic(String id) async {
    var accessToken = await _token.getAccessToken();
    var response = await http.get(Uri.parse('$API_URL/tracks/$id'), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      List<Artist> artists =
          List<Artist>.from(responseData['artists'].map((artist) {
        return Artist(artist['id'], artist['name'], '');
      }));

      return Music(
          responseData['id'],
          responseData['name'],
          responseData['album']['images'][0]['url'],
          responseData['preview_url'],
          int.parse(responseData['album']['release_date'].split('-')[0]),
          responseData['duration_ms'] / 1000,
          responseData['explicit'],
          artists);
    } else {
      throw Exception(
          'Error retrieving music information : ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  List<Music> _getMusicsFromResponse(List<dynamic> tracks) {
    List<Music> musics = [];

    for (var track in tracks) {
      List<Artist> artists = List<Artist>.from(track['artists'].map((artist) {
        return Artist(artist['id'], artist['name'], '');
      }));

      musics.add(Music(
          track['id'],
          track['name'],
          track['album']['images'][0]['url'],
          track['preview_url'],
          int.parse(track['album']['release_date'].split('-')[0]),
          track['duration_ms'] / 1000,
          track['explicit'],
          artists));
    }

    return musics;
  }

  Future<List<Music>> getMusicsWithName(String name,
      {int limit = 20, int offset = 0, String market = "FR"}) async {
    var accessToken = await _token.getAccessToken();
    var response = await http.get(
        Uri.parse(
            '$API_URL/search?q=track%3A$name&type=track&market=fr&limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return _getMusicsFromResponse(responseData['tracks']['items']);
    } else {
      throw Exception(
          'Error while retrieving music : ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future<List<Music>> getMusicsWithArtistName(String name,
      {int limit = 20, int offset = 0, String market = "FR"}) async {
    var accessToken = await _token.getAccessToken();
    var response = await http.get(
        Uri.parse(
            '$API_URL/search?q=artist%3A$name&type=track&market=fr&limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return _getMusicsFromResponse(responseData['tracks']['items']);
    } else {
      throw Exception(
          'Error while retrieving music : ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future<Artist> getArtistWithName(String name, {String market = "FR"}) async {
    var accessToken = await _token.getAccessToken();
    var response = await http.get(
        Uri.parse(
            '$API_URL/search?q=artist%3A$name&type=artist&market=$market'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      List<Artist> artists =
          List<Artist>.from(responseData['artists']['items'].map((artist) {
        String image = '';
        if (!artist['images'].isEmpty) {
          image = artist['images'][0]['url'];
        }
        return Artist(artist['id'], artist['name'], image);
      }));

      for (Artist a in artists) {
        if (a.name?.toLowerCase() == name.toLowerCase()) {
          return a;
        }
      }

      throw Exception('Artist not found : ${name}');
    } else {
      throw Exception(
          'Error retrieving artist information : ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future<List<Artist>> getArtistsWithName(String name,
      {int limit = 20, int offset = 0, String market = "FR"}) async {
    var accessToken = await _token.getAccessToken();
    var response = await http.get(
        Uri.parse(
            '$API_URL/search?q=artist%3A$name&type=artist&market=$market&limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      List<Artist> artists =
          List<Artist>.from(responseData['artists']['items'].map((artist) {
        String image = '';
        if (!artist['images'].isEmpty) {
          image = artist['images'][0]['url'];
        }
        return Artist(artist['id'], artist['name'], image);
      }));

      return artists;
    } else {
      throw Exception(
          'Error while retrieving artist : ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future<List<Music>> getTopMusicsWithArtistId(String id,
      {String market = "FR"}) async {
    var accessToken = await _token.getAccessToken();
    var response = await http.get(
        Uri.parse('$API_URL/artists/$id/top-tracks?market=$market'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return _getMusicsFromResponse(responseData['tracks']);
    } else {
      throw Exception(
          'Error while retrieving music : ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future<List<Music>> getMusicsWithPlaylistId(String id,
      {String market = "FR"}) async {
    var accessToken = await _token.getAccessToken();
    var response = await http
        .get(Uri.parse('$API_URL/playlists/$id?market=$market'), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      List<Music> musics = [];

      List<dynamic> tracks = responseData['tracks']['items'];
      for (var track in tracks) {
        List<Artist> artists =
            List<Artist>.from(track['track']['artists'].map((artist) {
          return Artist(artist['id'], artist['name'], '');
        }));

        DateTime releaseDate =
            DateTime.parse(track['track']['album']['release_date']);

        musics.add(Music(
            track['track']['id'],
            track['track']['name'],
            track['track']['album']['images'][0]['url'],
            track['track']['preview_url'],
            int.parse(responseData['album']['release_date'].split('-')[0]),
            track['track']['duration_ms'] / 1000,
            track['track']['explicit'],
            artists));
      }
      /*
      List<Music> musics = _getMusicsFromResponse(responseData['tracks']['items']);
      }*/

      return musics;
    } else {
      throw Exception(
          'Error while retrieving music : ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  Future<List<Music>> getMusicsWithIds(List<String> ids,
      {String market = "FR"}) async {
    var accessToken = await _token.getAccessToken();
    String url = API_URL + '/tracks?market=$market&ids=';

    if (ids.length == 0) return [];

    url += ids.join('%2C');

    print(url);

    var response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return _getMusicsFromResponse(responseData['tracks']);
    } else {
      throw Exception(
          'Error while retrieving music : ${response.statusCode} ${response.reasonPhrase}');
    }
  }
}
