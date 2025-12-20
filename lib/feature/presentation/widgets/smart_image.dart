import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SmartImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<SmartImage> createState() => _SmartImageState();
}

class _SmartImageState extends State<SmartImage> with AutomaticKeepAliveClientMixin {
  // 1. STATIC CACHE (Global Memory)
  // Stores links we already found so we don't ask Firebase twice.
  static final Map<String, String> _urlCache = {};

  late Future<String?> _linkFuture;

  @override
  bool get wantKeepAlive => true; // Keeps image alive during scroll

  @override
  void initState() {
    super.initState();
    _linkFuture = _resolveUrl();
  }

  @override
  void didUpdateWidget(covariant SmartImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _linkFuture = _resolveUrl();
    }
  }

  Future<String?> _resolveUrl() async {
    final path = widget.imageUrl.trim();
    
    // Safety Check 1: Empty Path
    if (path.isEmpty) return null;

    // Safety Check 2: Already a Web Link
    if (path.startsWith('http')) return path;

    // Safety Check 3: Check Cache First (Instant Load)
    if (_urlCache.containsKey(path)) return _urlCache[path];

    // Safety Check 4: Ask Firebase
    try {
      final url = await FirebaseStorage.instance.ref(path).getDownloadURL();
      _urlCache[path] = url; // Save to cache
      return url;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Production Styles
    final loadingColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    final errorWidget = Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.white24),
      ),
    );

    return FutureBuilder<String?>(
      future: _linkFuture,
      builder: (context, snapshot) {
        // STATE 1: LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(color: loadingColor);
        }

        // STATE 2: ERROR
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return errorWidget;
        }

        // STATE 3: SUCCESS
        return CachedNetworkImage(
          imageUrl: snapshot.data!,
          fit: widget.fit,
          placeholder: (context, url) => Container(color: loadingColor),
          errorWidget: (context, url, error) => errorWidget,
        );
      },
    );
  }
}