import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../api_service.dart';
import 'package:flutter/services.dart';
import 'episode_detail_screen.dart';

class AnimeDetailScreen extends StatelessWidget {
  final String animeEndpoint;

  AnimeDetailScreen({required this.animeEndpoint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anime Details'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: FutureBuilder<AnimeDetail>(
        future: ApiService().fetchAnimeDetail(animeEndpoint),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final animeDetail = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 550,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(animeDetail.thumb),
                        fit: BoxFit.cover,
                      ),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      alignment: Alignment.bottomLeft,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Text(
                        animeDetail.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black45,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Synopsis',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue[800],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      animeDetail.sinopsis.join('\n\n'),
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue[800],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      animeDetail.detail.join('\n'),
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Episodes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue[800],
                      ),
                    ),
                  ),
                  if (animeDetail.episodeList != null &&
                      animeDetail.episodeList!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: animeDetail.episodeList!.length,
                      itemBuilder: (context, index) {
                        final episode = animeDetail.episodeList![index];
                        return EpisodeTile(episode: episode);
                      },
                    ),
                  if (animeDetail.episodeList == null ||
                      animeDetail.episodeList!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'No episodes available.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
