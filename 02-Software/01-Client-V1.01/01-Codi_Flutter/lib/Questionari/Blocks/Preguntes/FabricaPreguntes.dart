import 'package:flutter/material.dart';
import 'package:DynoForm/Questionari/Controlers/QuestionariControlador.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaBase.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaBool.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaImatgeZones.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaText.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaChoice.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaChoiceMulti.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaImatgeZonesMulti.dart';

// La classe utilitària encarregada de desviar la construcció de preguntes
class FabricaPreguntes {

  /// Converteix la definició estructural d'un mapa JSON en un giny real lligat a l'estat RAM
  static WidgetPreguntaBase construir({
    required Map<String, dynamic> jsonPregunta,
    required String idBlocActiu,
    required QuestionariControlador controlador,
  }) {
    // 1. Extreure propietats transversals obligatòries de la definició de plantilla
    final String clauCamp = jsonPregunta['id_camp'] ?? '';
    final String tipus = jsonPregunta['tipus'] ?? '';
    final int numero = jsonPregunta['numero'] ?? 0;
    final String enunciat = jsonPregunta['enunciat'] ?? '';
    final Map<String, dynamic>? metadades = jsonPregunta['metadades'] as Map<String, dynamic>?;

    if (clauCamp.isEmpty || tipus.isEmpty) {
      throw Exception("Definició de pregunta corrupta. Falta 'id_camp' o 'tipus'.");
    }

    // 2. Resoldre dinàmicament el valor actual que hi ha desat a la memòria RAM per a aquest bloc
    final String valorActual = controlador.obtenirValorCamp(idBlocActiu, clauCamp);

    // 3. Crear el canal simètric d'escriptura (Callback de persistència en segon pla)
    final ValueChanged<String> onCanviDada = (nouValor) {
      controlador.guardarValorCamp(idBlocActiu, clauCamp, nouValor);
    };

    // 4. Actuar com a selector de tipologies segons la lògica de negoci de la plantilla
    switch (tipus) {
      case 'bool':
        return WidgetPreguntaBool(
          key: ValueKey("${idBlocActiu}_$clauCamp"), // Evita conflictes de reciclatge de ginys a Flutter
          numero: numero,
          text: enunciat,
          valorActual: valorActual,
          onCanvi: onCanviDada,
          metadadesExtra: metadades,
        );

      case 'imatge_zones':
        return WidgetPreguntaImatgeZones(
          key: ValueKey("${idBlocActiu}_$clauCamp"),
          numero: numero,
          text: enunciat,
          valorActual: valorActual,
          onCanvi: onCanviDada,
          metadadesExtra: metadades,
        );

      case 'text':
        return WidgetPreguntaText(
          key: ValueKey("${idBlocActiu}_$clauCamp"),
          numero: numero,
          text: enunciat,
          valorActual: valorActual,
          onCanvi: onCanviDada,
          metadadesExtra: metadades,
        );

      case 'choice':
        return WidgetPreguntaChoice(
          key: ValueKey("${idBlocActiu}_$clauCamp"),
          numero: numero,
          text: enunciat,
          valorActual: valorActual,
          onCanvi: onCanviDada,
          metadadesExtra: metadades,
        );

      case 'choice_multi':
        return WidgetPreguntaChoiceMulti(
          key: ValueKey("${idBlocActiu}_$clauCamp"),
          numero: numero,
          text: enunciat,
          valorActual: valorActual,
          onCanvi: onCanviDada,
          metadadesExtra: metadades,
        );

      case 'imatge_zones_multi':
        return WidgetPreguntaImatgeZonesMulti(
          key: ValueKey("${idBlocActiu}_$clauCamp"),
          numero: numero,
          text: enunciat,
          valorActual: valorActual,
          onCanvi: onCanviDada,
          metadadesExtra: metadades,
        );

      default:
      // Evitem el col·lapse de l'App retornant una implementació buida segura en cas de tipus desconegut
        return WidgetPreguntaBool(
          numero: numero,
          text: "[Tipus desconegut: '$tipus'] $enunciat",
          valorActual: '',
          onCanvi: (v) {},
        );
    }
  }
}
