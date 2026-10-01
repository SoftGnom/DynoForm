import 'package:flutter/material.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaBase.dart';


// Especialització: Camp desplegable d'opcions
class WidgetPreguntaBool extends WidgetPreguntaBase {
  /// Slot obert opcional per injectar contingut directament sota el text de l'enunciat
  final Widget? ginyExtraInformatiu;

  /// Slot obert opcional per injectar un giny ampli a la part inferior de la targeta
  final Widget? ginyInferiorOpcional;

  const WidgetPreguntaBool({
    Key? key,
    required int numero,
    required String text,
    required String valorActual,
    required ValueChanged<String> onCanvi,
    this.ginyExtraInformatiu,
    this.ginyInferiorOpcional,
    Map<String, dynamic>? metadadesExtra,
  }) : super(
    key: key,
    numero: numero,
    text: text,
    valorActual: valorActual,
    onCanvi: onCanvi,
    posicioResposta: 'esquerra', // Forçat per disseny a l'esquerra
    metadadesExtra: metadadesExtra,
  );

  /// Implementació de l'espai esquerre: Botons SÍ / NO verticals i mútuament excloents
  @override
  Widget? buildLeftInput(BuildContext context) {
    final bool esSi = valorActual == "SÍ";
    final bool esNo = valorActual == "NO";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // BOTÓ "SÍ"
        InkWell(
          onTap: () {
            // LÒGICA DE DESMARCAT: Si ja estava seleccionat "SÍ", es buida la resposta ("")
            if (esSi) {
              onCanvi("");
            } else {
              onCanvi("SÍ");
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 46,
            width: double.infinity,
            decoration: BoxDecoration(
              color: esSi ? Colors.green.shade600 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: esSi ? Colors.green.shade700 : Colors.grey.shade400,
                width: 1.5,
              ),
              boxShadow: esSi ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            alignment: Alignment.center,
            child: Text(
              "SÍ",
              style: TextStyle(
                color: esSi ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // BOTÓ "NO"
        InkWell(
          onTap: () {
            // LÒGICA DE DESMARCAT: Si ja estava seleccionat "NO", es buida la resposta ("")
            if (esNo) {
              onCanvi("");
            } else {
              onCanvi("NO");
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 46,
            width: double.infinity,
            decoration: BoxDecoration(
              color: esNo ? Colors.red.shade600 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: esNo ? Colors.red.shade700 : Colors.grey.shade400,
                width: 1.5,
              ),
              boxShadow: esNo ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            alignment: Alignment.center,
            child: Text(
              "NO",
              style: TextStyle(
                color: esNo ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Override de l'espai informatiu auxiliar sota el text enunciat
  @override
  Widget? buildExtraInfo(BuildContext context) {
    // Si s'ha passat un giny explícit per paràmetre, té prioritat absoluta
    if (ginyExtraInformatiu != null) {
      return ginyExtraInformatiu;
    }
    // Si no, deleguem en el comportament per defecte de la mare (que llegeix metadades d'ajuda del JSON)
    return super.buildExtraInfo(context);
  }

  /// Override del quadrat inferior. Està obert, però si es deixa buit, es col·lapsa a 0 píxels.
  @override
  Widget? buildBottomInput(BuildContext context) {
    // Retorna el giny opcional passat en configuració (pot ser null)
    return ginyInferiorOpcional;
  }
}
