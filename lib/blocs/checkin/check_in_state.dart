import 'package:equatable/equatable.dart';

abstract class CheckInState extends Equatable {
  const CheckInState();

  @override
  List<Object?> get props => [];
}


class CheckInInitial extends CheckInState {}


class CheckInLoading extends CheckInState {
  final String message;
  const CheckInLoading({this.message = 'Verificando permissões e sensores...'});

  @override
  List<Object?> get props => [message];
}


class CheckInReadyForShake extends CheckInState {
  final String message;
  const CheckInReadyForShake({this.message = 'Balance o celular para fazer o check-in!'});

  @override
  List<Object?> get props => [message];
}


class CheckInProcessing extends CheckInState {
  final String message;
  const CheckInProcessing({this.message = 'Detectando movimento e obtendo localização...'});

  @override
  List<Object?> get props => [message];
}


class CheckInSuccess extends CheckInState {
  final String message;
  const CheckInSuccess(this.message);

  @override
  List<Object?> get props => [message];
}


class CheckInFailure extends CheckInState {
  final String message;
  const CheckInFailure(this.message);

  @override
  List<Object?> get props => [message];
}