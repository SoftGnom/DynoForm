import 'package:flutter/material.dart';
import 'package:DynoForm/Emmagatzematge/BD/BDServiceQuestionari.dart';
import 'package:DynoForm/Emmagatzematge/BD/BDServiceIncidents.dart';
import 'package:DynoForm/Emmagatzematge/Estructures/InstanceNode.dart';

class QuestionariControlador with ChangeNotifier {
  final List<InstanceNode> llistaPlanaBlocs = [];
  int _incidentActualId = 0;
  String idBlocSeleccionat = "ARREL";

  Map<String, List<Map<String, dynamic>>> plantillesPreguntes = {};
  Map<String, Map<String, dynamic>?> metadadesCreacio = {};
  bool enCarrega = true;

  // =========================================================================
  // LOGICA INTEGRAL DE PRE-ORDER TREE TRAVERSAL (CERCA DE SUBARBRES)
  // =========================================================================

  /// Troba l'últim index absolut que pertany al subarbre d'un node passat per ID.
  /// Qualsevol element posterior amb una profunditat major forma part de la seva descendència.
  int _obtenirUltimIndexDescendent(String idNode) {
    int indexBase = llistaPlanaBlocs.indexWhere((n) => n.id == idNode);
    if (indexBase == -1) return -1;

    int i = indexBase + 1;
    while (i < llistaPlanaBlocs.length) {
      if (llistaPlanaBlocs[i].profunditat > llistaPlanaBlocs[indexBase].profunditat) {
        i++;
      } else {
        break;
      }
    }
    return i - 1;
  }

  // =========================================================================
  // COHESIÓ I INSERCIÓ SENSE INTERCALACIONS INVOLUNTÀRIES
  // =========================================================================

  void afegirSubBloc({required String idPare, required String tipus, required String titolBase}) {
    int indexPare = llistaPlanaBlocs.indexWhere((node) => node.id == idPare);
    if (indexPare == -1) return;

    InstanceNode nodePare = llistaPlanaBlocs[indexPare];

    int quantsFillsTeJa = llistaPlanaBlocs.where((node) => node.idPare == idPare && node.tipusPlantilla == tipus).length;
    int numeroNou = quantsFillsTeJa + 1;
    int novaProfunditat = nodePare.profunditat + 1;

    // Usem un identificador unic temporal basat en temps per evitar col·lisions en esborrats
    String nouId = "${idPare}_${tipus}_${DateTime.now().millisecondsSinceEpoch}";

    InstanceNode nouNode = InstanceNode(
      id: nouId,
      idPare: idPare,
      titol: "$titolBase $numeroNou",
      tipusPlantilla: tipus,
      profunditat: novaProfunditat,
      respostes: {},
    );

    int indexInsercio;
    var fillsMateixTipus = llistaPlanaBlocs.where((node) => node.idPare == idPare && node.tipusPlantilla == tipus).toList();

    if (fillsMateixTipus.isNotEmpty) {
      // Es col·loca al final de l'últim germà existent INCLOENT els fills d'aquest germà
      String idUltimGerma = fillsMateixTipus.last.id;
      indexInsercio = _obtenirUltimIndexDescendent(idUltimGerma) + 1;
    } else {
      // Si és el primer fill d'aquest tipus, va al final del subarbre actual del pare
      indexInsercio = _obtenirUltimIndexDescendent(idPare) + 1;
    }

    llistaPlanaBlocs.insert(indexInsercio, nouNode);
    idBlocSeleccionat = nouId;

    notifyListeners();
    _guardarA_Sembast();
  }

  // =========================================================================
  // ACCIONS DEL MENÚ LATERAL: ESBORRAT EN CASCADA I MOVEMENT DE PARE
  // =========================================================================

  void esborrarBloc(String idBlocAEliminar) {
    if (idBlocAEliminar == "ARREL") return;

    int index = llistaPlanaBlocs.indexWhere((node) => node.id == idBlocAEliminar);
    if (index == -1) return;

    List<InstanceNode> paquetAEliminar = [llistaPlanaBlocs[index]];
    _recollirDescendentsRecursius(idBlocAEliminar, paquetAEliminar);

    for (var node in paquetAEliminar) {
      llistaPlanaBlocs.remove(node);
    }

    if (idBlocSeleccionat == idBlocAEliminar) {
      idBlocSeleccionat = "ARREL";
    }

    notifyListeners();
    _guardarA_Sembast();
  }

