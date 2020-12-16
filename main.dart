import 'dart:collection';

import 'model/event.dart';
import 'model/patient.dart';
import 'model/district.dart';
import 'model/hospital.dart';
import 'utils/patient_generator.dart';

void main() {
  var cityHospitals = HashMap<District, Hospital>();
  District.values.forEach((district) {
    cityHospitals[district] = Hospital(district);
  });

  var simulation = Simulation(cityHospitals);
  simulation.startSimulation();
}

class Simulation {
  static double currentSystemTime = 0;
  static const double numOfSimulationDays = 92.0;
  static const double simulationEndTime = 60.0 * 24.0 * numOfSimulationDays;

  // 1 пациент в 4.8 минуты (~300 пациентов в день)
  static const double patientsArrivalRate = 0.21;
  static const double selfIsolationRecoveryProbability = 0.75;

  // Кол-во коек в городе
  // Пациент поступивший в критическом состоянии умирает через 1 день ожидания в очереди 4600 коек
  // Пациент поступивший в критическом состоянии умирает через 1.5 день ожидания в очереди 4100 коек
  // Пациент поступивший в критическом состоянии умирает через 2 день ожидания в очереди 3900 коек

  static const int availableWards = 670;

  PatientGenerator patientGenerator = PatientGenerator(patientsArrivalRate);
  List<SystemEvent> events = List();
  final Map<District, Hospital> cityHospitals;

  Simulation(this.cityHospitals) {
    _setupSimulation();
    events.add(ArrivalEvent(patientGenerator.generate()));
  }

  void startSimulation() {
    while (currentSystemTime < simulationEndTime) {
      simulate();
    }
    cityHospitals.values.forEach((hospital) {
      hospital.printReport();
    });
    _printReport();
  }

  void simulate() {
    _reorderEvents();
    var eventsToHandle = _getNextEvents();
    updateTime(eventsToHandle.first);
    _handleEvents(eventsToHandle);
  }

  updateTime(SystemEvent currentEvent) {
    currentSystemTime = currentEvent.getEventTime();
  }

  List<SystemEvent> _getNextEvents() {
    var nextEvent = events.removeAt(0);
    List<SystemEvent> nextEvents = [nextEvent];
    while (events.isNotEmpty &&
        events.first.getEventTime() == nextEvent.getEventTime()) {
      nextEvents.add(events.removeAt(0));
    }
    return nextEvents;
  }

  void _handleEvents(List<SystemEvent> eventsToHandle) {
    eventsToHandle.forEach((event) {
      switch (event.getEventType()) {
        case EventType.ARRIVAL:
          _handleArrival(event);
          break;
        case EventType.DISCHARGE:
          _handleDischarge(event);
          break;
      }
    });
  }

  void _handleArrival(ArrivalEvent arrivalEvent) {
    District patientDistrict = DistrictDistributor.distribute();
    cityHospitals[patientDistrict].healPatient(arrivalEvent.patient);
    _generateNewArrival();
  }

  void _generateNewArrival() {
    var newPatient = patientGenerator.generate();
    events.add(ArrivalEvent(newPatient));
  }

  void _handleDischarge(DischargeEvent dischargeEvent) {
    cityHospitals[dischargeEvent.hospitalDistrict]
        .dischargePatient(dischargeEvent.patient);
  }

  void _setupSimulation() {
    Function(Patient, District) onDischargeEvent = (patient, district) {
      var event = DischargeEvent(patient, district);
      events.add(event);
    };
    cityHospitals.values.forEach((hospital) {
      hospital.initiateDischargeEvent = onDischargeEvent;
    });
  }

  void _reorderEvents() {
    if (events.length < 2) return;
    events.sort((a, b) {
      if (a.getEventTime() > b.getEventTime())
        return 1;
      else if (a.getEventTime() < b.getEventTime())
        return -1;
      else
        return 0;
    });
  }

  _printReport() {
    int totalDead = 0;
    int totalRecovered = 0;
    int totalRecoveredOnSelfIsolation = 0;
    cityHospitals.values.forEach((hospital) {
      totalDead += hospital.deadPatients;
      totalRecovered += hospital.recoveredPatients;
      totalRecoveredOnSelfIsolation +=
          hospital.recoveredPatientsOnSelfIsolation;
    });
    print("Total number of patients in system: ${Patient.patientsCount}");
    print(
        "Average number of patients per day: ${(Patient.patientsCount / numOfSimulationDays).toStringAsFixed(2)}");
    print(
        "Total recovered hospital patients: $totalRecovered (${(totalRecovered / Patient.patientsCount * 100).toStringAsFixed(2)}%)");
    print(
        "Total recovered on self-isolation patients: $totalRecoveredOnSelfIsolation (${(totalRecoveredOnSelfIsolation / Patient.patientsCount * 100).toStringAsFixed(2)}%)");
    print(
        "Total dead hospital patients: $totalDead (${(totalDead / Patient.patientsCount * 100).toStringAsFixed(2)}%)");

  }
}
