import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/anime_model.dart';
import 'video_player_screen.dart';
import '../api_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Episode> _watchedEpisodes = [];

  @override
  void initState() {
    super.initState();
    _loadWatchedEpisodes();
  }

  Future<void> _loadWatchedEpisodes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> episodeHistory = prefs.getStringList('episodeHistory') ?? [];

    setState(() {
      _watchedEpisodes =
          episodeHistory.map((e) => Episode.fromJson(jsonDecode(e))).toList();
    });
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('episodeHistory');
    setState(() {
      _watchedEpisodes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch History'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: _watchedEpisodes.isEmpty
          ? Center(child: Text('No watched episodes'))
          : ListView.builder(
              itemCount: _watchedEpisodes.length,
              itemBuilder: (context, index) {
                final episode = _watchedEpisodes[index];
                return ListTile(
                  title: Text(episode.episodeTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(episode.episodeDate),
                      Text('Last Played: ${episode.lastPlayedTime}'),
                    ],
                  ),
                  onTap: () async {
                    final episodeDetail = await ApiService()
                        .fetchEpisodeDetail(episode.episodeEndpoint);

                    final highQualityLinks =
                        episodeDetail.getDownloadLinks('high_quality');
                    if (highQualityLinks.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                              url: highQualityLinks.first.link),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No video link available')),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
