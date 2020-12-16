import 'patient_state.dart';

class Patient {
  static int patientsCount = 0;

  final int id;
  final double arrivalTime;
  final PatientState arrivalState;
  double acceptedTime;
  PatientState acceptedState;
  double departureTime;
  bool isRecoveredOnSelfIsolation;

  Patient(this.arrivalTime, this.arrivalState) : id = ++patientsCount;
}
