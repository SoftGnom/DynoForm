import 'package:flutter/material.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaBase.dart';

// Especialització: Mapejat interactiu d'imatges amb selecció múltiple de zones
class WidgetPreguntaImatgeZonesMulti extends WidgetPreguntaBase {
  const WidgetPreguntaImatgeZonesMulti({
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
    posicioResposta: 'avall',
    metadadesExtra: metadadesExtra,
  );

  @override
  Widget? buildBottomInput(BuildContext context) {
    if (metadadesExtra == null) return const Text("Error: Falten metadades de la imatge");

    final String rutaImatge = metadadesExtra!['ruta_imatge'] ?? '';
    final List<dynamic>? llistaZones = metadadesExtra!['zones'] as List<dynamic>?;

    if (rutaImatge.isEmpty || llistaZones == null) {
      return const Text("Configuració de zones o imatge invàlida.");
    }

    // Convertim el String separat per comes en una llista de IDs de zones actives
    final List<String> zonesSeleccionades = valorActual.split(',').where((s) => s.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final ampleContenidor = constraints.maxWidth;
            final altContenidor = ampleContenidor * 0.5625; // Proporció 16:9

            return Stack(
              children: [
                // CAPA 1: Imatge de fons
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

                // CAPA 2: Zones interactives
                ...llistaZones.map((zonaData) {
                  final Map<String, dynamic> zona = zonaData as Map<String, dynamic>;
                  final String zonaId = zona['id'] ?? '';
                  final String etiqueta = zona['etiqueta'] ?? '';

                  final double x = (zona['left'] as num).toDouble();
                  final double y = (zona['top'] as num).toDouble();
                  final double w = (zona['width'] as num).toDouble();
                  final double h = (zona['height'] as num).toDouble();

                  // Comprovem si aquesta zona en concret està inclosa dins de la llista
                  final bool esZonaSeleccionada = zonesSeleccionades.contains(zonaId);

                  return Positioned(
                    left: x * ampleContenidor,
                    top: y * altContenidor,
                    width: w * ampleContenidor,
                    height: h * altContenidor,
                    child: InkWell(
                      onTap: () {
                        final novesZones = List<String>.from(zonesSeleccionades);
                        if (esZonaSeleccionada) {
                          novesZones.remove(zonaId); // Si ja hi era, la desmarquem
                        } else {
                          novesZones.add(zonaId);    // Si no hi era, la sumem
                        }
                        onCanvi(novesZones.join(',')); // Guardem unint el llistat per comes
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: esZonaSeleccionada
                              ? Colors.redAccent.withOpacity(0.35)
                              : Colors.black.withOpacity(0.05),
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

        // Indicador inferior que llista de forma agregada totes les zones afectades
        if (zonesSeleccionades.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Zones afectades registrades: ${zonesSeleccionades.join(', ').toUpperCase()}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
