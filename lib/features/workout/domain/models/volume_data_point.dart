import 'package:equatable/equatable.dart';

class VolumeDataPoint extends Equatable {
  final DateTime date;
  final double tonnage;

  const VolumeDataPoint({
    required this.date,
    required this.tonnage,
  });

  @override
  List<Object?> get props => [date, tonnage];
}

class VolumeTonnageReport extends Equatable {
  final List<VolumeDataPoint> points;
  final double totalTonnage30Days;

  const VolumeTonnageReport({
    required this.points,
    required this.totalTonnage30Days,
  });

  @override
  List<Object?> get props => [points, totalTonnage30Days];
}
