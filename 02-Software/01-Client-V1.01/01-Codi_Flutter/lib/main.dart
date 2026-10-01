
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:DynoForm/Questionari/PantallaMestreIncident.dart';
import 'package:DynoForm/Emmagatzematge/BD/BDServiceQuestionari.dart';
import 'package:DynoForm/Emmagatzematge/BD/BDServiceIncidents.dart';
import 'package:DynoForm/Emmagatzematge/BD/BDServiceApp.dart';
import 'package:DynoForm/Xarxa/ClientApiServidor.dart';


import 'dart:convert';
import 'package:file_picker/file_picker.dart';

Future<void> main() async {

  // 1. OBLIGATORI: Garanteix que els canals natius de Flutter estan actius abans d'executar codi asíncron
  WidgetsFlutterBinding.ensureInitialized();

  print("🔐 MODE TEST: Inicialitzant instàncies xifrades de la Base de Dades...");

  // Contrasenya temporal de proves (hardcoded) per simular la sessió
  const String contrasenyaProves = "contra_proves";

  // 2. Obrim i configurem de forma seqüencial els 3 Singletons del sistema
  bool okQuestionari = await BDServiceQuestionari.init(contrasenyaProves);
  bool okIncidents = await BDServiceIncidents.init(contrasenyaProves);
  bool okApp = await BDServiceApp.init(contrasenyaProves);
  bool okAutentificacio = await ClientApiServidor.init(contrasenyaProves,defaultTargetPlatform.name.toUpperCase()+"_Client");

  // LOGS DE CONTROL DE SEGURETAT A LA TERMINAL
  print("📊 ESTAT DELS SERVEIS:");
  print("   - Mòdul Qüestionari (Sembast): ${okQuestionari ? '🟢 ACTIU (Llest)' : '🔴 ERROR'}");
  print("   - Mòdul Incidents (Sembast):   ${okIncidents ? '🟢 ACTIU (Llest)' : '🔴 ERROR'}");
  print("   - Mòdul Aplicació (Sembast):   ${okApp ? '🟢 ACTIU (Llest)' : '🔴 ERROR'}");
  print("   - Mòdul Cient (Conexio amb el Servidor):   ${okAutentificacio ? '🟢 ACTIU (Llest)' : '🔴 ERROR'}");


  // 4.Llançem la interfície gràfica només quan els magatzems estan preparats
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DynoForm - Segregació de dades',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
      ),
      home: const PantallaImportacioJson(),//PantallaMestreIncident(),
    );
  }



}

class PantallaImportacioJson extends StatefulWidget {
  const PantallaImportacioJson({super.key});

  @override
  State<PantallaImportacioJson> createState() => _PantallaImportacioJsonState();
}

class _PantallaImportacioJsonState extends State<PantallaImportacioJson> {
  String? _missatgeError;
  bool _processant = false;
  String? _nomFitxerSeleccionat;

  // CORREGIT: Ara el paràmetre s'anomena 'textBrut' tot junt, sense espais rebels
  String _netejarJsonTolerant(String textBrut) {
    String textNet = textBrut.trim();

    // 1. Elimina el marcador de posició de bytes (BOM) invisible si s'ha colat
    if (textNet.startsWith('\uFEFF')) {
      textNet = textNet.substring(1);
    }

    // 2. Elimina les comes sobrants (trailing commas) d'objectes o llistes abans de tancar-se
    final regexComesSobrants = RegExp(r',(?=\s*[}\]])');
    textNet = textNet.replaceAll(regexComesSobrants, '');

    return textNet.trim();
  }

  void _seleccionarIProcessarFitxer() async {
    setState(() {
      _missatgeError = null;
      _processant = true;
      _nomFitxerSeleccionat = null;
    });

    try {
      // Obre el diàleg natiu de fitxers (Android/Windows/Linux/Web)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _processant = false;
        });
        return;
      }

      final fitxer = result.files.first;

      setState(() {
        _nomFitxerSeleccionat = fitxer.name;
      });

      final bytes = fitxer.bytes;
      if (bytes == null) {
        throw const FormatException("No s'han pogut llegir els bytes del fitxer seleccionat.");
      }

      final textOriginal = utf8.decode(bytes);

      // Netegem el JSON per eliminar les comes conflictives
      final textCorregit = _netejarJsonTolerant(textOriginal);

      // Descodifiquem el text ja polit
      final Map<String, dynamic> jsonMapejat = jsonDecode(textCorregit);

      // Comprovacions de seguretat indispensables per a la base del qüestionari
      if (!jsonMapejat.containsKey('versio')) {
        throw const FormatException("Falta la clau obligatòria a l'arrel: 'versio'");
      }
      if (!jsonMapejat.containsKey('preguntesBlocks')) {
        throw const FormatException("Falta la clau obligatòria a l'arrel: 'preguntesBlocks'");
      }
      if (!jsonMapejat.containsKey('fillsBlocks')) {
        throw const FormatException("Falta la clau obligatòria a l'arrel: 'fillsBlocks'");
      }

      // Guardem a Sembast
      await BDServiceQuestionari().guardarArbreBlocs(0, jsonMapejat);

      print("📦 [BD Sembast]: S'ha importat correctament la configuració del fitxer $_nomFitxerSeleccionat (Versió: ${jsonMapejat['versio']})");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaMestreIncident()),
        );
      }
    } on FormatException catch (e) {
      setState(() {
        _missatgeError = "❌ El JSON té un error de format o sintaxi insalvable:\n${e.message}";
        _processant = false;
      });
    } catch (e) {
      setState(() {
        _missatgeError = "❌ Error inesperat obrint el fitxer: $e";
        _processant = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("INICIALITZADOR MATRIU D'INCIDENTS"),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.folder_open_rounded, size: 40, color: Colors.red.shade800),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Càrrega des de Fitxer Estructural",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Selecciona el fitxer .json de configuració estructural. El sistema arreglarà automàticament problemes menors com comes de més.",
                              style: TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: InkWell(
                  onTap: _processant ? null : _seleccionarIProcessarFitxer,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _processant ? Colors.grey : Colors.red.shade800.withAlpha(100),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_processant) ...[
                            CircularProgressIndicator(color: Colors.red.shade900),
                            const SizedBox(height: 16),
                            const Text(
                              "Processant i corregint format...",
                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),
                            ),
                          ] else ...[
                            Icon(Icons.upload_file_rounded, size: 64, color: Colors.red.shade800),
                            const SizedBox(height: 16),
                            Text(
                              _nomFitxerSeleccionat ?? "Prem aquí per buscar el fitxer JSON",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: _nomFitxerSeleccionat != null ? FontWeight.bold : FontWeight.normal,
                                  color: _nomFitxerSeleccionat != null ? Colors.black87 : Colors.black45
                              ),
                            ),
                            if (_nomFitxerSeleccionat == null) ...[
                              const SizedBox(height: 8),
                              const Text(
                                "Format corregit automàticament si hi ha comes extres",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ]
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_missatgeError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _missatgeError!,
                    style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
