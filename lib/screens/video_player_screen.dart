import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/services.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  VideoPlayerScreen({required this.url});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isFullScreen = false;
  InAppWebViewController? _webViewController;

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
    const maxTimes = 10;
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text('Video Player'),
              backgroundColor: Colors.lightBlue[300],
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
                  onLoadStart: (InAppWebViewController controller, Uri? url) {
                    print("Started loading: $url");
                  },
                  onLoadStop:
                      (InAppWebViewController controller, Uri? url) async {
                    print("Stopped loading: $url");
                  },
                  onLoadError: (InAppWebViewController controller, Uri? url,
                      int code, String message) {
                    print(
                        "Error loading: $url with code: $code and message: $message");
                  },
                  onLoadHttpError: (InAppWebViewController controller, Uri? url,
                      int statusCode, String description) {
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
    );
  }
}
