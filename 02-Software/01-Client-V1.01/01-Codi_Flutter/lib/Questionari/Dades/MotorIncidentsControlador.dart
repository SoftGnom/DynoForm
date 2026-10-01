import 'package:flutter/material.dart';

// El gestor d'estat central per al control global de l'aplicació 
class MotorIncidentsControlador with ChangeNotifier {
  int? _idIncidentActiu;
  bool _estaSincronitzantAmbServidor = false;

  int? get idIncidentActiu => _idIncidentActiu;
  bool get estaSincronitzant => _estaSincronitzantAmbServidor;

  /// Assigna l'incident de treball a la tauleta
  void seleccionarIncident(int id) {
    _idIncidentActiu = id;
    notifyListeners();
  }

  /// Canvia l'estat de la icona de cobertura/sincronització de dades
  void canviarEstatSincronitzacio(bool estat) {
    _estaSincronitzantAmbServidor = estat;
    notifyListeners();
  }
}

/*
 *
 */
