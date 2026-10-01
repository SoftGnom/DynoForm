
// ==========================================
//   FILL SINGLETON (1 COL·LECCIÓ)
// ==========================================

import 'package:DynoForm/Emmagatzematge/BD/BDService.dart';

// Colecions
const int _INFO_APP = 0;

const List<String> _COLECCIONS = ['info'];


class BDServiceApp extends BDService {

  // --- ESTRUCTURA DEL PATRÓ SINGLETON NADIU EN DART ---

  // Instància única de la classe
  static BDServiceApp? _instance;

  // El constructor privat
  BDServiceApp._internal();

  // Metodie d'inicialitzador Asíncron
  static Future<bool> init(String contrasenya) async {
    final prova = BDServiceApp._internal();

    // Cridem al mètode del pare
    bool exit = await prova.obrirBaseDeDades(contrasenya, "app");

    if (exit) {
      prova.initColeccions(_COLECCIONS[_INFO_APP]);
      
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

  // 3. El punt d'accés global
  factory BDServiceApp() {
    if (_instance == null) {
      throw Exception("Error: No pots fer servir la BD perquè no s'ha iniciat sessió correctament.");
    }
    return _instance!;
  }

// ----------------------------------------------------

// --- ESTRUCTURA DE LA CLASE ---

  /// Recupera qualsevol valor des del disc a partir de la seva clau identificadora.
  Future<dynamic> llegirDada(String clau) async {
    // Directament llegim el snapshot sense clonar tot el mapa, estalviant memòria en la lectura
    final snapshot = await llegirPerId(_INFO_APP, 0);
    return snapshot?[clau];
  }

  /// Escriu de forma asíncrona un valor dinàmic associat a una clau de control.
  Future<void> escriureDada(String clau, dynamic valor) async {
    // Carreguem l'estat actual assegurant que és mutable
    final mapaConfiguracioActual = await _obtenirMapaUnificat();

    // Injectem o actualitzem la clau
    mapaConfiguracioActual[clau] = valor;

    // Escrivim al disc (ID del Registre fix: 0)
    await guardarPerId(_INFO_APP, 0, mapaConfiguracioActual);
  }

  /// Mètode intern per extreure de forma segura i mutable el mapa de configuració
  Future<Map<String, dynamic>> _obtenirMapaUnificat() async {
    final snapshot = await llegirPerId(_INFO_APP, 0);
    if (snapshot != null) {
      return Map<String, dynamic>.from(snapshot); // Evita errors de mapes immutables
    }
    return <String, dynamic>{}; // Instància nova i buida si no existeix
  }


}
