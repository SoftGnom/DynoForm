import 'package:flutter/material.dart';


// La classe mare abstracta de qualsevol formulari visual
abstract class WidgetPreguntaBase extends StatelessWidget {
  final int numero;
  final String text;
  final String valorActual;
  final ValueChanged<String> onCanvi;

  // Paràmetres opcionals que poden governar l'automatització estructural des del JSON
  final String posicioResposta; // 'esquerra' o 'avall'
  final Map<String, dynamic>? metadadesExtra; // Per a continguts adjunts com imatges d'ajuda

  const WidgetPreguntaBase({
    Key? key,
    required this.numero,
    required this.text,
    required this.valorActual,
    required this.onCanvi,
    this.posicioResposta = 'avall',
    this.metadadesExtra,
  }) : super(key: key);

  /// Slot 1: Esquerra. Si retorna null, l'espai es col·lapsa automàticament.
  Widget? buildLeftInput(BuildContext context) => null;

  /// Slot 2: Informació Extra (Text descriptiu, diagrames o fotos auxiliars).
  Widget? buildExtraInfo(BuildContext context) {
    // Exemple d'automatització bàsica: si el JSON de la plantilla porta una línia d'ajuda, la pintem aquí
    if (metadadesExtra != null && metadadesExtra!['text_ajuda'] != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          metadadesExtra!['text_ajuda'] as String,
          style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic
          ),
        ),
      );
    }
    return null;
  }

  /// Slot 3: Davall. Espai per a inputs amples o controls principals.
  Widget? buildBottomInput(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    final Widget? leftContent = buildLeftInput(context);
    final Widget? extraContent = buildExtraInfo(context);
    final Widget? bottomContent = buildBottomInput(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // L'ENUMERACIÓ I EL TEXT PRINCIPAL
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$numero.",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // DISPOSITIU HORITZONTAL (SLOT ESQUERRA + COS DRET)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Si el giny fill disposa informació a l'esquerra, es renderitza aquí
              if (leftContent != null) ...[
                Container(
                  width: 160, // Mida optimitzada per a botons selectors o llistes en tauletes
                  margin: const EdgeInsets.only(right: 20),
                  child: leftContent,
                ),
              ],

              // EL COS DRET (CONTÉ INFORMACIÓ EXTRA I/O LA RESPOSTA INFERIOR)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (extraContent != null) extraContent,
                    if (bottomContent != null) ...[
                      const SizedBox(height: 8),
                      bottomContent,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}