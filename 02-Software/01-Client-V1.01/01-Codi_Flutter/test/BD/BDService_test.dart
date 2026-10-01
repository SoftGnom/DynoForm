import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io';
import 'package:sembast/sembast_io.dart';

// Imports de producció
import 'package:DynoForm/Emmagatzematge/BD/BDService.dart';
import 'package:DynoForm/Emmagatzematge/BD/BDServiceApp.dart';
import 'package:DynoForm/Emmagatzematge/BD/BDServiceIncidents.dart';
import '../Mock/BD/BDServiceMock.dart';


void main() {
  // Inicialització obligatòria de l'entorn de test de Flutter
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Simulem el canal natiu de path_provider per evitar l'error MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '.'; // Mapeja el directori d'execució actual per als fitxers .db de test
        }
        return null;
      },
    );
  });

  group('A) Tests de Seguretat i Criptografia (Còdec AES-256)', () {
    const contrasenyaCorrecta = "Usu1234!";
    final mapaOriginal = {"id_incident": "INC-001", "tipus": "Foc Forestal", "confidencial": "Dada sensible"};

    test('Hauria de derivar la clau correctament, xifrar i desxifrar amb IV dinàmic', () {
      final passwordBytes = utf8.encode(contrasenyaCorrecta);
      final sha256Digest = sha256.convert(passwordBytes);
      final clauCriptografica = encrypt.Key(Uint8List.fromList(sha256Digest.bytes));
      final encrypter = encrypt.Encrypter(encrypt.AES(clauCriptografica, mode: encrypt.AESMode.cbc));

      final jsonText = jsonEncode(mapaOriginal);
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypted = encrypter.encrypt(jsonText, iv: iv);

      final combinedBytes = Uint8List(16 + encrypted.bytes.length);
      combinedBytes.setRange(0, 16, iv.bytes);
      combinedBytes.setRange(16, combinedBytes.length, encrypted.bytes);
      final stringXifratBase64 = base64.encode(combinedBytes);

      expect(stringXifratBase64, isNot(contains("INC-001")));
      expect(stringXifratBase64, isNot(contains("Foc Forestal")));

      final combinedBytesDecode = base64.decode(stringXifratBase64);
      final ivBytes = combinedBytesDecode.sublist(0, 16);
      final encryptedBytes = combinedBytesDecode.sublist(16);

      final ivDec = encrypt.IV(ivBytes);
      final encryptedDec = encrypt.Encrypted(encryptedBytes);
      final textDesxifrat = encrypter.decrypt(encryptedDec, iv: ivDec);
      final mapaResultat = jsonDecode(textDesxifrat) as Map;

      expect(mapaResultat["id_incident"], equals("INC-001"));
    });
  });

  group('B) Tests de Cicle de Vida i Patró Singleton (BDServiceIncidents)', () {
    setUp(() async {
      try { await BDServiceIncidents.close(); } catch (_) {}
    });

    tearDown(() async {
      try { await BDServiceIncidents.close(); } catch (_) {}
    });

    test('Hauria de llançar una excepció si s’intenta accedir mitjançant el Factory sense fer init()', () {
      expect(
            () => BDServiceIncidents(),
        throwsA(isA<Exception>().having(
              (e) => e.toString(),
          'missatge',
          contains("No pots fer servir la BD perquè no s'ha iniciat sessió correctament"),
        )),
      );
    });

    test('Hauria d’inicialitzar el Singleton correctament en fer un init() vàlid', () async {
      final exit = await BDServiceIncidents.init("ContrasenyaSegura999");
      expect(exit, isTrue);

      final instancia = BDServiceIncidents();
      expect(instancia, isNotNull);
      expect(instancia.estaLlest, isTrue);
    });

    test('Hauria d’alliberar la RAM i revocar l’accés completament després de fer close()', () async {
      await BDServiceIncidents.init("ContrasenyaSegura999");
      final instancia = BDServiceIncidents();

      await BDServiceIncidents.close();

      expect(() => BDServiceIncidents(), throwsA(isA<Exception>()));
      expect(instancia.estaLlest, isFalse);
      expect(instancia.coleccions.isEmpty, isTrue);
    });
  });

  group('C) Tests d’Operacions CRUD de la Classe Pare a través de DBServiceMock', () {
    late BDServiceMock bdMock;
    const idStorePrivat = 0; // 'store_test_privat' inicialitzat al mock

    const nomFitxerBD = 'bd_test_pure_pare.db'; // El fitxer real que crea Sembast a l'arrel

    setUp(() async {
      // NETEJA CRÍTICA: Si el fitxer del test anterior existeix al disc, l'esborrem
      // d'aquesta manera garantim que cada test comenci amb la base de dades a zero.
      final fitxer = File(nomFitxerBD);
      if (await fitxer.exists()) {
        await fitxer.delete();
      }

      bdMock = BDServiceMock();
      // Obrim una base de dades completament neta
      await bdMock.inicialitzarPerAProves("ContrasenyaMock2026", "bd_test_pure_pare");
    });

    tearDown(() async {
      // Tanquem de forma neta per alliberar el fitxer
      await bdMock.executarTancar();

      // Opcional: també podem esborrar el fitxer en acabar l'últim test
      final fitxer = File(nomFitxerBD);
      if (await fitxer.exists()) {
        await fitxer.delete();
      }
    });

    test('Hauria de desar documents JSON i recuperar-los intactes garantint el flux del còdec', () async {
      final incidentFictici = {
        "codi": "GRAVE-99",
        "municipi": "Salt",
        "vehicles_mobilitzats": ["BUP-10", "UMV-02"],
        "timestamp_creacio": 1782364900
      };

      // 1. Validació de l'escriptura (CREATE)
      final idAssignada = await bdMock.executarGuardar(idStorePrivat, incidentFictici);
      expect(idAssignada, isA<int>());
      expect(idAssignada, greaterThan(0));

      // 2. Validació de la lectura massiva (READ)
      final totsElsRegistres = await bdMock.executarLlegirTot(idStorePrivat);
      expect(totsElsRegistres.length, equals(1));

      final dadesRecuperades = totsElsRegistres.first.value;
      expect(dadesRecuperades["codi"], equals("GRAVE-99"));
      expect(dadesRecuperades["municipi"], equals("Salt"));
      expect(dadesRecuperades["vehicles_mobilitzats"], isA<List>());
    });

    test('Hauria de respondre correctament a les consultes de recompte de registres', () async {
      // Inicialment la taula de dades ha d'estar a zero
      int totalInicial = await bdMock.executarComptar(idStorePrivat);
      expect(totalInicial, equals(0));

      // Injectem registres consecutius
      await bdMock.executarGuardar(idStorePrivat, {"pas": "alfa"});
      await bdMock.executarGuardar(idStorePrivat, {"pas": "beta"});
      await bdMock.executarGuardar(idStorePrivat, {"pas": "gamma"});

      // L'índex intern de Sembast en memòria ha de reflectir el total exacte
      int totalFinal = await bdMock.executarComptar(idStorePrivat);
      expect(totalFinal, equals(3));
    });

    test('Hauria d’actualitzar camps específics d’un document mitjançant la seva ID numèrica', () async {
      final original = {"estat": "En camí", "prioritat": "Alta"};
      final id = await bdMock.executarGuardar(idStorePrivat, original);

      // Apliquem una mutació parcial del document (UPDATE)
      final actualitzacio = {"estat": "Treballant a l'escena"};
      await bdMock.executarActualitzar(idStorePrivat, id, actualitzacio);

      // Verifiquem que el camp mutat s'ha canviat, però el col·lateral es manté intacte
      final llista = await bdMock.executarLlegirTot(idStorePrivat);
      expect(llista.first.value["estat"], equals("Treballant a l'escena"));
      expect(llista.first.value["prioritat"], equals("Alta"));
    });
  });




}
