

// ==========================================
//  FILL SINGLETON (2 COL·LECCIONS)
// ==========================================

import 'package:DynoForm/Emmagatzematge/BD/BDService.dart';


// Colecions
const int _PRIVATE = 0;
const int _PUBLIC = 1;

const List<String> _COLECCIONS = ['private', 'public'];

class BDServiceIncidents extends BDService {

  // --- ESTRUCTURA DEL PATRÓ SINGLETON NADIU EN DART ---

  /// Instància única de la classe
  static BDServiceIncidents? _instance;

  /// El constructor privat
  BDServiceIncidents._internal();

  /// Metodie d'inicialitzador Asíncron
  static Future<bool> init(String contrasenya) async {
    final prova = BDServiceIncidents._internal();

    // Cridem al mètode del pare
    bool exit = await prova.obrirBaseDeDades(contrasenya, "incidents");

    if (exit) {
      prova.initColeccions(_COLECCIONS[_PRIVATE]);
      prova.initColeccions(_COLECCIONS[_PUBLIC]);

      _instance = prova;
      return true;
    }
    _instance = null;
    return false;
  }

  /// MÈTODE DE TANCAMENT SIMÈTRIC (Logout / Bloqueig de seguretat)
  static Future<void> close() async {
    if (_instance != null) {
      // 1. Cridem al mètode '@protected' del pare per tancar el fitxer Sembast i buidar el Vector
      await _instance!.tancarBaseDeDades();

      // 2. Destruïm la instància d'aquesta classe a la memòria RAM.
      // Així, el proper cop que es vulgui utilitzar la BD, es forçarà a passar per l'init() amb contrasenya.
      _instance = null;

      print("Mòdul d'Incidents desconnectat i instància del Singleton alliberada.");
    }
  }

  /// 3. El punt d'accés global
  factory BDServiceIncidents() {
    if (_instance == null) {
      throw Exception("Error: No pots fer servir la BD perquè no s'ha iniciat sessió correctament.");
    }
    return _instance!;
  }


  // ----------------------------------------------------


  Future<void> guardarBlocsIncident({
    required int idIncident,
    required List<Map<String, dynamic>> llistaCompletaJson,
    required Map<String, List<Map<String, dynamic>>> definicioPreguntes,
  }) async {
    List<Map<String, dynamic>> copiaPublica = [];
    List<Map<String, dynamic>> copiaPrivada = [];

    // Recorrem l'arbre sencer en un únic bucle eficient
    for (var nodeOriginal in llistaCompletaJson) {
      // 1. Generem la rèplica per al calaix públic (Manté la jerarquia estructural completa)
      Map<String, dynamic> copiaNodePublic = {
        'id': nodeOriginal['id'],
        'idPare': nodeOriginal['idPare'],
        'titol': nodeOriginal['titol'],
        'tipusPlantilla': nodeOriginal['tipusPlantilla'],
        'profunditat': nodeOriginal['profunditat'],
        'respostes': <String, String>{}, // Es va omplint dinàmicament
      };

      // 2. Generem la rèplica per al calaix privat (Manté la jerarquia per poder fer el mapatge simètric)
      Map<String, dynamic> copiaNodePrivat = {
        'id': nodeOriginal['id'],
        'idPare': nodeOriginal['idPare'],
        'titol': nodeOriginal['titol'],
        'tipusPlantilla': nodeOriginal['tipusPlantilla'],
        'profunditat': nodeOriginal['profunditat'],
        'respostes': <String, String>{}, // Es va omplint dinàmicament
      };

      String tipusBloc = nodeOriginal['tipusPlantilla'] as String;
      Map<String, String> respostesOriginals = Map<String, String>.from(nodeOriginal['respostes'] as Map);
      final llistaPreguntesDefinides = definicioPreguntes[tipusBloc] ?? [];

      // Repartim les respostes analitzant la propietat base de la definició
      respostesOriginals.forEach((clauCamp, valor) {
        final defPregunta = llistaPreguntesDefinides.firstWhere(
              (p) => p['id_camp'] == clauCamp,
          orElse: () => <String, dynamic>{},
        );

        bool esPrivat = defPregunta['privat'] ?? false;

        if (esPrivat) {
          (copiaNodePrivat['respostes'] as Map)[clauCamp] = valor;
        } else {
          (copiaNodePublic['respostes'] as Map)[clauCamp] = valor;
        }
      });

      copiaPublica.add(copiaNodePublic);
      copiaPrivada.add(copiaNodePrivat);
    }

    // Emmagatzematge xifrat independent a Sembast
    await guardarPerId(_PUBLIC, idIncident, {'blocs': copiaPublica});
    await guardarPerId(_PRIVATE, idIncident, {'blocs': copiaPrivada});
    print("💾 [Sembast Cripto]: S'ha trossejat l'incident $idIncident en dues còpies independents de forma simultània.");
  }


