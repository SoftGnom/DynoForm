import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:DynoForm/Emmagatzematge/BD/BDServiceIncidents.dart';
import 'package:DynoForm/Xarxa/ClientApiServidor.dart';
import 'package:canonical_json/canonical_json.dart';


class GestorSincronitzacioServidor {


  /// Genera el Hash SHA-256 seguint l'estàndard internacional Canonical JSON
  String _generarHashCompatiblePython(Map<String, dynamic> dades) {
    // 1. canonicalJson.encode() ja retorna un List<int> (bytes UTF-8) directament!
    final List<int> bytesCanonics = canonicalJson.encode(dades);

    // 2. Passem els bytes directament a l'algorisme SHA-256 de la llibreria crypto
    final Digest hashResultat = sha256.convert(bytesCanonics);

    // 3. El convertim a String hexadecimal per poder-lo enviar al servidor
    return hashResultat.toString();
  }

  /// Funció que es llança quan el usauri prem el botó "Sincronitzar amb Central"
  Future<bool> executarFluxSincronitzacio({
    required int idIncident,
  }) async {

    print("⚙️ [GestorSincronitzacio]: Processant dades per enviar a FastAPI...");

    // 1. Convertim les llistes de nodes de Dart a Mapes JSON nets (com demana el servidor)
    final Map<String, dynamic> mapaPrivat =
        await BDServiceIncidents().getPrivatIncident(idIncident) ?? {};

    final Map<String, dynamic> mapaPublic =
        await BDServiceIncidents().getPublicIncident(idIncident) ?? {};

    // 2. Generem els hashes de forma IDÈNTICA a Python (sort_keys=True)
    String hashPrivat = _generarHashCompatiblePython(mapaPrivat);
    String hashPublic = _generarHashCompatiblePython(mapaPublic);

    // 3. OBTENIM EL MOMENT ACTUAL EN FORMAT ISO 8601 (Ex: 2026-06-09T14:30:00Z)
    final String araISO = DateTime.now().toUtc().toIso8601String();

    bool exitSincro = false;

    // 4. CRIDEM LA TEVA FUNCIO MODIFICADA (L'ID de la tauleta s'injecta sol a dins!)
    exitSincro = await ClientApiServidor().sincronitzarIncident(
      idIncident: idIncident.toString()+"-"+DateTime.now().toIso8601String(),
      contingutPrivat: mapaPrivat,
      contingutPublic: mapaPublic,
      dateTime: araISO,
      hashPrivat: hashPrivat,
      hashPublic:hashPublic,
    );

    if (exitSincro) {
      print("✅ [GestorSincronitzacio]: Incident $idIncident enviat i verificat pel servidor.");
    } else {
      print("❌ [GestorSincronitzacio]: Error en la sincronització. El paquet ha estat rebutjat.");
    }
    return exitSincro;
  }

}
