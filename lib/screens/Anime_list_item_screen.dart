import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../screens/anime_detail_screen.dart';

class AnimeListItem extends StatelessWidget {
  final Anime anime;

  AnimeListItem({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AnimeDetailScreen(animeEndpoint: anime.endpoint),
            ),
          );
        },
        child: Container(
          width: 180, // Slightly increased width for better content display
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                20), // Increased radius for smoother corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15), // Soft shadow
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(anime.thumb),
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(20), // ClipRRect to match border radius
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              18, // Increased font size for better readability
                          fontWeight: FontWeight
                              .w600, // Slightly lighter weight for a modern feel
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${anime.totalEpisode} eps | ${anime.updatedOn}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
