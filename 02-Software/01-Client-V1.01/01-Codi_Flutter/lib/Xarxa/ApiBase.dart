import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:DynoForm/Emmagatzematge/BD/BDServiceApp.dart';

// 🌟 AQUÍ ESTÀ LA MÀGIA: Importem el stub per defecte, però si Dart detecta que estem compilant
// per a la web o per a io, canvia el fitxer de configuració de manera transparent.
import 'package:DynoForm/Xarxa/configurador/configurador_xarxa_stub.dart'
  if (dart.library.js_interop) 'package:DynoForm/Xarxa/configurador/configurador_xarxa_web.dart'
  if (dart.library.io) 'package:DynoForm/Xarxa/configurador/configurador_xarxa_mobi.dart';

abstract class ApiBase {
  late final Dio _dio;

  // URL base apuntant al teu Nginx
  final String _baseUrl = "https://localhost:8443";

  ApiBase() {

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // ✨ CONFIGURACIÓ NETEJA: Cridem la funció externa autoconfigurada!
    // Ella sabrà si posar el BrowserHttpClientAdapter o el de mòbil amb badCertificateCallback
    configurarAdaptadorDio(_dio);
  }

  /// Mètode HTTP genèric per enviar dades (POST)
  @protected
  Future<Response> postProcess(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      _gestionarErrorXarxa(e);
      rethrow;
    }
  }

  /// Mètode HTTP genèric per obtenir dades (GET)
  @protected
  Future<Response> getProcess(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(path, queryParameters: queryParams);
    } on DioException catch (e) {
      _gestionarErrorXarxa(e);
      rethrow;
    }
  }

  @protected
  void _gestionarErrorXarxa(DioException e) {
    if (e.response != null) {
      print("❌ [ApiBase] Error del servidor: ${e.response?.statusCode} - ${e.response?.data}");
    } else {
      print("❌ [ApiBase] Error de xarxa/timeout: ${e.message}");
    }
  }

  // =========================================================================
  // GESTIÓ D'IDENTITAT CREADA PEL PARE ABSTRACTE
  // =========================================================================

  String? _idTauleta;
  bool _isidTauleta = false; // Inicialitzada per defecte en fals per evitar errors de tipus Late

  bool get isidTauleta => _isidTauleta;

  @protected
  String? getIdTauleta(){
    return _idTauleta;
  }

  late final String _contrasenyaSeguretat;
  late final String _modelDispositiu;

  @protected
  void initContrasenya(String contrasenyaSeguretat, String modelDispositiu) {
    _contrasenyaSeguretat = contrasenyaSeguretat;
    _modelDispositiu = modelDispositiu;
  }

  /// 1. Declaració / Validació inicial de la tauleta
  @protected
  Future<String?> declararTauleta(String model, String contrasenya) async {
    try {
      final resposta = await postProcess(
        "/tauleta/declarar",
        data: {
          "contrasenya": contrasenya,
          "model_dispositiu": model,
        },
      );

      if (resposta.statusCode == 200 && resposta.data['ack'] == true) {
        // Retorna l'UUID generat pel servidor
        return resposta.data['id_tauleta'];
      }
      return null;
    } catch (e) {
      print("Error declarant tauleta: $e");
      return null;
    }
  }

  /// MOTOR DE VERIFICACIÓ D'IDENTITAT SOTA DEMANDA
  /// Intermeia amb Sembast permanent i amb la xarxa en cas de buidat de dades.
  @protected
  Future<void> assegurarIdentitat() async {
    // 1. Dreta de pas ràpida: Si ja existeix en RAM, retornem sense fer accessos
    if (_idTauleta != null && _idTauleta!.isNotEmpty) {
      _isidTauleta = true;
      return;
    }

    try {
      // 2. Llegim utilitzant la instància unificada compartida de Sembast per a l'App
      final idPersistit = await BDServiceApp().llegirDada("id_tauleta");

      if (idPersistit != null && idPersistit is String && idPersistit.isNotEmpty) {
        _idTauleta = idPersistit;
        print("🔑 [ApiBase]: Identitat recuperada amb èxit de Sembast: $_idTauleta");
        _isidTauleta = true;
        return;
      }

      // 3. Cas de primera arrencada de la història de l'app: Es requereix registre a FastAPI
      print("⚠️ [ApiBase]: Dispositiu no trobat a la DB local. Connectant amb el servidor central...");


      String? nouIdGenerat = await declararTauleta(_modelDispositiu, _contrasenyaSeguretat);

      if (nouIdGenerat != null && nouIdGenerat.isNotEmpty) {
        _idTauleta = nouIdGenerat;

        // Persistim a Sembast per a futurs reinicis de l'aplicació informàtica
        await BDServiceApp().escriureDada("id_tauleta", nouIdGenerat);
        print("✅ [ApiBase]: Auto-declaració completada i guardada a disc. UUID: $_idTauleta");
        _isidTauleta = true;
        return;
      }
    } catch (e) {
      print("❌ [ApiBase]: Error crític controlant el flux de seguretat d'identitat: $e");
    }

    // Si arriba aquí, vol dir que no s'ha pogut obtenir l'UUID (bloqueig operatiu)
    _isidTauleta = false;
  }
}
