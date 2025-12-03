import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/exercise_model.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/machine_detail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';

Widget buildMachinesGrid(BuildContext context, List<ExerciseModel> exercises, {String highlightTerm = ""}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Theme.of(context).colorScheme.surface.withOpacity(0.9),
          Theme.of(context).colorScheme.surface,
        ],
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.75,
        ),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return _buildMachineCard(context, exercises[index], highlightTerm);
        },
      ),
    ),
  );
}

Widget _buildMachineCard(BuildContext context, ExerciseModel exercise, String highlightTerm) {
  final locale = context.watch<LanguageCubit>().state.locale.languageCode;
  final name = exercise.name[locale] ?? exercise.name['en'] ?? 'Unknown';

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MachineDetailScreen(exercise: exercise),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Machine Image
            Image.network(
              exercise.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, size: 30),
              ),
            ),
            // Semi-transparent overlay with machine name
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.surface.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: _buildHighlightedText(context, name, highlightTerm),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildHighlightedText(BuildContext context, String text, String term) {
  if (term.isEmpty) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 12,
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
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      children: matches,
    ),
    textAlign: TextAlign.center,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}
