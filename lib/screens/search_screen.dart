import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../api_service.dart';
import '../models/anime_model.dart';
import '../screens/anime_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _speechText = '';
  Future<List<AnimeSearchResult>> _searchResults = Future.value([]);
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
    _loadSearchHistory();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {});
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) {
        setState(() {
          _speechText = result.recognizedWords;
          _searchController.text = _speechText;
          if (result.finalResult) {
            _performSearch(_speechText);
          }
        });
      },
      listenFor: Duration(seconds: 10),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
      onSoundLevelChange: (level) => print('Sound level: $level'),
    );
  }

  void _stopListening() {
    _speech.stop();
  }

  void _performSearch(String query) {
    setState(() {
      _searchResults = ApiService().searchAnime(query);
      _saveSearchQuery(query);
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.add(query);
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search anime...',
            border: InputBorder.none,
          ),
          onSubmitted: (query) {
            _performSearch(query);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
              setState(() {
                _isListening = !_isListening;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _loadSearchHistory,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearSearchHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    'Search History:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _clearSearchHistory,
                  ),
                ],
              ),
            ),
          if (_searchHistory.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchHistory.length,
                itemBuilder: (context, index) {
                  final query = _searchHistory[index];
                  return ListTile(
                    title: Text(query),
                    onTap: () {
                      _searchController.text = query;
                      _performSearch(query);
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: FutureBuilder<List<AnimeSearchResult>>(
              future: _searchResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Center(child: Text('No results found'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final result = snapshot.data![index];
                      return ListTile(
                        leading: Image.network(result.thumb),
                        title: Text(result.title),
                        subtitle: Text(
                            'Genres: ${result.genres.join(', ')}\nRating: ${result.rating}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnimeDetailScreen(
                                animeEndpoint: result.endpoint,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No results found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
