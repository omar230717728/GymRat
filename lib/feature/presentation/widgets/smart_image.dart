import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorPlaceholder();
    }

    // Case A: It's already a full link (https://...)
    if (imageUrl.startsWith('http')) {
      return _buildNetworkImage(imageUrl);
    }

    // Case B: It's a Storage Path (images/...) -> Fetch URL
    return FutureBuilder<String>(
      future: FirebaseStorage.instance.ref(imageUrl).getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorPlaceholder();
        }
        return _buildNetworkImage(snapshot.data!);
      },
    );
  }

  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.broken_image, size: 24, color: Colors.white24),
      ),
    );
  }
}
