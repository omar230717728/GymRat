import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/auth/login_required_popup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/core/utils/machine.dart';
import 'package:flutter_application_1/feature/cubit/favorites_cubit.dart';
import 'package:flutter_application_1/feature/cubit/favorite_state.dart';
import 'package:flutter_application_1/feature/presentation/pages/details_screen/machine_detail.dart';

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
          return const Center(
            child: Text("No favorites yet!", style: TextStyle(fontSize: 18)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final machine = favorites[index];
            return _buildItem(context, machine);
          },
        );
      },
    );
  }

  Widget _buildItem(BuildContext context, Machine machine) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            machine.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        ),
        title: Text(
          machine.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          machine.description.length > 60
              ? "${machine.description.substring(0, 60)}..."
              : machine.description,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            context.read<FavoritesCubit>().toggleFavorite(machine);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MachineDetailScreen(machine: machine),
            ),
          );
        },
      ),
    );
  }
}
