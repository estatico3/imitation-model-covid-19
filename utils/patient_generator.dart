import 'dart:math';

import '../main.dart';
import '../model/patient.dart';
import '../model/patient_state.dart';

class PatientGenerator {
  final double _rate;

  PatientGenerator(this._rate);

  Patient generate() {
    double arrivalTime = Simulation.currentSystemTime + _generateTimeInterval();
    PatientState arrivalState = _generateState();
    return Patient(arrivalTime, arrivalState);
  }

  double _generateTimeInterval() {
    // in range from 0.0 to 1.0
    double randomNumber = Random().nextDouble();
    return ((-1 / _rate) * log(randomNumber));
  }

  PatientState _generateState() {
    double randomNumber = Random().nextDouble();
    if (randomNumber <= 0.85)
      return PatientState.MEDIUM;
    else if (randomNumber <= 0.95)
      return PatientState.BAD;
    else
      return PatientState.CRITICAL;
  }
}
