// ==========================================
//   CLASSE PARE / PLANTILLA ABSTRACTA
// ==========================================


import 'package:meta/meta.dart';
import 'dart:convert';
import 'dart:typed_data'; // Afegeix aquesta línia per gestionar Uint8List
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast_memory.dart';


/// Classes auxiliars privades per evitar instanciar la classe abstracta Codec de Dart
class _ElNostreCodecAES extends Codec<Map<String, Object?>, String> {
  @override
  final _EncoderEncoder encoder;
  @override
  final _DecoderDecoder decoder;

  _ElNostreCodecAES(encrypt.Encrypter encrypter)
      : encoder = _EncoderEncoder(encrypter),
        decoder = _DecoderDecoder(encrypter);
}

class _EncoderEncoder extends Converter<Map<String, Object?>, String> {
  final encrypt.Encrypter encrypter;
  _EncoderEncoder(this.encrypter);

  @override
  String convert(Map<String, Object?> input) {
    final jsonText = jsonEncode(input);

    // Generem un IV únic i aleatori per a AQUEST registre concret
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = encrypter.encrypt(jsonText, iv: iv);

    // Unim els 16 bytes de l'IV + els bytes del text xifrat
    final combinedBytes = Uint8List(16 + encrypted.bytes.length);
    combinedBytes.setRange(0, 16, iv.bytes);
    combinedBytes.setRange(16, combinedBytes.length, encrypted.bytes);

    // Retornem en Base64 per a que Sembast ho guardi com a String
    return base64.encode(combinedBytes);
  }
}

class _DecoderDecoder extends Converter<String, Map<String, Object?>> {
  final encrypt.Encrypter encrypter;

  _DecoderDecoder(this.encrypter);

  @override
  Map<String, Object?> convert(String input) {
    final combinedBytes = base64.decode(input);

    // Separem els primers 16 bytes (IV) de la resta (dada xifrada)
    final ivBytes = combinedBytes.sublist(0, 16);
    final encryptedBytes = combinedBytes.sublist(16);

    final iv = encrypt.IV(ivBytes);
    final encrypted = encrypt.Encrypted(encryptedBytes);

    final textDesxifrat = encrypter.decrypt(encrypted, iv: iv);
    return (jsonDecode(textDesxifrat) as Map).cast<String, Object?>();
  }
}

abstract class BDService {

  // --- ESTRUCTURA DEL PATRÓ SINGLETON NADIU EN DART ---

  //Variavles
  bool _estaConnectat = false;
  Database? _base_de_dades;
  @protected
  late final List<StoreRef<int, Map<String, Object?>>> coleccions = [];

  // G/Setters
  // Mètode per comprovar si el fill està llest
  bool get estaLlest => _estaConnectat;
  Database? get _db => _base_de_dades;


  @protected
  SembastCodec _crearCodecAES256(String contrasenyaUsu) {
    // Derivació de la clau de 32 bytes mitjançant SHA-256 (Obligatori per a AES-256)
    final passwordBytes = utf8.encode(contrasenyaUsu);
    final sha256Digest = sha256.convert(passwordBytes);
    final clauCriptografica = encrypt.Key(Uint8List.fromList(sha256Digest.bytes));

    // El mode CBC és correcte, l'IV dinàmic ara es gestiona a l'Encoder
    final encrypter = encrypt.Encrypter(encrypt.AES(clauCriptografica, mode: encrypt.AESMode.cbc));

    // Retornem el SembastCodec associant el nostre convertidor concret
    return SembastCodec(
      signature: 'aes-256-dinamic-iv',
      codec: _ElNostreCodecAES(encrypter),
    );
  }

  /// Obre la base de dades detectant dinàmicament si estem al Firefox (Web) o en Natriu
  @protected
  Future<bool> obrirBaseDeDades(String contrasenyaUsu, String idBD) async {
    try {
      // 1. DETECTOR DE PLATAFORMA (WEB / FIREFOX)
      if (kIsWeb) {
        try {
          // Intentem aixecar el sistema complet xifrat en RAM
          final filtreXifratge = _crearCodecAES256(contrasenyaUsu);
          _base_de_dades = await databaseFactoryMemory.openDatabase(
            idBD,
            codec: filtreXifratge,
          );
          print("🌐 [SISTEMA WEB]: Sembast actiu en RAM (XIFRAT AES-256) per a: '$idBD'.");
        } catch (errorCodec) {
          // FALLBACK D'EMERGÈNCIA: Si el xifratge es baralla amb la RAM del Firefox,
          // obrim una BD en RAM neta sense xifrar per permetre el testing de les pantalles.
          _base_de_dades = await databaseFactoryMemory.openDatabase(idBD);
          print("⚠️ [SISTEMA WEB]: Còdec incompatible amb la RAM. S'ha activat la BD en RAM NETA per a proves.");
        }
      } else {
        // 2. MODE DISPOSITIU REAL / EMULADOR (NATIU)
        final filtreXifratge = _crearCodecAES256(contrasenyaUsu);
        final directori = await getApplicationDocumentsDirectory();
        final rutaFitxer = join(directori.path, '$idBD.db');

        _base_de_dades = await databaseFactoryIo.openDatabase(
          rutaFitxer,
          codec: filtreXifratge,
        );
        print("📱 [SISTEMA NATIU]: Fitxer .db creat i xifrat correctament per a: '$idBD'.");
      }

      _estaConnectat = true;
      return true;
    } catch (e) {
      print("❌ Error crític fatal obrint la base de dades ($idBD): $e");
      _estaConnectat = false;
      return false;
    }
  }



