import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../api_service.dart';
import 'video_player_screen.dart';

class EpisodeTile extends StatefulWidget {
  final Episode episode;

  EpisodeTile({required this.episode});

  @override
  _EpisodeTileState createState() => _EpisodeTileState();
}

class _EpisodeTileState extends State<EpisodeTile> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.episode.episodeTitle),
      subtitle: Text(widget.episode.episodeDate),
      onTap: () async {
        if (_isLoading) return; // Prevent multiple taps

        setState(() {
          _isLoading = true;
        });

        try {
          final episodeDetail = await ApiService()
              .fetchEpisodeDetail(widget.episode.episodeEndpoint);

          final highQualityLinks =
              episodeDetail.getDownloadLinks('high_quality');
          if (highQualityLinks.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VideoPlayerScreen(url: highQualityLinks.first.link),
              ),
            );
          } else {
            // Handle the case where no link is available
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No video link available')),
            );
          }
        } catch (error) {
          // Log detailed error 
          print('Error fetching episode details: $error');

          // Show generic error message to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching episode details')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
      trailing: _isLoading
          ? CircularProgressIndicator()
          : Icon(Icons.play_circle_fill, color: Colors.lightBlue[300]),
    );
  }
}
