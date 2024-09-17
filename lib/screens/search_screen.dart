import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_service.dart';
import '../models/anime_model.dart';
import '../screens/anime_detail_screen.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSearching = false;
  bool _isImageSearching = false; // New variable to track image search loading
  String _speechText = '';
  Future<List<AnimeSearchResult>> _searchResults = Future.value([]);
  List<String> _searchHistory = [];
  List<AnimeSearchResult> _imageSearchResults = [];

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
    setState(() {
      _isSearching = true;
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isSearching = false;
    });
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
      _searchResults = ApiService().searchAnime(query);
      _saveSearchQuery(query);
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
      _isSearching = false; // Ensure the flag is set correctly
    });
  }

  Future<void> _saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_searchHistory.contains(query)) {
      _searchHistory.add(query);
      await prefs.setStringList('searchHistory', _searchHistory);
    }
  }

  Future<void> _saveImageSearchQuery(String filename) async {
    final prefs = await SharedPreferences.getInstance();
    String query = 'Image search: $filename';
    if (!_searchHistory.contains(query)) {
      _searchHistory.add(query);
      await prefs.setStringList('searchHistory', _searchHistory);
    }
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      _searchHistory.clear();
    });
  }

  Future<void> _searchByImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _isImageSearching = true; // Start loading animation for image search
      });

      try {
        final bytes = await file.readAsBytes();
        final response = await http.post(
          Uri.parse('https://api.trace.moe/search'),
          headers: {
            'Content-Type': 'image/jpeg',
          },
          body: bytes,
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          final results = (jsonResponse['result'] as List)
              .map((data) => AnimeSearchResult.fromJson(data))
              .toList();

          setState(() {
            _imageSearchResults = results;
            _isImageSearching = false; // Stop loading animation
          });

          // Save image search query to history
          if (results.isNotEmpty) {
            _saveImageSearchQuery(results[0].filename);
          }
        } else {
          throw Exception('Failed to load search results');
        }
      } catch (e) {
        setState(() {
          _isImageSearching = false; // Stop loading animation on error
        });
        print('Error searching by image: $e');
      }
    }
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
          onChanged: (query) {
            setState(() {
              _isSearching = query.isNotEmpty;
            });
          },
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
            icon: Icon(Icons.image),
            onPressed: _searchByImage,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isSearching &&
              _searchHistory.isNotEmpty &&
              _imageSearchResults.isEmpty)
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
          if (!_isSearching &&
              _searchHistory.isNotEmpty &&
              _imageSearchResults.isEmpty)
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
          if (_isSearching)
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
          if (_isImageSearching)
            Expanded(
              child: Center(
                  child: CircularProgressIndicator()), // Show loading indicator
            ),
          if (!_isSearching && _imageSearchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _imageSearchResults.length,
                itemBuilder: (context, index) {
                  final result = _imageSearchResults[index];
                  return ListTile(
                    leading: Image.network(result.image),
                    title: Text(result.filename),
                    subtitle: Text(
                      'Episode: ${result.episode}\nSimilarity: ${result.similarity.toStringAsFixed(2)}%',
                    ),
                    onTap: () {
                      // Copy the filename to the clipboard
                      Clipboard.setData(ClipboardData(text: result.filename));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Filename copied to clipboard')),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
