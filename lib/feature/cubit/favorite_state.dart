import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/core/utils/machine.dart';

class FavoritesState extends Equatable {
  final List<Machine> favorites;

  const FavoritesState({required this.favorites});

  @override
  List<Object> get props => [favorites];
}