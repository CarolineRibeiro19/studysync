import 'package:equatable/equatable.dart';
import '../../models/meeting.dart';

abstract class CheckInEvent extends Equatable {
  const CheckInEvent();

  @override
  List<Object?> get props => [];
}

class StartCheckIn extends CheckInEvent {
  final Meeting meeting;
  final double checkInRangeMeters; 

  const StartCheckIn(this.meeting, {this.checkInRangeMeters = 50.0}); 

  @override
  List<Object?> get props => [meeting, checkInRangeMeters];
}


class AccelerometerShakeDetected extends CheckInEvent {
  const AccelerometerShakeDetected();
}


class ResetCheckIn extends CheckInEvent {}