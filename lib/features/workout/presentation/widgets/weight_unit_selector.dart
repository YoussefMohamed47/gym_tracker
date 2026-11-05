import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/weight_converter.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';

class WeightUnitSelector extends StatelessWidget {
  const WeightUnitSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutCubit, WorkoutState>(
      buildWhen: (previous, current) =>
          previous.displayUnit != current.displayUnit,
      builder: (context, state) {
        return SegmentedButton<WeightUnit>(
          segments: const [
            ButtonSegment<WeightUnit>(
              value: WeightUnit.kg,
              label: Text('KG', style: TextStyle(fontSize: 12)),
            ),
            ButtonSegment<WeightUnit>(
              value: WeightUnit.lb,
              label: Text('LB', style: TextStyle(fontSize: 12)),
            ),
          ],
          selected: {state.displayUnit},
          onSelectionChanged: (Set<WeightUnit> newSelection) {
            context.read<WorkoutCubit>().setPreferredUnit(newSelection.first);
          },
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      },
    );
  }
}
