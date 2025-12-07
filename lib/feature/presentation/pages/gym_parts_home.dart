
import 'package:flutter/material.dart';
import 'package:flutter_application_1/feature/presentation/pages/muscle_list_screen.dart';
import 'package:flutter_application_1/feature/presentation/widgets/smart_image.dart';
import 'package:flutter_application_1/feature/presentation/widgets/keep_alive_wrapper.dart'; // <--- IMPORT
import 'package:lottie/lottie.dart';
import 'package:flutter_application_1/core/repositories/gym_repository.dart';
import 'package:flutter_application_1/core/models/body_part_model.dart';
import 'package:flutter_application_1/core/di/injection_container.dart' as di;

class GymPartScreen extends StatefulWidget {
  const GymPartScreen({super.key});

  @override
  State<GymPartScreen> createState() => _GymPartScreenState();
}

class _GymPartScreenState extends State<GymPartScreen> {
  late PageController _pageController;
  double _currentPage = 0.0;
  List<BodyPartModel> _bodyParts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });

    _loadBodyParts();
  }

  Future<void> _loadBodyParts() async {
    try {
      final parts = await di.sl<GymRepository>().fetchBodyParts();
      if (mounted) {
        setState(() {
          _bodyParts = parts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF141414), Color(0xFF000000)],
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 32,
                        height: 1.1,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                      ),
                      children: [
                        const TextSpan(text: "What do you want\nto train today "),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Lottie.asset(
                            'assets/lottie/arm.json',
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const TextSpan(text: "?"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Hero Carousel (The New Design)
                Expanded(
                  child: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                          : _buildHeroCarousel(),
                ),
                
                const SizedBox(height: 140), // <--- INCREASED SPACE FOR NAV BAR
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCarousel() {
    if (_bodyParts.isEmpty) {
      return const Center(child: Text("No body parts found", style: TextStyle(color: Colors.white)));
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _bodyParts.length,
      itemBuilder: (context, index) {
        final bodyPart = _bodyParts[index];
        
        // Parallax & Scale Logic
        double value = 0.0;
        if (_pageController.position.haveDimensions) {
          value = index - _currentPage;
          value = (value * 0.038).clamp(-1, 1);
        } else {
           value = (index == 0) ? 0.0 : 1.0; 
        }
        
        final distanceFromCenter = (index - _currentPage).abs();
        final scale = 1.0 - (distanceFromCenter * 0.1).clamp(0.0, 0.2);
        final opacity = 1.0 - (distanceFromCenter * 0.5).clamp(0.0, 0.5);

        return KeepAliveWrapper(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: HeroCard(
                title: bodyPart.name,
                subtitle: "Train now", 
                imageUrl: bodyPart.image,
                onTap: () => _navigateToCategory(bodyPart),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToCategory(BodyPartModel bodyPart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MuscleListScreen(
          bodyPartId: bodyPart.id, 
          bodyPartName: bodyPart.name,
        ),
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const HeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image REPLACED with SmartImage
              SmartImage(
                imageUrl: imageUrl, 
                fit: BoxFit.cover,
              ),

              // Overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black87, // Darker at bottom
                      Colors.black,
                    ],
                    stops: [0.0, 0.5, 0.8, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
