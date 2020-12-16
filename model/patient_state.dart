import 'dart:math';

import '../main.dart';
import 'patient.dart';

enum PatientState { MEDIUM, BAD, CRITICAL, RECOVERED, DEAD }

extension PatientStateChanges on PatientState {
  static PatientState determineCurrentState(
      Patient patient, double currentTime, bool isFromQueue) {
    double waitingTime = currentTime - patient.arrivalTime;
    int oneDayDuration = 1440;
    switch (patient.arrivalState) {
      case PatientState.MEDIUM:
        if (patient.isRecoveredOnSelfIsolation == null && isFromQueue) {
          double recoverProbability = Random().nextDouble();
          if (recoverProbability < Simulation.selfIsolationRecoveryProbability) {
            patient.isRecoveredOnSelfIsolation = true;
            return PatientState.RECOVERED;
          } else {
            patient.isRecoveredOnSelfIsolation = false;
          }
        }
        if (waitingTime < oneDayDuration * 7)
          return patient.arrivalState;
        else if (waitingTime < oneDayDuration * 10)
          return PatientState.BAD;
        else if (waitingTime < oneDayDuration * 15)
          return PatientState.CRITICAL;
        else
          return PatientState.DEAD;
        break;
      case PatientState.BAD:
        if (waitingTime < oneDayDuration * 5)
          return patient.arrivalState;
        else if (waitingTime < oneDayDuration * 7)
          return PatientState.CRITICAL;
        else
          return PatientState.DEAD;
        break;
      case PatientState.CRITICAL:
        if (waitingTime < oneDayDuration * 2.5)
          return patient.arrivalState;
        else
          return PatientState.DEAD;
        break;

      case PatientState.DEAD:
        return PatientState.DEAD;
      case PatientState.RECOVERED:
        return PatientState.RECOVERED;
    }
    return null;
  }
}
