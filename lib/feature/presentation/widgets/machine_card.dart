import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/machine_model.dart';
import 'package:flutter_application_1/feature/presentation/widgets/smart_image.dart'; // <--- IMPORT
import 'package:shimmer/shimmer.dart';

class MachineCard extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback? onTap;
  final String highlightTerm;

  const MachineCard({
    super.key,
    required this.machine,
    this.onTap,
    this.highlightTerm = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // Ensure image/gradient stays inside
      color: const Color(0xFF1A1A1A),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Full Image
            SmartImage(
              imageUrl: machine.image,
              fit: BoxFit.cover,
            ),

            // Layer 2: Gradient Overlay (Bottom)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Center(
                  child: _buildHighlightedText(context, machine.name, highlightTerm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(BuildContext context, String text, String term) {
    if (term.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerTerm = term.toLowerCase();
    final matches = <TextSpan>[];

    int start = 0;
    int index = lowerText.indexOf(lowerTerm, start);

    while (index != -1) {
      if (index > start) {
        matches.add(TextSpan(text: text.substring(start, index)));
      }
      matches.add(TextSpan(
        text: text.substring(index, index + term.length),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ));
      start = index + term.length;
      index = lowerText.indexOf(lowerTerm, start);
    }

    if (start < text.length) {
      matches.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        children: matches,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
