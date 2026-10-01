
import 'package:flutter/material.dart';
import 'package:DynoForm/Questionari/Controlers/QuestionariControlador.dart';
import 'package:DynoForm/Questionari/Blocks/BlocUniversalWidget.dart';
import 'package:DynoForm/Questionari/Menu/ElTeuMenuLateralWidget.dart';
import 'package:DynoForm/Xarxa/GestorSincronitzacioServidor.dart';

// La vista principal contenidora de la tauleta
class PantallaMestreIncident extends StatefulWidget {
  const PantallaMestreIncident({super.key});

  @override
  State<PantallaMestreIncident> createState() => _PantallaMestreIncidentState();
}


class _PantallaMestreIncidentState extends State<PantallaMestreIncident> {
  late QuestionariControlador _questionariControlador;

  // Instanciem el gestor estructural de sincronització (Class 1)
  final GestorSincronitzacioServidor _gestorSincronitzacio = GestorSincronitzacioServidor();
  // Controla si el menú lateral està visible o amagat
  bool _menuObert = true;

  // Definim la ID de l'incident actiu (en una app real la rebràs per paràmetre del constructor)
  final int _idIncidentActiu = 0;//TODO: cambiar per un ID dinamic

  @override
  void initState() {
    super.initState();
    _questionariControlador = QuestionariControlador();

    // Executem de forma asíncrona la càrrega des del disc un cop instanciada la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _questionariControlador.inicialitzarFluxIncident(_idIncidentActiu); // ID Incident operatiu real
    });
  }


  /// FUNCIÓ CRÍTICA: Executa el flux seqüencial de guardat local + enviament remot
  Future<void> _processarSincronitzacioInterficie(BuildContext context) async {
    // 1. Mostrem un diàleg modal de càrrega transparent per bloquejar la UI i evitar dobles clics
    showDialog(
      context: context,
      barrierDismissible: false, // El usuari no el pot tancar tocant a fora
      builder: (BuildContext context) {
        return const PopScope(
          canPop: false, // Bloqueja el botó físic "Enrere" d'Android durant la càrrega
          child: AlertDialog(
            backgroundColor: Colors.white,
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.red),
                SizedBox(width: 24),
                Expanded(
                  child: Text(
                    "Connectant amb la Central Operativa...",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      print("📡 [UI Sincro]: Iniciant el motor de reintents amb dades consolidades en disc...");

      int iEnviar = 2;
      bool estat = false;

      while(iEnviar > 0 && estat == false){
        // Finestra de cortesia (400ms): Estabilitza la UI i serveix de debounce per a l'últim input de RAM a disc
        await Future.delayed(const Duration(milliseconds: 400));

        // Invoquem el Gestor passant la ID de l'incident per processar el Canonical JSON xifrat
        estat = await _gestorSincronitzacio.executarFluxSincronitzacio(
          idIncident: _idIncidentActiu,
        );
        iEnviar-=1;
      }
      // 2. Tanquem el diàleg de càrrega de forma segura extreient-lo de la pila de pantalles
      if (mounted) Navigator.pop(context);

      // 3. Preparem dinàmicament el text i el color del contingut de notificació
      final String misatge = estat
          ? "Sincronització completada amb èxit a la Central."
          : "No s'ha pogut sincronitzar amb la Central després de 3 intents.";

      final Color colorFonsSnackBar = estat ? Colors.green : Colors.red.shade800;
      final IconData iconaNotificacio = estat ? Icons.check_circle : Icons.error_outline;

      // 4. Mostrem notificació contextualitzada a la part inferior de la tauleta
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(iconaNotificacio, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(misatge, style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
            ),
            backgroundColor: colorFonsSnackBar,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
    catch (errorExcepcio, tracaPila) {
      // 1. Imprimim per la consola de debug de Flutter la traça exacta (Fitxer + Línia de codi)
      print("❌ [UI Sincro] Error crític durant el flux de transmissió: $errorExcepcio");
      print("🔍 [UI Sincro] DETALL DE LA LÍNIA QUE FA LLANÇAR L'ERROR:\n$tracaPila");

      if (mounted) Navigator.pop(context); // Tanquem el modal d'espera de forma segura

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("Error de test: ${errorExcepcio.toString().split('\n').first}")),//"Error inesperat del sistema: Excepció en xarxa o dades. Sincronització avortada.")),
              ],
            ),
            backgroundColor: Colors.amber.shade900,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _questionariControlador,
      builder: (context, child) {

        // PANTALLA DE CÀRREGA: Si el controlador està descarregant de Sembast (ID 0 o ID 204)
        if (_questionariControlador.enCarrega || _questionariControlador.llistaPlanaBlocs.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 16),
                  Text("Desxifrant i acoblant dades de l'incident...", style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        }

        // Recuperem el focus actiu de la llista unificada de memòria RAM
        final nodeActiu = _questionariControlador.llistaPlanaBlocs.firstWhere(
              (node) => node.id == _questionariControlador.idBlocSeleccionat,
          orElse: () => _questionariControlador.llistaPlanaBlocs.first,
        );

        // Extraiem la configuració des del magatzem intern que el controlador s'ha encarregat de baixar
        final llistaPreguntes = _questionariControlador.plantillesPreguntes[nodeActiu.tipusPlantilla] ?? [];
        final metadades = _questionariControlador.metadadesCreacio[nodeActiu.tipusPlantilla];

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(_menuObert ? Icons.menu_open : Icons.menu),
              tooltip: _menuObert ? "Amagar índex" : "Mostrar índex",
              onPressed: () => setState(() => _menuObert = !_menuObert),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16), // Espaiat net entre el botó i el text del títol
                const Expanded(
                  child: Text(
                    "INFORME D'ACTUACIÓ OPERATIVA - SEGREGACIÓ COMPLETA",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text("Sincronitzar", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await _processarSincronitzacioInterficie(context);
                  },
                ),
              ],
            ),
            backgroundColor: Colors.red.shade900,
            foregroundColor: Colors.white,
          ),
          body: Row(
            children: [
              if (_menuObert)
                Container(
                  width: 290,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: ElTeuMenuLateralWidget(controlador: _questionariControlador),
                ),
              Expanded(
                child: Container(
                  color: Colors.grey.shade100,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: BlocUniversalWidget(
                      nodeBloc: nodeActiu,
                      controlador: _questionariControlador,
                      plantillesPreguntes: llistaPreguntes,
                      metadadesCreacio: metadades,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



