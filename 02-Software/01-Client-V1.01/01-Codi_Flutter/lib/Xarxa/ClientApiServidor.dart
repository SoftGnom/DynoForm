import 'package:dio/dio.dart';
import 'package:DynoForm/Xarxa/ApiBase.dart';

class ClientApiServidor extends ApiBase {

  // --- ESTRUCTURA SINGLETON ---


  static ClientApiServidor? _instance;

  factory ClientApiServidor() {
    if (_instance == null) {
      throw Exception("Error: No pots fer servir la Conexio perquè no s'ha iniciat sessió correctament.");
    }
    return _instance!;
  }

  // Constructor intern privat que delega l'aixecament de Dio al pare abstracte
  ClientApiServidor._internal() : super();


  Future<bool> _comprovarAutentificacio() async {
    if (!isidTauleta) {
      await assegurarIdentitat();
      if (!isidTauleta){
        return false;
      }
      return true;
    }
    return true;
  }

  /// INICIALITZADOR ASÍNCRON GLOBAL DE XARXA
  /// Crida'l des del teu `main.dart` o en fer Login un cop obert el Sembast de l'App
  static Future<bool> init(String contrasenya, String modelDispositiu) async {
    final prova = ClientApiServidor._internal();

    // Configurem el paràmetre heretat del pare
    prova.initContrasenya(contrasenya, modelDispositiu);

    // Forcem a que vagi a buscar el seu identificador permanent immediatament a l'iniciar
    bool state = await prova._comprovarAutentificacio();

    // CRÍTIC: Assignem la instància configurada al Singleton global
    _instance = prova;
    print("📡 [ClientApiServidor]: Mòdul de connexió instanciat i llest per operar.");

    return state;
  }

  /// MÈTODE DE TANCAMENT SIMÈTRIC (Logout / Bloqueig de seguretat)
  static Future<void> close() async {
    if (_instance != null) {
      // Destruïm l'objecte de la memòria RAM per forçar un proper pas per l'init()
      _instance = null;
      print("🚫 [ClientApiServidor]: Connexió tancada i instància del Singleton desallotjada de la RAM.");
    }
  }

  // --- ENDPOINTS ESPECÍFICS ---


  /// 2. Enviament de dades d'incident sincronitzades
  Future<bool> sincronitzarIncident({
    required String idIncident,
    required Map<String, dynamic> contingutPrivat,
    required Map<String, dynamic> contingutPublic,
    required String dateTime,
    required String hashPrivat,
    required String hashPublic,
  }) async {

    // -- Introducio --

    // Si l'usuari prem el botó, l'interceptem per demanar / comprovar la identitat al moment
    bool autentificat = await _comprovarAutentificacio();

    if (!autentificat) {
      print("🚫 [ClientApiServidor]: S'ha denegat l'enviament de dades. Dispositiu No Declarat i sense xarxa per registrar-se.");
      return false; // Bloquegem l'enviament evitant el POST
    }

    // -- Cos --

    try {

      Map<String, dynamic> incidentDades = {
        "ids": {
          "tablet": getIdTauleta(),
          // Es llegirà de la RAM de l'API o l'API el sobrescriurà automàticament
          "incident": idIncident
        },
        "contingut_dinamic_privat": contingutPrivat,
        "contingut_dinamic_public": contingutPublic,
        "datetime": dateTime,
      };

      final Map<String, String> hashes = {
        "privat": hashPrivat,
        "public": hashPublic,
      };

      final resposta = await postProcess(
        "/incident/sincro/data",
        data: {
          "incident_in": incidentDades,
          "hash_data": hashes,
        },
      );

      // -- Final --

      return resposta.statusCode == 200 && resposta.data['ack'] == true;
    } catch (e) {
      print("Error executant la petició POST de sincronització: $e");
      return false;
    }
  }
}


