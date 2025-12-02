import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/auth/login_required_popup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/feature/cubit/favorites_cubit.dart';
import 'package:flutter_application_1/feature/cubit/favorite_state.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/machine_detail.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FavoritesCubit>().loadFavorites();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.microtask(() => showLoginRequiredPopup(context));
      return const SizedBox();
    }
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final favorites = state.favorites;

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noFavorites,
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.startAddingFavorites,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final machine = favorites[index];
            return Dismissible(
              key: Key(machine.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                context.read<FavoritesCubit>().toggleFavorite(machine);
                final locale = context.read<LanguageCubit>().state.locale.languageCode;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${machine.getName(locale)} ${AppLocalizations.of(context)!.removedFromFavorites}")),
                );
              },
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white, size: 30),
              ),
              child: _buildGridItem(context, machine),
            );
          },
        );
      },
    );
  }

  Widget _buildGridItem(BuildContext context, Machine machine) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MachineDetailScreen(machine: machine),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Hero(
                  tag: machine.id,
                  child: Image.network(
                    machine.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.getName(context.watch<LanguageCubit>().state.locale.languageCode),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    machine.bodyPart.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
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
