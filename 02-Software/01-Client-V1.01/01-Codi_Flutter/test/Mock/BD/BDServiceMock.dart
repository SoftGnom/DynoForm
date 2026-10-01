import 'package:sembast/sembast.dart';
import 'package:DynoForm/Emmagatzematge/BD/BDService.dart';

/// Una subclasse específica de test que estén [BDService].
/// La seva única finalitat és actuar com a passarel·la pública per poder
/// validar els mètodes `@protected` del pare en l'entorn de 'flutter test'.
class BDServiceMock extends BDService {

  /// Constructor públic simple. A diferència dels fills reals de producció,
  /// no implementa un patró Singleton rígid per permetre instanciar
  /// bases de dades completament noves i aïllades en cada cas de test.
  BDServiceMock();

  /// Exposa públicament el mètode d'obertura de la base de dades del pare
  /// i aprofita per inicialitzar unes col·leccions de prova controlades.
  Future<bool> inicialitzarPerAProves(String contrasenya, String idBD) async {
    final exit = await obrirBaseDeDades(contrasenya, idBD);
    if (exit) {
      // Inicialitzem dues col·leccions fictícies per provar la lògica multi-store
      initColeccions('store_test_privat'); // Assignat automàticament a la ID 0
      initColeccions('store_test_public');  // Assignat automàticament a la ID 1
    }
    return exit;
  }

  /// Wrapper públic per al mètode protegit [guardar]
  Future<int> executarGuardar(int idColeccio, Map<String, dynamic> dades) async {
    return await guardar(idColeccio, dades);
  }

  /// Wrapper públic per al mètode protegit [llegirTot]
  Future<List<RecordSnapshot<int, Map<String, Object?>>>> executarLlegirTot(int idColeccio) async {
    return await llegirTot(idColeccio);
  }

  /// Wrapper públic per al mètode protegit [comptar]
  Future<int> executarComptar(int idColeccio, {Filter? filtre}) async {
    return await comptar(idColeccio, filtre: filtre);
  }

  /// Wrapper públic per al mètode protegit [buscar]
  Future<List<RecordSnapshot<int, Map<String, Object?>>>> executarBuscar(int idColeccio, Finder filtre) async {
    return await buscar(idColeccio, filtre);
  }

  /// Wrapper públic per al mètode protegit [actualitzar]
  Future<Map<String, Object?>?> executarActualitzar(int idColeccio, int idIncident, Map<String, Object?> actualitzacio) async {
    return await actualitzar(idColeccio, idIncident, actualitzacio);
  }

  /// Wrapper públic per al mètode protegit [esborrar]
  Future<dynamic> executarEsborrar(int idColeccio, int idRegistre) async {
    return await esborrar(idColeccio, idRegistre);
  }

  /// Wrapper públic per al mètode protegit [tancarBaseDeDades]
  Future<void> executarTancar() async {
    await tancarBaseDeDades();
  }
}
