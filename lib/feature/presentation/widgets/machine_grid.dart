import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/machine_model.dart';
import 'package:flutter_application_1/feature/presentation/widgets/machine_card.dart';

class MachineGridWidget extends StatelessWidget {
  final List<MachineModel> machines;
  final Function(MachineModel) onMachineTap;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final String highlightTerm;

  const MachineGridWidget({
    super.key,
    required this.machines,
    required this.onMachineTap,
    this.physics,
    this.shrinkWrap = false,
    this.highlightTerm = '',
  });

  @override
  Widget build(BuildContext context) {
    if (machines.isEmpty) {
      return const Center(
        child: Text(
          "No machines found",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: machines.length,
      itemBuilder: (context, index) {
        final machine = machines[index];
        return MachineCard(
          machine: machine,
          onTap: () => onMachineTap(machine),
          highlightTerm: highlightTerm,
        );
      },
    );
  }
}
