import 'dart:math';

import '../model/patient.dart';
import '../model/patient_state.dart';

class RecoveryTimeGenerator {
  double generateRecoveryTime(Patient patient) {
    double lowerBound;
    double upperBound;
    double minutesInDay = 1440;

    switch(patient.acceptedState) {

      case PatientState.MEDIUM:
        lowerBound= minutesInDay * 14;
        upperBound= minutesInDay * 16;
        break;
      case PatientState.BAD:
        lowerBound= minutesInDay * 21;
        upperBound= minutesInDay * 25;
        break;
      case PatientState.CRITICAL:
        lowerBound= minutesInDay * 28;
        upperBound= minutesInDay* 32;
        break;
      case PatientState.DEAD:
        lowerBound= 0;
        upperBound= 0;
        break;
      case PatientState.RECOVERED:
        lowerBound= 0;
        upperBound= 0;
        break;
    }

    double randomNumber = Random().nextDouble();
    return lowerBound + (upperBound - lowerBound) * randomNumber;
  }
}