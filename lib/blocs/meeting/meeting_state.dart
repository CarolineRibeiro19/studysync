import 'package:equatable/equatable.dart';
import '../../models/meeting.dart';

abstract class MeetingState extends Equatable {
  const MeetingState();

  @override
  List<Object?> get props => [];
}

class MeetingInitial extends MeetingState {}

class MeetingLoading extends MeetingState {}

class MeetingLoaded extends MeetingState {
  final List<Meeting> meetings;

  const MeetingLoaded(this.meetings);

  @override
  List<Object?> get props => [meetings];
}

class MeetingError extends MeetingState {
  final String message;

  const MeetingError(this.message);

  @override
  List<Object?> get props => [message];
}