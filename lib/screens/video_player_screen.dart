import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  VideoPlayerScreen({required this.url});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isFullScreen = false;
  InAppWebViewController? _webViewController;
  Timer? _videoTimeUpdater;

  @override
  void initState() {
    super.initState();
    _startVideoTimeUpdater(); // Start the timer when the widget is initialized
  }

  @override
  void dispose() {
    _videoTimeUpdater?.cancel(); // Cancel the timer when the widget is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
  }

  void _hideElementsPeriodically() {
    int timesExecuted = 0;
    const maxTimes = 120000; // Change to your requirement
    const delay = Duration(milliseconds: 500);

    void execute() {
      _webViewController?.evaluateJavascript(
        source: '''
          var elements = document.getElementsByClassName('viewer-top-bl');
          for (var i = 0; i < elements.length; i++) {
            elements[i].style.display = 'none';
          }
        ''',
      );

      timesExecuted++;
      if (timesExecuted < maxTimes) {
        Future.delayed(delay, execute);
      }
    }

    Future.delayed(delay, execute);
  }

  void _startVideoTimeUpdater() {
    _videoTimeUpdater = Timer.periodic(Duration(seconds: 1), (timer) {
      _getCurrentVideoTime(); // Fetch and save the current video time every second
      _updateElementClass(); // Update the class of the element with ID bodyel every second
    });
  }

  Future<void> _getCurrentVideoTime() async {
    if (_webViewController != null) {
      try {
        String? currentTime = await _webViewController?.evaluateJavascript(
          source: '''
            (function() {
              var timingElement = document.querySelector('.video-timing.current');
              return timingElement ? timingElement.innerText : '';
            })();
          ''',
        );

        if (currentTime != null && currentTime.isNotEmpty) {
          print('Current video time: $currentTime');
          await _saveVideoTimeToHistory(currentTime);
        }
      } catch (error) {
        print('Error fetching current video time: $error');
      }
    }
  }

  Future<void> _updateElementClass() async {
    if (_webViewController != null) {
      try {
        await _webViewController?.evaluateJavascript(
          source: '''
            (function() {
              var element = document.getElementById('bodyel');
              if (element) {
                element.className = 'theme-dark-forced video-theatre-mode';
              }
            })();
          ''',
        );
      } catch (error) {
        print('Error updating element class: $error');
      }
    }
  }

  Future<void> _saveVideoTimeToHistory(String time) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('episodeHistory') ?? [];

    if (history.isNotEmpty) {
      // Assuming the last played episode is the current one
      Map<String, dynamic> lastEpisode = jsonDecode(history.last);
      lastEpisode['last_played_time'] = time;

      history[history.length - 1] = jsonEncode(lastEpisode);
      await prefs.setStringList('episodeHistory', history);
    }
  }

  Future<bool> _onWillPop() async {
    if (_isFullScreen) {
      _toggleFullScreen();
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _isFullScreen
            ? null
            : AppBar(
                title: Text('Video Player'),
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              ),
        body: Column(
          children: [
            if (!_isFullScreen)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [],
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(widget.url),
                    ),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                        useOnDownloadStart: true,
                      ),
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      _webViewController = controller;
                      _hideElementsPeriodically();
                    },
                    onLoadStop:
                        (InAppWebViewController controller, Uri? url) async {
                      print("Stopped loading: $url");
                      _getCurrentVideoTime(); // Fetch and save the current video time
                    },
                    onLoadError: (InAppWebViewController controller, Uri? url,
                        int code, String message) {
                      print(
                          "Error loading: $url with code: $code and message: $message");
                    },
                    onLoadHttpError: (InAppWebViewController controller,
                        Uri? url, int statusCode, String description) {
                      print(
                          "HTTP Error loading: $url with status code: $statusCode and description: $description");
                    },
                  ),
                  if (!_isFullScreen)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        onPressed: _toggleFullScreen,
                        child: Icon(Icons.fullscreen),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
