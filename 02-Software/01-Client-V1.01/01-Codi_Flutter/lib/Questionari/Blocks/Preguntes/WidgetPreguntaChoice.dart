import 'package:flutter/material.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaBase.dart';

// Especialització: Camp desplegable d'opcions amb cerca integrada
class WidgetPreguntaChoice extends WidgetPreguntaBase {
  const WidgetPreguntaChoice({
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
    posicioResposta: 'avall', // Li donem tot l'ample inferior
    metadadesExtra: metadadesExtra,
  );

  @override
  Widget? buildBottomInput(BuildContext context) {
    // 1. Extreure la llista d'opcions des de les metadades del JSON
    if (metadadesExtra == null || metadadesExtra!['opcions'] == null) {
      return const Text(
        "Error: Falten les opcions en les metadades d'aquesta pregunta.",
        style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
      );
    }

    // Convertim la llista dinàmica del JSON a una llista de Strings neta
    final List<dynamic> llistaDinamica = metadadesExtra!['opcions'] as List<dynamic>;
    final List<String> opcions = llistaDinamica.map((e) => e.toString()).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.only(top: 8.0),
          child: DropdownMenu<String>(
            // Ample total adaptat a la targeta del qüestionari
            width: constraints.maxWidth,
            enableSearch: true,         // Activa la cerca/filtre automàtic quan escrius
            enableFilter: true,         // El text introduït filtra la llista desplegable
            requestFocusOnTap: true,    // Obre el teclat en clicar per poder cercar ràpid

            // Text que surt quan no hi ha res seleccionat
            hintText: "Selecciona una opció...",
            // Icona de suport visual
            leadingIcon: const Icon(Icons.list_alt_rounded, color: Colors.grey),

            // Gestiona el valor actual de la base de dades RAM
            initialSelection: valorActual.isNotEmpty ? valorActual : null,

            // Estil del camp de text principal
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),

            // Configuració de la finestra desplegable (alçada màxima optimitzada per a llistes llargues)
            menuHeight: 350, // Permet visualitzar unes 7-8 opcions simultànies amb scroll fluid de fins a 80

            // Callback quan el usuari selecciona un element
            onSelected: (String? nouValor) {
              if (nouValor != null) {
                onCanvi(nouValor);
                FocusScope.of(context).unfocus();//El teclat s'amaga immediatament després de triar!
              }
            },

            // Mapejat real dels elements que es mostraran a la llista
            dropdownMenuEntries: opcions.map<DropdownMenuEntry<String>>((String opcio) {
              final bool esSeleccionada = valorActual == opcio;
              return DropdownMenuEntry<String>(
                value: opcio,
                label: opcio,
                // Estilitzem cada fila per fer-la còmoda de prémer en tauleta (mida de dit)
                style: MenuItemButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  backgroundColor: esSeleccionada ? Colors.red.shade50 : null,
                  foregroundColor: esSeleccionada ? Colors.red.shade900 : Colors.black87,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