  Future<List<Map<String, dynamic>>?> carregarBlocsIncident(int idIncident) async {
    final snapshotPublic = await llegirPerId(_PUBLIC, idIncident);
    final snapshotPrivat = await llegirPerId(_PRIVATE, idIncident);

    // Si no hi ha registre públic, l'incident no existeix (retornem null per demanar la ID 0)
    if (snapshotPublic == null || !snapshotPublic.containsKey('blocs')) {
      return null;
    }

    List<Map<String, dynamic>> llistaPublica = (snapshotPublic['blocs'] as List).cast<Map<String, dynamic>>();
    List<Map<String, dynamic>> llistaPrivada = [];

    if (snapshotPrivat != null && snapshotPrivat.containsKey('blocs')) {
      llistaPrivada = (snapshotPrivat['blocs'] as List).cast<Map<String, dynamic>>();
    }

    List<Map<String, dynamic>> llistaReconstruidaUnificada = [];

    // Recorrem la còpia pública i anem introduint les respostes de la còpia privada
    for (var nodePub in llistaPublica) {
      Map<String, dynamic> nodeUnificat = Map<String, dynamic>.from(nodePub);
      Map<String, String> respostesFusionades = Map<String, String>.from(nodePub['respostes'] as Map);

      // Busquem el node homòleg dins de la llista privada utilitzant la ID única del bloc
      final nodePrivatHomoleg = llistaPrivada.firstWhere(
            (n) => n['id'] == nodePub['id'],
        orElse: () => <String, dynamic>{},
      );

      if (nodePrivatHomoleg.containsKey('respostes') && nodePrivatHomoleg['respostes'] != null) {
        Map<String, String> respostesPrivades = Map<String, String>.from(nodePrivatHomoleg['respostes'] as Map);
        // Introduïm les dades privades a la col·lecció de respostes
        respostesFusionades.addAll(respostesPrivades);
      }

      nodeUnificat['respostes'] = respostesFusionades;
      llistaReconstruidaUnificada.add(nodeUnificat);
    }

    return llistaReconstruidaUnificada;
  }

  Future<Map<String, dynamic>?> getPublicIncident(int idIncident) async {
    final snapshotPublic = await llegirPerId(_PUBLIC, idIncident);

    // Si no hi ha registre públic, l'incident no existeix (retornem null per demanar la ID 0)
    if (snapshotPublic == null || !snapshotPublic.containsKey('blocs')) {
      return null;
    }

    return snapshotPublic;
  }

  Future<Map<String, dynamic>?> getPrivatIncident(int idIncident) async {
    final snapshotPrivat = await llegirPerId(_PRIVATE, idIncident);

    // Si no hi ha registre públic, l'incident no existeix (retornem null per demanar la ID 0)
    if (snapshotPrivat == null || !snapshotPrivat.containsKey('blocs')) {
      return null;
    }

    return snapshotPrivat;
  }

}



