import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/feature/cubit/machine_list_cubit.dart';
import 'package:flutter_application_1/feature/cubit/language_cubit.dart';
import 'package:flutter_application_1/feature/presentation/pages/exercise_list_screen.dart';
import 'package:flutter_application_1/feature/cubit/progress_cubit.dart';

class MachineListScreen extends StatefulWidget {
  final String bodyPartId;
  final String muscleId;
  final Map<String, String> muscleName;

  const MachineListScreen({
    super.key,
    required this.bodyPartId,
    required this.muscleId,
    required this.muscleName,
  });

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MachineListCubit>().loadMachines(widget.bodyPartId, widget.muscleId);
    context.read<ProgressCubit>().logVisit(
      muscleName: widget.muscleName['en'] ?? widget.muscleName.values.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.select((LanguageCubit cubit) => cubit.state.locale.languageCode);
    final title = widget.muscleName[languageCode] ?? widget.muscleName['en'] ?? 'Machines';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BlocBuilder<MachineListCubit, MachineListState>(
        builder: (context, state) {
          if (state is MachineListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MachineListLoaded) {
            return ListView.builder(
              itemCount: state.machines.length,
              itemBuilder: (context, index) {
                final machine = state.machines[index];
                final machineName = machine.name[languageCode] ?? machine.name['en'] ?? 'Unknown';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: machine.imageUrl.isNotEmpty ? NetworkImage(machine.imageUrl) : null,
                    child: machine.imageUrl.isEmpty ? const Icon(Icons.fitness_center) : null,
                  ),
                  title: Text(machineName),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseListScreen(
                          bodyPartId: widget.bodyPartId,
                          muscleId: widget.muscleId,
                          machineId: machine.id,
                          machineName: machine.name,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is MachineListError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Select a muscle'));
        },
      ),
    );
  }
}
