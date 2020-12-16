import 'dart:collection';

import '../main.dart';
import '../utils/recovery_time_generator.dart';
import 'district.dart';
import 'patient.dart';
import 'patient_state.dart';

class Hospital {
  final RecoveryTimeGenerator _recoveryTimeGenerator = RecoveryTimeGenerator();
  Function(Patient, District) initiateDischargeEvent;
  final District _district;
  String _name;
  final Map<int, Patient> _wards = HashMap();
  final List<Patient> _patientsQueue = List();
  int _capacity;

  List<Patient> _recoveredPatients = [];
  List<Patient> _recoveredOnSelfIsolationPatients = [];
  List<Patient> _deadPatients = [];
  List<int> _queueLengthRecords = [];

  int get deadPatients => _deadPatients.length;

  int get recoveredPatients => _recoveredPatients.length;

  int get recoveredPatientsOnSelfIsolation =>
      _recoveredOnSelfIsolationPatients.length;

  String get name => _name;

  Hospital(this._district) {
    _capacity =
        (Simulation.availableWards * _district.populationPercentage).round();
    _name = _district.name;
  }

  void healPatient(Patient patient) {
    if (_wards.length == _capacity) {
      _patientsQueue.add(patient);
    } else {
      _startToRecover(patient);
    }
    makeQueueRecord();
  }

  void dischargePatient(Patient patient) {
    _dischargePatient(patient);
    _checkQueue();
    makeQueueRecord();
  }

  void _startToRecover(Patient patient) {
    _wards[patient.id] = patient;
    patient.acceptedTime = Simulation.currentSystemTime;
    patient.acceptedState = PatientStateChanges.determineCurrentState(
        patient, Simulation.currentSystemTime, false);
    patient.departureTime = Simulation.currentSystemTime +
        _recoveryTimeGenerator.generateRecoveryTime(patient);
    initiateDischargeEvent(patient, _district);
  }

  void _dischargePatient(Patient patient) {
    _wards.remove(patient.id);
    _recoveredPatients.add(patient);
  }

  void _checkQueue() {
    _takeOutRedundant();
    if (_patientsQueue.isNotEmpty) {
//      var patient = _patientsQueue.firstWhere(
//          (element) => element.arrivalState == PatientState.CRITICAL,
//          orElse: () => _patientsQueue.first);
//      _patientsQueue.remove(patient);
      var patient = _patientsQueue.removeAt(0);
      _startToRecover(patient);
    }
  }

  void _takeOutRedundant() {
    List<int> deadPatientsIds = [];
    List<int> recoveredOnSelfIsolationPatientsIds = [];
    _patientsQueue.forEach((patient) {
      var currentPatientState = PatientStateChanges.determineCurrentState(
          patient, Simulation.currentSystemTime, true);
      if (currentPatientState == PatientState.DEAD) {
        deadPatientsIds.add(patient.id);
        _deadPatients.add(patient);
      } else if (currentPatientState == PatientState.RECOVERED) {
        recoveredOnSelfIsolationPatientsIds.add(patient.id);
        _recoveredOnSelfIsolationPatients.add(patient);
      }
      patient.acceptedTime = Simulation.currentSystemTime;
    });

    if (deadPatientsIds.isNotEmpty ||
        recoveredOnSelfIsolationPatientsIds.isNotEmpty) {
      _patientsQueue.removeWhere((patient) =>
          deadPatientsIds.contains(patient.id) ||
          recoveredOnSelfIsolationPatientsIds.contains(patient.id));
    }
  }

  void makeQueueRecord() {
    _queueLengthRecords.add(_patientsQueue.length);
  }

  void printReport() {
    double averageQueueLength = _queueLengthRecords.fold(
            0, (previousValue, element) => previousValue + element) /
        _queueLengthRecords.length;
    List<Patient> allPatientsInHospital =
        (_recoveredPatients + _deadPatients + _wards.values.toList());
    double averageWaitingTime = allPatientsInHospital.fold(
            0,
            (previousValue, patient) =>
                previousValue + (patient.acceptedTime - patient.arrivalTime)) /
        (allPatientsInHospital.length * 1440);
    double averageRecoveryTime = _recoveredPatients.fold(
            0,
            (previousValue, patient) =>
                previousValue + (patient.departureTime - patient.arrivalTime)) /
        (_recoveredPatients.length * 1440);
    print("---------------------------");
    print(_district.name);
    print(
        "Total number of patients: ${_recoveredPatients.length + _recoveredOnSelfIsolationPatients.length + _deadPatients.length + _patientsQueue.length + _wards.length}");
    print("Recovered: ${_recoveredPatients.length}");
    print(
        "Recovered on self-isolation: ${_recoveredOnSelfIsolationPatients.length}");
    print("Died in the queue: ${_deadPatients.length}");
    print("Recovering at the moment: ${_wards.length}");
    print("Average queue length: ${averageQueueLength.toStringAsFixed(2)}");
    print("Current queue length: ${_patientsQueue.length}");
    print(
        "Average waiting time: ${averageWaitingTime.toStringAsFixed(2)} days");
    print("Average recovery time: ${averageRecoveryTime.toStringAsFixed(2)} days");
    print("---------------------------");

//    _deadPatients.forEach((patient) {
//      print("-------------------DEAD-------------------");
//      print("Initial state: ${patient.arrivalState}");
//      print(
//          "Spent in queue: ${((patient.acceptedTime - patient.arrivalTime) / 1440).toStringAsFixed(2)} days");
//    });
  }
}
