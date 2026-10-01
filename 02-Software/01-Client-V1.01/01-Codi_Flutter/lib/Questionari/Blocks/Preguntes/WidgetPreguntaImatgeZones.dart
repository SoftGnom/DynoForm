import 'package:flutter/material.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaBase.dart';


// Especialització: Camp desplegable d'opcions
class WidgetPreguntaImatgeZones extends WidgetPreguntaBase {
  const WidgetPreguntaImatgeZones({
    Key? key,
    required int numero,
    required String text,
    required String valorActual,
    required ValueChanged<String> onCanvi,
    Map<String, dynamic>? metadadesExtra,
  }) : super(
    key: key,
    numero: numero,
    text: text,
    valorActual: valorActual,
    onCanvi: onCanvi,
    posicioResposta: 'avall', // Obligatori a baix per tenir espai ample per la foto
    metadadesExtra: metadadesExtra,
  );

  @override
  Widget? buildBottomInput(BuildContext context) {
    // 1. Extreure la configuració des de les metadades de la plantilla JSON
    if (metadadesExtra == null) return const Text("Error: Falten metadades de la imatge");

    final String rutaImatge = metadadesExtra!['ruta_imatge'] ?? '';
    final List<dynamic>? llistaZones = metadadesExtra!['zones'] as List<dynamic>?;

    if (rutaImatge.isEmpty || llistaZones == null) {
      return const Text("Configuració de zones o imatge invàlida.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contenidor adaptatiu que mesura l'espai real disponible a la tauleta
        LayoutBuilder(
          builder: (context, constraints) {
            final ampleContenidor = constraints.maxWidth;
            // Assumim una proporció d'imatge controlada (ex: aspect ratio 16:9 o basat en disseny)
            final altContenidor = ampleContenidor * 0.5625;

            return Stack(
              children: [
                // CAPA 1: La imatge de fons de l'objecte (un cotxe, cos humà, habitació...)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    rutaImatge,
                    width: ampleContenidor,
                    height: altContenidor,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.broken_image, size: 40)),
                    ),
                  ),
                ),

                // CAPA 2: Mapejat de zones interactives transparents/colorejades per sobre
                ...llistaZones.map((zonaData) {
                  final Map<String, dynamic> zona = zonaData as Map<String, dynamic>;
                  final String zonaId = zona['id'] ?? '';
                  final String etiqueta = zona['etiqueta'] ?? '';

                  // Coordenades normalitzades (en fraccions de 0.0 a 1.0) llegides del JSON
                  final double x = (zona['left'] as num).toDouble();
                  final double y = (zona['top'] as num).toDouble();
                  final double w = (zona['width'] as num).toDouble();
                  final double h = (zona['height'] as num).toDouble();

                  final bool esZonaSeleccionada = valorActual == zonaId;

                  return Positioned(
                    left: x * ampleContenidor,
                    top: y * altContenidor,
                    width: w * ampleContenidor,
                    height: h * altContenidor,
                    child: InkWell(
                      onTap: () {
                        // Lògica de desmarcat simètrica: si es torna a prémer es buida
                        if (esZonaSeleccionada) {
                          onCanvi("");
                        } else {
                          onCanvi(zonaId);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          // Si està seleccionada, es tenyeix de vermell operatiu amb vora nítida
                          color: esZonaSeleccionada
                              ? Colors.redAccent.withOpacity(0.35)
                              : Colors.black.withOpacity(0.05), // Ombres subtils per intuir interacció
                          border: Border.all(
                            color: esZonaSeleccionada ? Colors.red.shade700 : Colors.white.withOpacity(0.5),
                            width: esZonaSeleccionada ? 2.5 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            etiqueta,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),

        // Indicador de text inferior que mostra el diagnòstic actual seleccionat
        if (valorActual.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 6),
                Text(
                  "Zona afectada registrada: ${valorActual.toUpperCase()}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
