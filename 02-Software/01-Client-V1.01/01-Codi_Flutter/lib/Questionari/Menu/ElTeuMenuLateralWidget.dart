import 'package:flutter/material.dart';
import 'package:DynoForm/Questionari/Controlers/QuestionariControlador.dart';
import 'package:DynoForm/Emmagatzematge/Estructures/InstanceNode.dart';

class ElTeuMenuLateralWidget extends StatelessWidget {
  final QuestionariControlador controlador;

  const ElTeuMenuLateralWidget({
    Key? key,
    required this.controlador,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            decoration: BoxDecoration(color: Colors.red.shade900),
            child: const Center(
              child: Text(
                "ESTRUCTURA OPERATIVA",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.8),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controlador.llistaPlanaBlocs.length,
              itemBuilder: (context, index) {
                final node = controlador.llistaPlanaBlocs[index];
                final bool esSeleccionat = node.id == controlador.idBlocSeleccionat;

                // Càlcul del sagnat d'ajust segons l'arbre real requerit
                double sagnatEsquerre = node.profunditat * 20.0;

                return InkWell(
                  onTap: () {
                    controlador.idBlocSeleccionat = node.id;
                    controlador.notifyListeners();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: esSeleccionat ? Colors.red.shade50 : Colors.transparent,
                      border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
                    ),
                    child: Row(
                      children: [
                        // 1. BOTÓ D'ESBORRAR (A l'esquerra del tot, absent només a l'ARREL)
                        if (node.id != "ARREL") ...[
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            tooltip: "Eliminar mòdul",
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _mostrarConfirmacioEsborrat(context, node);
                            },
                          ),
                          const SizedBox(width: 10), // Espai obligatori de separació
                        ] else ...[
                          const SizedBox(width: 30), // Manté alineació visual respecte a l'arrel
                        ],

                        // 2. SAGNAT VISUAL SEGONS LA PROFUNDITAT DEL PARS/FILLS
                        SizedBox(width: sagnatEsquerre),

                        // 3. ICONA ESTRUCTURAL DE TIPUS DE NODE
                        Icon(
                          node.profunditat == 0
                              ? Icons.local_fire_department
                              : node.profunditat == 1
                              ? Icons.directions_car
                              : Icons.person,
                          size: 18,
                          color: esSeleccionat ? Colors.red.shade900 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),

                        // 4. TEXT DEL TÍTOL DEL BLOC
                        Expanded(
                          child: Text(
                            node.titol,
                            style: TextStyle(
                              fontWeight: node.profunditat == 0 ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13.5,
                              color: esSeleccionat ? Colors.red.shade900 : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 5. ACCIÓ DE CANVI DE PARE (FLETXA) CONDICIONADA AL TIPUS DE BLOC
                        // Restricció estructural: Un passatger (persona) pot canviar de vehicle.
                        if (node.tipusPlantilla == "persona") ...[
                          _construirBotoCanviPare(context, node),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construeix una fletxa que en clicar-la desplega un menú amb els pares vàlids segons la jerarquia
  Widget _construirBotoCanviPare(BuildContext context, InstanceNode node) {
    // Cerquem quins candidats a pare són vàlids en aquest moment de l'incident.
    // Una persona només accepta com a pares nodes de tipus 'vehicle'.
    final paresValids = controlador.llistaPlanaBlocs
        .where((n) => n.tipusPlantilla == "vehicle" && n.id != node.id)
        .toList();

    if (paresValids.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: Icon(Icons.drive_file_move_outlined, color: Colors.blue.shade700, size: 18),
      tooltip: "Moure de vehicle (Canviar de pare)",
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: (String idNouPare) {
        controlador.redefinirPareDeBloc(
          idBlocAMoure: node.id,
          idNouPare: idNouPare,
        );
      },
      itemBuilder: (BuildContext context) {
        return paresValids.map((InstanceNode vehiclePare) {
          return PopupMenuItem<String>(
            value: vehiclePare.id,
            child: Row(
              children: [
                const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Assignar a: ${vehiclePare.titol}"),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  void _mostrarConfirmacioEsborrat(BuildContext context, InstanceNode node) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Confirmar eliminació"),
          content: Text("Això esborrarà el mòdul '${node.titol}' i totes les dades i sub-fills que contingui de forma irreversible. Desitges continuar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CANCEL·LAR"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                controlador.esborrarBloc(node.id);
              },
              child: const Text("ELIMINAR", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
