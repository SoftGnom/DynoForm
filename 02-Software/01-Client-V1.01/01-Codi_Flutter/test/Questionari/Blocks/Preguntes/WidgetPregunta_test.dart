import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:DynoForm/Emmagatzematge/Estructures/InstanceNode.dart';
import 'package:DynoForm/Questionari/Controlers/QuestionariControlador.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/FabricaPreguntes.dart';

import '../../../Mock/Questionari/Blocks/Preguntes/FakeQuestionariControlador.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:DynoForm/Emmagatzematge/Estructures/InstanceNode.dart';
import 'package:DynoForm/Questionari/Controlers/QuestionariControlador.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/FabricaPreguntes.dart';

import '../../../Mock/Questionari/Blocks/Preguntes/FakeQuestionariControlador.dart';

void main() {
  late FakeQuestionariControlador controladorFake;

  setUp(() {
    controladorFake = FakeQuestionariControlador();
  });

  group('Tests de Lògica de Negoci - Qüestionaris', () {

    testWidgets('Pregunta BOOL: Lògica de selecció i desmarcatge simètric (SÍ/NO)', (WidgetTester tester) async {
      final Map<String, dynamic> plantillaBool = {
        "numero": 1,
        "id_camp": "oxigen_ok",
        "tipus": "bool",
        "enunciat": "Hi ha suficients ampolles d'oxigen?",
        "metadades": {"text_ajuda": "Ajuda operativa de seguretat"}
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedBuilder(
              animation: controladorFake,
              builder: (context, child) {
                return FabricaPreguntes.construir(
                  jsonPregunta: plantillaBool,
                  idBlocActiu: "BLOC_TEST",
                  controlador: controladorFake,
                );
              },
            ),
          ),
        ),
      );

      // 1. VERIFICACIÓ INICIAL: Estat buit
      expect(find.text("Hi ha suficients ampolles d'oxigen?"), findsOneWidget);
      expect(find.text("Ajuda operativa de seguretat"), findsOneWidget);
      expect(controladorFake.obtenirValorCamp("BLOC_TEST", "oxigen_ok"), "");

      // 2. ACCIÓ: Seleccionem "SÍ"
      await tester.tap(find.text("SÍ"));
      // CORRECCIÓ: Esperem que l'animació de transició del giny s'assequi
      await tester.pumpAndSettle();

      // VERIFICACIÓ: S'ha desat correctament
      expect(controladorFake.darreraClauModificada, "oxigen_ok");
      expect(controladorFake.darrerValorModificat, "SÍ");
      expect(controladorFake.obtenirValorCamp("BLOC_TEST", "oxigen_ok"), "SÍ");

      // 3. ACCIÓ SIMÈTRICA: Tornem a prémer "SÍ" per desmarcar
      await tester.tap(find.text("SÍ"));
      // CORRECCIÓ: Esperem que es completi l'animació de retorn a l'estat buit
      await tester.pumpAndSettle();

      // VERIFICACIÓ: Ara la memòria s'ha buidat rectament
      expect(controladorFake.darrerValorModificat, "");
      expect(controladorFake.obtenirValorCamp("BLOC_TEST", "oxigen_ok"), "");
    });


    testWidgets('Pregunta IMATGE ZONES: Selecció d’àrees geo-posicionades per coordenades', (WidgetTester tester) async {
      final Map<String, dynamic> plantillaZones = {
        "numero": 2,
        "id_camp": "impacte_structural",
        "tipus": "imatge_zones",
        "enunciat": "Indica el sector del vehicle afectat:",
        "metadades": {
          "ruta_imatge": "assets/imatges/test_cotxe.png",
          "zones": [
            {"id": "frontal", "etiqueta": "Sector Frontal", "left": 0.1, "top": 0.1, "width": 0.3, "height": 0.3},
            {"id": "maleter", "etiqueta": "Sector Posterior", "left": 0.6, "top": 0.1, "width": 0.3, "height": 0.3}
          ]
        }
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedBuilder(
              animation: controladorFake,
              builder: (context, child) {
                return FabricaPreguntes.construir(
                  jsonPregunta: plantillaZones,
                  idBlocActiu: "BLOC_TEST",
                  controlador: controladorFake,
                );
              },
            ),
          ),
        ),
      );

      // 1. VERIFICACIÓ INICIAL
      expect(find.text("Sector Frontal"), findsOneWidget);
      expect(find.text("Sector Posterior"), findsOneWidget);
      expect(controladorFake.obtenirValorCamp("BLOC_TEST", "impacte_structural"), "");

      // 2. ACCIÓ: Cliquem a la zona del maleter
      await tester.tap(find.text("Sector Posterior"));
      // CORRECCIÓ: pumpAndSettle resol els fils asíncrons de la imatge i les animacions de la zona externa
      await tester.pumpAndSettle();

      // VERIFICACIÓ: La ID s'ha enviat correctament
      expect(controladorFake.darreraClauModificada, "impacte_structural");
      expect(controladorFake.darrerValorModificat, "maleter");
      expect(controladorFake.obtenirValorCamp("BLOC_TEST", "impacte_structural"), "maleter");

      // VERIFICACIÓ VISUAL LÒGICA: El text reactiu ja s'ha renderitzat completament
      expect(find.text("Zona afectada registrada: MALETER"), findsOneWidget);
    });
  });
}
