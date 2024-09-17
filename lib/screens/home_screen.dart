import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/anime_model.dart';
import '../api_service.dart';
import '../screens/anime_list_item_screen.dart';
import '../screens/anime_news_screen.dart';
import '../screens/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeModeChanged;

  HomeScreen({required this.onThemeModeChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Future<List<Anime>> _animeList;
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _fetchAnimeList();
    _loadThemeMode();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  void _fetchAnimeList() {
    _animeList = ApiService().fetchOngoingAnime();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  Future<void> _refreshAnimeList() async {
    setState(() {
      _fetchAnimeList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _animationController.forward(from: 0.0); // Restart the animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Text(
            _selectedIndex == 0 ? 'Ongoing Anime' : 'History',
            key: ValueKey<int>(_selectedIndex),
            style: TextStyle(
              color: Colors.purpleAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: Icon(Icons.search, color: Colors.purpleAccent),
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
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _selectedIndex == 0
            ? RefreshIndicator(
                onRefresh: _refreshAnimeList,
                child: _buildAnimeList(),
              )
            : HistoryScreen(),
      ),
      bottomNavigationBar: _buildAnimatedBottomNavigationBar(),
    );
  }

  Widget _buildAnimeList() {
    return FutureBuilder<List<Anime>>(
      future: _animeList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Lottie.asset('assets/loading.json', width: 150));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.redAccent),
            ),
          );
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
    );
  }

  Widget _buildAnimatedBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.home, 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.history, 1),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        backgroundColor: Colors.transparent,
        elevation: 0,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;

    return ScaleTransition(
      scale: isSelected ? _animation : AlwaysStoppedAnimation(1.0),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
        size: isSelected ? 30 : 24,
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Navigation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black26,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _createDrawerItem(
                  icon: Icons.local_movies_outlined,
                  text: 'Anime Stream',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                _createDrawerItem(
                  icon: Icons.newspaper,
                  text: 'Anime News',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AnimeNewsScreen()),
                    );
                  },
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _createDrawerItem(
                  icon: Icons.brightness_6,
                  text: 'Toggle Dark Mode',
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                        widget.onThemeModeChanged(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Lottie.asset(
              'assets/anime.json',
              repeat: true, // Ensures the animation repeats
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      GestureTapCallback? onTap,
      Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.purpleAccent),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
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
              color: Colors.purpleAccent,
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