  /// MÈTODE CORREGIT: Re-parentalitza un subarbre sencer i recalcula visualment la profunditat (+1 del pare)
  void redefinirPareDeBloc({required String idBlocAMoure, required String idNouPare}) {
    if (idBlocAMoure == "ARREL" || idBlocAMoure == idNouPare) return;

    int indexMogut = llistaPlanaBlocs.indexWhere((node) => node.id == idBlocAMoure);
    int indexNouPare = llistaPlanaBlocs.indexWhere((node) => node.id == idNouPare);
    if (indexMogut == -1 || indexNouPare == -1) return;

    InstanceNode nodeMogut = llistaPlanaBlocs[indexMogut];
    InstanceNode nouPare = llistaPlanaBlocs[indexNouPare];

    // Recollim el bloc i tota la seva llinatgia de sub-fills
    List<InstanceNode> subArbreFills = [];
    _recollirDescendentsRecursius(idBlocAMoure, subArbreFills);
    List<InstanceNode> paquetAMoure = [nodeMogut, ...subArbreFills];

    // Els extreiem de la seva ubicació antiga
    for (var node in paquetAMoure) {
      llistaPlanaBlocs.remove(node);
    }

    // L'optimització de profunditat: la nova profunditat és exactament la del pare + 1 (i es propaga als fills)
    int desplacamentNivell = (nouPare.profunditat + 1) - nodeMogut.profunditat;
    nodeMogut.idPare = idNouPare;

    for (var node in paquetAMoure) {
      node.profunditat += desplacamentNivell;
    }

    // Inserim el bloc sencer netament al final del subarbre del nou pare assignat
    int indexOnInserir = _obtenirUltimIndexDescendent(idNouPare) + 1;
    llistaPlanaBlocs.insertAll(indexOnInserir, paquetAMoure);

    idBlocSeleccionat = idBlocAMoure;
    notifyListeners();
    _guardarA_Sembast();
  }

  void _recollirDescendentsRecursius(String idPare, List<InstanceNode> resultat) {
    for (var i = 0; i < llistaPlanaBlocs.length; i++) {
      if (llistaPlanaBlocs[i].idPare == idPare) {
        resultat.add(llistaPlanaBlocs[i]);
        _recollirDescendentsRecursius(llistaPlanaBlocs[i].id, resultat);
      }
    }
  }

  // =========================================================================
  // INICIALITZACIÓ CENTRALITZADA I PERSISTÈNCIA
  // =========================================================================

  void inicialitzarNouIncident(int idIncident) {
    _incidentActualId = idIncident;
    llistaPlanaBlocs.clear();
    llistaPlanaBlocs.add(InstanceNode(
      id: "ARREL",
      idPare: null,
      titol: "Dades Generals Incident",
      tipusPlantilla: "general",
      profunditat: 0,
      respostes: {},
    ));
    idBlocSeleccionat = "ARREL";
    enCarrega = false;
    notifyListeners();
    _guardarA_Sembast();
  }

  Future<void> inicialitzarFluxIncident(int idIncident) async {
    try {
      enCarrega = true;
      notifyListeners();

      final Map<String, dynamic>? configuracioMatriu = await BDServiceQuestionari().carregarArbreBlocs(0);
      if (configuracioMatriu != null) {
        if (configuracioMatriu['preguntesBlocks'] != null) {
          final rawPreguntes = configuracioMatriu['preguntesBlocks'] as Map;
          plantillesPreguntes = rawPreguntes.map((key, value) {
            return MapEntry(key.toString(), (value as List).map((item) => Map<String, dynamic>.from(item as Map)).toList());
          });
        }
        if (configuracioMatriu['fillsBlocks'] != null) {
          final rawFills = configuracioMatriu['fillsBlocks'] as Map;
          metadadesCreacio = rawFills.map((key, value) {
            return MapEntry(key.toString(), value != null ? Map<String, dynamic>.from(value as Map) : null);
          });
        }
      }

      _incidentActualId = idIncident;
      llistaPlanaBlocs.clear();

      final dadesIncident = await BDServiceIncidents().carregarBlocsIncident(idIncident);
      if (dadesIncident != null) {
        for (var element in dadesIncident) {
          llistaPlanaBlocs.add(InstanceNode.fromJson(element));
        }
        idBlocSeleccionat = "ARREL";
        enCarrega = false;
        notifyListeners();
      } else {
        inicialitzarNouIncident(idIncident);
      }
    } catch (e) {
      enCarrega = false;
      notifyListeners();
    }
  }

  void _guardarA_Sembast() {
    if (enCarrega) return;
    final llistaJson = llistaPlanaBlocs.map((node) => node.toJson()).toList();
    BDServiceIncidents().guardarBlocsIncident(
      idIncident: _incidentActualId,
      llistaCompletaJson: llistaJson,
      definicioPreguntes: plantillesPreguntes,
    );
  }

  String obtenirValorCamp(String idBloc, String clauCamp) =>
      llistaPlanaBlocs.firstWhere((n) => n.id == idBloc, orElse: () => llistaPlanaBlocs.first).respostes[clauCamp] ?? "";

  void guardarValorCamp(String idBloc, String clauCamp, String valor) {
    int index = llistaPlanaBlocs.indexWhere((n) => n.id == idBloc);
    if (index == -1) return;
    if (valor.isEmpty) {
      llistaPlanaBlocs[index].respostes.remove(clauCamp);
    } else {
      llistaPlanaBlocs[index].respostes[clauCamp] = valor;
    }
    notifyListeners();
    _guardarA_Sembast();
  }
}
