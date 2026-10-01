import 'package:flutter/material.dart';
import 'package:DynoForm/Emmagatzematge/Estructures/InstanceNode.dart';
import 'package:DynoForm/Questionari/Controlers/QuestionariControlador.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/FabricaPreguntes.dart';
import 'BotoCreacioBlocConcret.dart';

// El component del llenç de la dreta (coordinador del bloc actiu)
class BlocUniversalWidget extends StatelessWidget {
  final InstanceNode nodeBloc;
  final QuestionariControlador controlador;
  final List<Map<String, dynamic>> plantillesPreguntes;

  // SOLUCIÓ 2: Passem la configuració estructural de creació per paràmetre extern
  final Map<String, dynamic>? metadadesCreacio;

  const BlocUniversalWidget({
    super.key,
    required this.nodeBloc,
    required this.controlador,
    required this.plantillesPreguntes,
    this.metadadesCreacio, // Paràmetre opcional (només si el bloc pot tenir sub-blocs fills)
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Capçalera del Bloc
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Text(
              nodeBloc.titol.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // Emboliquem la llista mapejada dins d'un Column com a "child" del Padding
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: plantillesPreguntes.map((jsonPregunta) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: FabricaPreguntes.construir(
                    jsonPregunta: jsonPregunta,
                    idBlocActiu: nodeBloc.id,
                    controlador: controlador,
                  ),
                );
              }).toList(),
            ),
          ),

          // SECCIÓ DINÀMICA MULTI-FILL: Generem tants botons com opcions hi hagi al JSON
          if (metadadesCreacio != null && metadadesCreacio!['opcions_creacio'] != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 12.0,    // Espaiat horitzontal entre botons
                runSpacing: 8.0,  // Espaiat vertical si salten de línia
                children: (metadadesCreacio!['opcions_creacio'] as List).map((opciodinamica) {
                  final opcio = Map<String, dynamic>.from(opciodinamica as Map);

                  return BotoCreacioBlocConcret(
                    idPare: nodeBloc.id,
                    tipusBlocAcrear: opcio['tipus_fills'] ?? '',
                    titolBase: opcio['titol_base'] ?? '',
                    controlador: controlador,
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


