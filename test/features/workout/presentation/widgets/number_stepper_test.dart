import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/number_stepper.dart';

void main() {
  group('NumberStepper Widget Tests', () {
    testWidgets('renders label, value, and unit correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberStepper(
              label: 'WEIGHT',
              valueText: '80.0',
              unit: 'KG',
              onIncrement: () {},
              onDecrement: () {},
            ),
          ),
        ),
      );

      expect(find.text('80.0'), findsOneWidget);
      expect(find.text('KG'), findsOneWidget);
    });

    testWidgets('tapping plus icon calls onIncrement', (tester) async {
      int value = 10;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NumberStepper(
                  label: 'REPS',
                  valueText: '$value',
                  onIncrement: () => setState(() => value++),
                  onDecrement: () => setState(() => value--),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();

      expect(find.text('11'), findsOneWidget);
      expect(value, 11);
    });

    testWidgets('tapping minus icon calls onDecrement', (tester) async {
      int value = 10;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NumberStepper(
                  label: 'REPS',
                  valueText: '$value',
                  onIncrement: () => setState(() => value++),
                  onDecrement: () => setState(() => value--),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();

      expect(find.text('9'), findsOneWidget);
      expect(value, 9);
    });

    testWidgets('tapping value calls onTapValue callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberStepper(
              label: 'WEIGHT',
              valueText: '60',
              onIncrement: () {},
              onDecrement: () {},
              onTapValue: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('60'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
