import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:latlong2/latlong.dart'; 
import '../../services/check_in_service.dart';
import '../../models/meeting.dart';
import 'check_in_event.dart';
import 'check_in_state.dart';

class CheckInBloc extends Bloc<CheckInEvent, CheckInState> {
  final CheckInService checkInService;
  
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<Position>? _positionSubscription;
  Meeting? _currentMeeting;
  double _checkInRangeMeters = 50.0;
  static const double _shakeThreshold = 15.0;
  LatLng? _lastKnownPosition;
  bool _shakeDetected = false;

  CheckInBloc({required this.checkInService /* removed required SupabaseClient supabase */})
      : super(CheckInInitial()) {
    on<StartCheckIn>(_onStartCheckIn);
    on<AccelerometerShakeDetected>(_onAccelerometerShakeDetected);
    on<ResetCheckIn>(_onResetCheckIn);
  }

  Future<void> _onStartCheckIn(
      StartCheckIn event, Emitter<CheckInState> emit) async {
    emit(CheckInLoading());
    _currentMeeting = event.meeting;
    _checkInRangeMeters = event.checkInRangeMeters;
    _shakeDetected = false;

    
    LocationPermission permission;
    try {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(CheckInFailure('Permissão de localização negada. Habilite nas configurações.'));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        emit(CheckInFailure('Permissão de localização permanentemente negada. Habilite nas configurações do app.'));
        return;
      }

      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(CheckInFailure('Serviço de localização desativado. Habilite o GPS.'));
        return;
      }

      
      _accelerometerSubscription?.cancel();
      double prevX = 0, prevY = 0, prevZ = 0;
      _accelerometerSubscription = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
        (AccelerometerEvent event) {
          double deltaX = (event.x - prevX).abs();
          double deltaY = (event.y - prevY).abs();
          double deltaZ = (event.z - prevZ).abs();

          double totalDelta = deltaX + deltaY + deltaZ;

          if (totalDelta > _shakeThreshold && !_shakeDetected) {
            _shakeDetected = true;
            add(const AccelerometerShakeDetected());
          }

          prevX = event.x;
          prevY = event.y;
          prevZ = event.z;
        },
        onError: (e) {
          print('Accelerometer error: $e');
        },
        cancelOnError: true,
      );

      
      _positionSubscription?.cancel();
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(
        (Position position) {
          _lastKnownPosition = LatLng(position.latitude, position.longitude);
        },
        onError: (e) {
          print('GPS stream error: $e');
          emit(CheckInFailure('Erro ao obter localização: $e'));
          _positionSubscription?.cancel();
        },
        cancelOnError: true,
      );

      emit(CheckInReadyForShake());
    } catch (e) {
      emit(CheckInFailure('Erro ao iniciar o check-in: $e'));
    }
  }

  Future<void> _onAccelerometerShakeDetected(
      AccelerometerShakeDetected event, Emitter<CheckInState> emit) async {
    if (state is CheckInReadyForShake || state is CheckInProcessing) {
      if (_currentMeeting == null ||
          _currentMeeting!.lat == null ||
          _currentMeeting!.long == null) {
        emit(CheckInFailure('Dados da reunião (localização) indisponíveis.'));
        _shakeDetected = false;
        return;
      }

      emit(CheckInProcessing());

      
      

      
      if (_lastKnownPosition == null) {
        try {
          final Position freshPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10),
          );
          _lastKnownPosition = LatLng(freshPosition.latitude, freshPosition.longitude);
        } catch (e) {
          emit(CheckInFailure('Não foi possível obter a localização GPS. Tente novamente. Erro: $e'));
          _shakeDetected = false;
          return;
        }
      }

      
      final Distance distanceCalculator = const Distance();
      final meetingLatLng = LatLng(_currentMeeting!.lat!, _currentMeeting!.long!);
      final double distance = distanceCalculator(
        _lastKnownPosition!,
        meetingLatLng,
      );

      print('Distance to meeting: $distance meters');
      print('Meeting Lat/Long: ${meetingLatLng.latitude}, ${meetingLatLng.longitude}');
      print('Current Lat/Long: ${_lastKnownPosition!.latitude}, ${_lastKnownPosition!.longitude}');
      print('Check-in range: $_checkInRangeMeters meters');

      if (distance <= _checkInRangeMeters) {
        try {
          
          await checkInService.updateMeetingAttendance(
            meetingId: _currentMeeting!.id,
            attended: true,
          );
          emit(CheckInSuccess('Check-in realizado com sucesso!'));
        } catch (e) {
          
          emit(CheckInFailure('Erro ao registrar presença: ${e.toString()}'));
        }
      } else {
        emit(CheckInFailure('Você está a ${distance.toStringAsFixed(2)} metros da reunião. Chegue mais perto para fazer o check-in (alcance: ${_checkInRangeMeters.toStringAsFixed(0)}m).'));
      }
      _shakeDetected = false;
    }
  }

  void _onResetCheckIn(ResetCheckIn event, Emitter<CheckInState> emit) {
    _shakeDetected = false;
    emit(CheckInInitial());
  }

  @override
  Future<void> close() {
    _accelerometerSubscription?.cancel();
    _positionSubscription?.cancel();
    return super.close();
  }
}