import 'package:flutter/material.dart';
import 'models/anime_model.dart';
import 'api_service.dart';
import 'screens/Anime_list_item_screen.dart';
import 'screens/anime_news_screen.dart'; 
import 'screens/search_screen.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime Streaming',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Anime>> _animeList;

  @override
  void initState() {
    super.initState();
    _fetchAnimeList();
  }

  void _fetchAnimeList() {
    _animeList = ApiService().fetchOngoingAnime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ongoing Anime'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: FutureBuilder<List<Anime>>(
        future: _animeList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final animeByDay = _groupAnimeByDay(snapshot.data!);
            return ListView.builder(
              itemCount: animeByDay.length,
              itemBuilder: (context, index) {
                final day = animeByDay.keys.elementAt(index);
                final animeList = animeByDay[day]!;
                return _buildDaySection(day, animeList);
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Navigation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context); 
            },
          ),
          ListTile(
            leading: Icon(Icons.newspaper),
            title: Text('Anime News'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnimeNewsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Map<String, List<Anime>> _groupAnimeByDay(List<Anime> animeList) {
    final Map<String, List<Anime>> animeByDay = {
      'All': animeList,
    };

    for (final anime in animeList) {
      final day = anime.updatedDay.trim();
      if (!animeByDay.containsKey(day)) {
        animeByDay[day] = [];
      }
      animeByDay[day]!.add(anime);
    }

    return animeByDay;
  }

  Widget _buildDaySection(String day, List<Anime> animeList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            day,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: animeList.length,
            itemBuilder: (context, index) {
              final anime = animeList[index];
              return AnimeListItem(anime: anime);
            },
          ),
        ),
      ],
    );
  }
}
