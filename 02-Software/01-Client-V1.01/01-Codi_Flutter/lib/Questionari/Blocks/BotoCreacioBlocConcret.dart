import 'package:flutter/material.dart';
import 'package:DynoForm/Questionari/Controlers/QuestionariControlador.dart';


// El motlle visual del botó per afegir nous mòduls
class BotoCreacioBlocConcret extends StatelessWidget {
  final String idPare;
  final String tipusBlocAcrear;
  final String titolBase;
  final QuestionariControlador controlador;

  const BotoCreacioBlocConcret({
    super.key,
    required this.idPare,
    required this.tipusBlocAcrear,
    required this.titolBase,
    required this.controlador,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade800,
          side: BorderSide(color: Colors.red.shade700, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        icon: const Icon(Icons.add_circle_outline, size: 22),
        label: Text(
          "Afegir $titolBase",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          // Invoquem la lògica del controlador per instanciar un nou node al repositori
          controlador.afegirSubBloc(
            idPare: idPare,
            tipus: tipusBlocAcrear,
            titolBase: titolBase,
          );
        },
      ),
    );
  }
}