  /// 4. Tanca la connexió física i revoca les claus de la memòria RAM (Requisit R-1.4.A.3)
  /// Imprescindible en fer Logout o en bloquejos de seguretat.
  @protected
  Future<void> tancarBaseDeDades() async {
    if (_base_de_dades != null) {
      await _base_de_dades!.close(); // Tanquem el fitxer de Sembast
      _base_de_dades = null;         // Alliberem l'objecte de la connexió
      _estaConnectat = false;

      // Buidem el Vector complet de la memòria perquè ningú pugui fer
      // un coleccions[x] mentre la sessió estigui tancada.
      coleccions.clear();

      print("Seguretat: Base de dades tancada i claus revocades de la RAM."); // TODO: Canviar a Log immutable
    }
  }




  // ----------------------------------------------------

  // --- ESTRUCTURA DE LA CLASE ---

  @protected
  void initColeccions(String nomColeccio) {
  // Creem la col·lecció física de Sembast al vol a partir del String aportat
  final novaColeccio = intMapStoreFactory.store(nomColeccio);
  // La fiquem a l'última posició disponible del Vector (Això garanteix l'ordre d'entrada)
  coleccions.add(novaColeccio);
  }

  /// Guarda un registre JSON de forma asíncrona en una col·lecció concreta (Retorna la ID)
  @protected
  Future<int> guardar(int idColeccio, Map<String, dynamic> dades) async {
    if (_db == null) throw Exception("BD no inicialitzada");

    return await coleccions[idColeccio].add(_db!, dades);
  }

  /// Retorna tots els "Snapshots" (ID + JSON desxifrat) d'una col·lecció completa
  @protected
  Future<List<RecordSnapshot<int, Map<String, Object?>>>> llegirTot(int idColeccio) async {
    if (_db == null) throw Exception("BD no inicialitzada");

    return await coleccions[idColeccio].find(_db!);
  }

  /// Cerca registres específics aplicant un filtre complex (Finder)
  @protected
  Future<List<RecordSnapshot<int, Map<String, Object?>>>> buscar(int idColeccio, Finder filtre) async {
    if (_db == null) throw Exception("BD no inicialitzada");

    return await coleccions[idColeccio].find(_db!, finder: filtre);
  }

  /// Actualitza parcialment camps d'un JSON existent per la seva ID numèrica
  @protected
  Future<Map<String, Object?>?> actualitzar(int idColeccio, int idIncident, Map<String, Object?> actualitzacio) async {
  if (_db == null) throw Exception("BD no inicialitzada");

  // Modifica només els camps enviats a l'objecte concret afectat
  return await coleccions[idColeccio].record(idIncident).update(_db!, actualitzacio);
  }


  //---


  /// 1. Elimina un registre específic d'una col·lecció per la seva ID numèrica
  /// Retorna la ID del registre eliminat (o null si no existia)
  @protected
  Future<dynamic> esborrar(int idColeccio, int idRegistre) async {
    if (_db == null) throw Exception("BD no inicialitzada");

    // Accés directe O(1) al registre concret per eliminar-lo del disc
    return await coleccions[idColeccio].record(idRegistre).delete(_db!);
  }

  /// 2. Compta quants registres hi ha en una col·lecció (opcionalment aplicant un filtre)
  /// Retorna un enter amb el total. Molt útil per a cues de sincronització offline.
  @protected
  Future<int> comptar(int idColeccio, {Filter? filtre}) async {
    if (_db == null) throw Exception("BD no inicialitzada");

    // Sembast compta directament a l'índex de memòria de forma ultra ràpida
    return await coleccions[idColeccio].count(_db!, filter: filtre);
  }

  /// 3. Elimina ABSOLUTAMENT TOTS els registres d'una col·lecció concreta
  /// Retorna el nombre total de registres eliminats.
  @protected
  Future<int> esborrarColleccioSencera(int idColeccio) async {
    if (_db == null) throw Exception("BD no inicialitzada");

    // Crida de neteja massiva sobre l'índex seleccionat
    return await coleccions[idColeccio].delete(_db!);
  }

  // AFEGEIX AIXÒ DINS DE LA CLASSE ABSTRACTA 'BDService'

  /// Guarda o sobrescriu (Upsert) un registre utilitzant una ID/Clau manual específica.
  /// Ideal per a estructures on la clau és la ID de l'incident.
  @protected
  Future<void> guardarPerId(int idColeccio, int idRegistre, Map<String, dynamic> dades) async {
    if (_db == null) throw Exception("BD no inicialitzada");

    // El mètode 'put' de Sembast insereix si no existeix, o sobreescriu si ja existeix.
    await coleccions[idColeccio].record(idRegistre).put(_db!, dades);
  }

  /// Retorna un sol registre complet desxifrat directament per la seva ID numèrica O(1)
  @protected
  Future<Map<String, Object?>?> llegirPerId(int idColeccio, int idRegistre) async {
    if (_db == null) throw Exception("BD no inicialitzada");

    // Accés directe instantani sense haver de recórrer tota la col·lecció
    return await coleccions[idColeccio].record(idRegistre).get(_db!);
  }

}

