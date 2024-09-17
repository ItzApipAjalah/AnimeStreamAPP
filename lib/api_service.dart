import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/anime_model.dart';
import 'models/news_model.dart';

class ApiService {
  static const String _searchBaseUrl = 'https://localhost:3000/api/v1/search/';

  final List<String> _endpoints = [
    'https://localhost:3000/api/v1/ongoing/1',
    'https://localhost:3000/api/v1/ongoing/2',
    'https://localhost:3000/api/v1/ongoing/3',
  ];

  static const String _baseUrl =
      'https://anime-news-api.vercel.app/api/news/ann';

  Future<List<News>> fetchNews() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      return News.fromJsonList(response.body);
    } else {
      throw Exception('Failed to load news');
    }
  }

  Future<List<Anime>> fetchOngoingAnime() async {
    List<Anime> allAnime = [];

    for (String endpoint in _endpoints) {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['ongoing'];
        allAnime.addAll(data.map((json) => Anime.fromJson(json)).toList());
      } else {
        throw Exception('Failed to load anime from $endpoint');
      }
    }

    return allAnime;
  }

  Future<AnimeDetail> fetchAnimeDetail(String endpoint) async {
    final response = await http
        .get(Uri.parse('https://localhost:3000/api/v1/detail/$endpoint'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final animeDetail = AnimeDetail.fromJson(jsonData['anime_detail']);
      final episodeList = (jsonData['episode_list'] as List)
          .map((e) => Episode.fromJson(e))
          .toList();
      return animeDetail.copyWith(
          episodeList:
              episodeList); // Use a copyWith method if you wish to include episodes
    } else {
      throw Exception('Failed to load anime detail');
    }
  }

  Future<EpisodeDetail> fetchEpisodeDetail(String endpoint) async {
    final response =
        await http.get(Uri.parse('http://localhost:4000/scrape/$endpoint'));
    if (response.statusCode == 200) {
      return EpisodeDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load episode details');
    }
  }

  Future<List<AnimeSearchResult>> searchAnime(String query) async {
    final response = await http.get(Uri.parse('$_searchBaseUrl$query'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['search'];
      return data.map((json) => AnimeSearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
