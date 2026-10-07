import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class TrailerPlayerScreen extends StatefulWidget {
  final String trailerUrl;
  final String title;
  final String? genre;
  final int? durationMinutes;
  final String? description;

  const TrailerPlayerScreen({
    super.key,
    required this.trailerUrl,
    required this.title,
    this.genre,
    this.durationMinutes,
    this.description,
  });

  static Future<void> open(
    BuildContext context, {
    required String trailerUrl,
    required String title,
    String? genre,
    int? durationMinutes,
    String? description,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TrailerPlayerScreen(
          trailerUrl: trailerUrl,
          title: title,
          genre: genre,
          durationMinutes: durationMinutes,
          description: description,
        ),
      ),
    );
  }

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullScreen() {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    if (_isFullScreen || isLandscape) {
      setState(() {
        _isFullScreen = false;
      });
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      setState(() {
        _isFullScreen = true;
      });
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  String? _extractYouTubeId(String url) {
    final cleanUrl = url.trim();
    final uri = Uri.tryParse(cleanUrl);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    }
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }
    final segments = uri.pathSegments;
    final embedIdx = segments.indexOf('embed');
    if (embedIdx != -1 && embedIdx + 1 < segments.length) {
      return segments[embedIdx + 1];
    }
    final shortsIdx = segments.indexOf('shorts');
    if (shortsIdx != -1 && shortsIdx + 1 < segments.length) {
      return segments[shortsIdx + 1];
    }

    final match = RegExp(
      r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([\w-]{11})',
    ).firstMatch(cleanUrl);
    return match?.group(1);
  }

  String _buildHtml(String url) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      height: 100%;
      background-color: #000000;
      overflow: hidden;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    video {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }
  </style>
</head>
<body>
  <video id="videoPlayer" controls autoplay playsinline>
    <source src="$url" type="video/mp4">
  </video>
</body>
</html>
''';
  }

  void _initController() {
    final videoId = _extractYouTubeId(widget.trailerUrl);

    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36',
        )
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              final url = request.url;
              if (url.startsWith('https://www.youtube.com/embed/') ||
                  url.startsWith('https://www.youtube-nocookie.com/embed/')) {
                return NavigationDecision.navigate;
              }
              if (url.contains('youtube.com/watch') ||
                  url.contains('youtu.be/')) {
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onPageFinished: (url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
              _controller?.runJavaScript('''
                (function() {
                  const style = document.createElement('style');
                  style.textContent = `
                    :root { color-scheme: dark !important; }
                    .ytp-bottom-sheet, .ytp-popup, .ytp-settings-menu, .ytp-panel-menu {
                      background: rgba(28, 28, 28, 0.95) !important;
                      color: #ffffff !important;
                    }
                    .ytp-menuitem-label, .ytp-menuitem-content, .ytp-bottom-sheet * {
                      color: #ffffff !important;
                    }
                    .ytp-bottom-sheet-drag-swipe {
                      background-color: #666666 !important;
                    }
                  `;
                  document.head.appendChild(style);
                })();
              ''');
            },
            onWebResourceError: (error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
        );

      if (_controller!.platform is AndroidWebViewController) {
        final androidCtrl = _controller!.platform as AndroidWebViewController;
        androidCtrl.setMediaPlaybackRequiresUserGesture(false);
        androidCtrl.setCustomWidgetCallbacks(
          onShowCustomWidget:
              (Widget customWidget, OnHideCustomWidgetCallback callback) {
                setState(() {
                  _isFullScreen = true;
                });
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
                SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.immersiveSticky,
                );
                Navigator.of(context)
                    .push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => Scaffold(
                          backgroundColor: Colors.black,
                          body: customWidget,
                        ),
                        fullscreenDialog: true,
                      ),
                    )
                    .then((_) {
                      if (mounted) {
                        setState(() {
                          _isFullScreen = false;
                        });
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                        SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.edgeToEdge,
                        );
                      }
                      callback();
                    });
              },
          onHideCustomWidget: () {
            if (mounted) {
              setState(() {
                _isFullScreen = false;
              });
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            }
            Navigator.of(context).maybePop();
          },
        );
      }

      if (videoId != null && videoId.isNotEmpty) {
        final embedUri = Uri.parse(
          'https://www.youtube.com/embed/$videoId?autoplay=1&playsinline=1&controls=1&rel=0&modestbranding=1&fs=0',
        );
        _controller!.loadRequest(
          embedUri,
          headers: const {'Referer': 'https://cineplex.vn/'},
        );
      } else {
        _controller!.loadHtmlString(
          _buildHtml(widget.trailerUrl),
          baseUrl: 'https://cineplex.vn',
        );
      }
    } catch (_) {
      _controller = null;
      _isLoading = false;
    }
  }

  Widget _buildVideoPlayer({required bool isFullScreen}) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: _controller != null
                ? WebViewWidget(controller: _controller!)
                : const SizedBox.shrink(),
          ),
        ),
        if (_isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
            ),
          ),
        // Nút phóng to / thu nhỏ ở góc dưới bên phải video
        Positioned(
          bottom: 10,
          right: 10,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleFullScreen,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  isFullScreen ? LucideIcons.minimize : LucideIcons.maximize,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isFullScreenMode = _isFullScreen || isLandscape;

    return PopScope(
      canPop: !isFullScreenMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isFullScreenMode) {
          _toggleFullScreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: !isFullScreenMode,
          bottom: !isFullScreenMode,
          left: false,
          right: false,
          child: isFullScreenMode
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: _buildVideoPlayer(isFullScreen: true),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            LucideIcons.arrowLeft,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: l10n.exitFullscreen,
                          onPressed: _toggleFullScreen,
                        ),
                      ),
                    ),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final maxVideoHeight = constraints.maxHeight * 0.45;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.arrowLeft,
                                  color: Colors.white,
                                ),
                                tooltip: l10n.back,
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 16:9 Video Player (bounded by maxVideoHeight so it never overflows)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: maxVideoHeight,
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _buildVideoPlayer(isFullScreen: false),
                          ),
                        ),

                        // Movie Info Details
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: theme.background,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(theme.spacingMd),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textPrimary,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      if (widget.durationMinutes != null &&
                                          widget.durationMinutes! > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.surfaceVariant,
                                            borderRadius: BorderRadius.circular(
                                              theme.radiusSm,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                LucideIcons.clock,
                                                size: 14,
                                                color: theme.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                l10n.durationMinutes(
                                                  widget.durationMinutes!,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: theme.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (widget.genre != null &&
                                          widget.genre!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.surfaceVariant,
                                            borderRadius: BorderRadius.circular(
                                              theme.radiusSm,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                LucideIcons.tags,
                                                size: 14,
                                                color: theme.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                widget.genre!,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: theme.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),

                                  if (widget.description != null &&
                                      widget.description!
                                          .trim()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.movieDescription,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.description!.trim(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: theme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
