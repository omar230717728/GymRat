import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class YouTubeVideoScreen extends StatefulWidget {
  final String videoUrl;

  const YouTubeVideoScreen({super.key, required this.videoUrl});

  @override
  _YouTubeVideoScreenState createState() => _YouTubeVideoScreenState();
}

class _YouTubeVideoScreenState extends State<YouTubeVideoScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? "",
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workoutVideo),
        backgroundColor: Colors.black,
      ),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}
