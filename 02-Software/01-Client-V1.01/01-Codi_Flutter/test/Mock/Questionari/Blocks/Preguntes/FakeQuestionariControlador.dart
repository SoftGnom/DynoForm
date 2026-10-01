import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:DynoForm/Emmagatzematge/Estructures/InstanceNode.dart';
import 'package:DynoForm/Questionari/Controlers/QuestionariControlador.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/FabricaPreguntes.dart';

/// 1. DOBLE DE PROVA (FAKE): Simula el controlador eliminant Sembast dels tests
class FakeQuestionariControlador extends ChangeNotifier implements QuestionariControlador {
  @override
  String idBlocSeleccionat = "BLOC_TEST";

  @override
  final List<InstanceNode> llistaPlanaBlocs = [];

  // Magatzem de dades en memòria neta per a la prova
  final Map<String, String> _memoriaRAMFake = {};

  String darreraClauModificada = "";
  String darrerValorModificat = "";

  @override
  String obtenirValorCamp(String idBloc, String clauCamp) {
    return _memoriaRAMFake["${idBloc}_$clauCamp"] ?? "";
  }

  @override
  void guardarValorCamp(String idBloc, String clauCamp, String valor) {
    _memoriaRAMFake["${idBloc}_$clauCamp"] = valor;
    darreraClauModificada = clauCamp;
    darrerValorModificat = valor;
    notifyListeners(); // Imprescindible per propagar el canvi d'estat
  }

  @override void inicialitzarNouIncident(int idIncident) {}
  @override Future<void> carregarIncidentExistent(int idIncident) async {}
  @override void afegirSubBloc({required String idPare, required String tipus, required String titolBase}) {}
}
