import 'district.dart';
import 'patient.dart';

enum EventType { ARRIVAL, DISCHARGE }

abstract class SystemEvent {
  EventType getEventType();

  double getEventTime();
}

class ArrivalEvent implements SystemEvent {
  final Patient patient;

  ArrivalEvent(this.patient);

  @override
  double getEventTime() {
    return patient.arrivalTime;
  }

  @override
  EventType getEventType() {
    return EventType.ARRIVAL;
  }
}

class DischargeEvent implements SystemEvent {
  final Patient patient;
  final District hospitalDistrict;

  DischargeEvent(this.patient, this.hospitalDistrict);

  @override
  double getEventTime() {
    return patient.departureTime;
  }

  @override
  EventType getEventType() {
    return EventType.DISCHARGE;
  }
}
