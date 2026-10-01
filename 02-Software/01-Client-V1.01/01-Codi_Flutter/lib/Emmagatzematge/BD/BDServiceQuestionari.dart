

// ==========================================
//  FILL SINGLETON (1 COL·LECCIONS)
// ==========================================

import 'package:DynoForm/Emmagatzematge/BD/BDService.dart';


// Colecions
const int _QUESTIONARI = 0;

const List<String> _COLECCIONS = ['questionari'];


class BDServiceQuestionari extends BDService {

  // --- ESTRUCTURA DEL PATRÓ SINGLETON NADIU EN DART ---

  /// Instància única de la classe
  static BDServiceQuestionari? _instance;

  /// El constructor privat
  BDServiceQuestionari._internal();

  /// Metodie d'inicialitzador Asíncron
  static Future<bool> init(String contrasenya) async {
    final prova = BDServiceQuestionari._internal();

    // Cridem al mètode del pare
    bool exit = await prova.obrirBaseDeDades(contrasenya, "questionari");

    if (exit) {
      prova.initColeccions(_COLECCIONS[_QUESTIONARI]);

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
  factory BDServiceQuestionari() {
    if (_instance == null) {
      throw Exception("Error: No pots fer servir la BD perquè no s'ha iniciat sessió correctament.");
    }
    return _instance!;
  }


// ----------------------------------------------------

// --- ESTRUCTURA DE LA CLASE ---

  /// Guarda la configuració estructural matriu del qüestionari (ID 0)
  ///
  /// Rep un [Map] que inclou de forma unificada 'preguntesBlocks' (definició de formularis)
  /// i 'fillsBlocks' (metadades per a la generació automàtica de mòduls fills).
  Future<void> guardarArbreBlocs(int idQuestionari, Map<String, dynamic> mapaConfiguracioGlobal) async {
    // Invoquem el mètode d'escriptura per ID emmagatzemant directament el mapa estructural
    await guardarPerId(_QUESTIONARI, idQuestionari, mapaConfiguracioGlobal);

    print("💾 [BD Questionari]: Esquelet i regles del qüestionari xifrades amb èxit a la ID fixa: $idQuestionari");
  }

  /// Carrega el mapa estructural de control amb el que es dissenyarà la UI dinàmicament
  ///
  /// Retorna un [Map<String, dynamic>] que el controlador o les vistes desglossaran
  /// per obtenir les llistes de preguntes amb les seves propietats base de privadesa.
  Future<Map<String, dynamic>?> carregarArbreBlocs(int idQuestionari) async {
    // Executem una lectura directa d'alta eficiència O(1) mitjançant la ID del registre
    final snapshot = await llegirPerId(_QUESTIONARI, idQuestionari);

    if (snapshot != null) {
      // Retornem el mapa complet desxifrat directament (sense extreure la clau 'blocs'
      // ja que ara guardem el mapa matriu que conté directament 'preguntesBlocks' i 'fillsBlocks')
      return snapshot;
    }

    print("⚠️ [BD Questionari]: No s'ha trobat cap estructura matriu per a la ID: $idQuestionari");
    return null;
  }
}


