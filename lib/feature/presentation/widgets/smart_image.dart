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
  });

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
    if (_urlCache.containsKey(path)) {
      return _urlCache[path];
    }

    // Safety Check 4: Ask Firebase (Protected by Try-Catch)
    try {
      final url = await FirebaseStorage.instance.ref(path).getDownloadURL();
      _urlCache[path] = url; // Save to cache
      return url;
    } catch (e) {
      debugPrint("Error fetching image ($path): $e");
      return null; // Return null instead of crashing
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for KeepAlive

    return FutureBuilder<String?>(
      future: _linkFuture,
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(color: const Color(0xFF1C1C1E)); 
        }

        // 2. Error/Null State
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildPlaceholder();
        }

        // 3. Success State
        return CachedNetworkImage(
          imageUrl: snapshot.data!,
          fit: widget.fit,
          placeholder: (context, url) => Container(color: const Color(0xFF1C1C1E)),
          errorWidget: (context, url, error) => _buildPlaceholder(),
          fadeInDuration: const Duration(milliseconds: 200),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1C1C1E),
      child: Center(
        child: Icon(
          Icons.fitness_center, 
          color: Colors.white.withOpacity(0.1), 
          size: 24,
        ),
      ),
    );
  }
}