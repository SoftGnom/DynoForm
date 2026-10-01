import 'package:flutter/material.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaBase.dart';

// Especialització: Selector múltiple de tipus acordió (Inline), ideal per a formularis dinàmics
class WidgetPreguntaChoiceMulti extends WidgetPreguntaBase {
  const WidgetPreguntaChoiceMulti({
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
    if (metadadesExtra == null || metadadesExtra!['opcions'] == null) {
      return const Text("Error: Falten les opcions en les metadades.");
    }

    final List<dynamic> llistaDinamica = metadadesExtra!['opcions'] as List<dynamic>;
    final List<String> opcions = llistaDinamica.map((e) => e.toString()).toList();

    return _ChoiceMultiInlineWidget(
      opcions: opcions,
      valorActual: valorActual,
      onCanvi: onCanvi,
    );
  }
}

// Widget amb estat intern per controlar l'obertura i el filtre de cerca
class _ChoiceMultiInlineWidget extends StatefulWidget {
  final List<String> opcions;
  final String valorActual;
  final ValueChanged<String> onCanvi;

  const _ChoiceMultiInlineWidget({
    required this.opcions,
    required this.valorActual,
    required this.onCanvi,
  });

  @override
  __ChoiceMultiInlineWidgetState createState() => __ChoiceMultiInlineWidgetState();
}

class __ChoiceMultiInlineWidgetState extends State<_ChoiceMultiInlineWidget> {
  bool _esObert = false;
  String _filtre = "";

  @override
  Widget build(BuildContext context) {
    // Convertim el String separat per comes de la base de dades a llista
    final List<String> seleccionats = widget.valorActual
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();

    // Filtrem les opcions segons el text introduït pel usuari
    final opcionsFiltrades = widget.opcions
        .where((opcio) => opcio.toLowerCase().contains(_filtre.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. La barra del desplegable (el botó principal)
        InkWell(
          onTap: () {
            setState(() {
              _esObert = !_esObert;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _esObert ? Colors.redAccent : Colors.grey.shade300,
                width: _esObert ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.library_add_check_rounded, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    seleccionats.isEmpty
                        ? "Selecciona múltiples opcions..."
                        : seleccionats.join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: seleccionats.isEmpty ? Colors.grey.shade600 : Colors.black87,
                      fontWeight: seleccionats.isEmpty ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _esObert ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),

        // 2. El panell expandit (només es mostra si _esObert és cert)
        if (_esObert) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Camp de cerca integrat
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cercar opció...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _filtre = text;
                      });
                    },
                  ),
                ),
                const Divider(height: 1),

                // Llista de Checkboxes amb alçada controlada i scroll fluid
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: opcionsFiltrades.isEmpty
                          ? [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No s'ha trobat cap coincidència",
                              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        )
                      ]
                          : opcionsFiltrades.map((opcio) {
                        final bool esSeleccionada = seleccionats.contains(opcio);

                        return CheckboxListTile(
                          value: esSeleccionada,
                          title: Text(opcio, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          activeColor: Colors.redAccent,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          onChanged: (bool? valor) {
                            final novesSeleccions = List<String>.from(seleccionats);
                            if (valor == true) {
                              novesSeleccions.add(opcio);
                            } else {
                              novesSeleccions.remove(opcio);
                            }
                            // Notifiquem el canvi immediatament unit per comes cap a la BD RAM
                            widget.onCanvi(novesSeleccions.join(','));
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
