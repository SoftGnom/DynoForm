import 'package:flutter/material.dart';
import 'package:DynoForm/Questionari/Blocks/Preguntes/WidgetPreguntaBase.dart';

class WidgetPreguntaText extends WidgetPreguntaBase {
  const WidgetPreguntaText({
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
    return _CampTextInteractiu(
      valorInicial: valorActual,
      onCanvi: onCanvi,
    );
  }
}

/// Giny privat amb estat per gestionar el controlador de text i el botó d'esborrar
class _CampTextInteractiu extends StatefulWidget {
  final String valorInicial;
  final ValueChanged<String> onCanvi;

  const _CampTextInteractiu({
    required this.valorInicial,
    required this.onCanvi,
  });

  @override
  State<_CampTextInteractiu> createState() => _CampTextInteractiuState();
}

class _CampTextInteractiuState extends State<_CampTextInteractiu> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.valorInicial);
    _focusNode = FocusNode();

    // 🟢 PERSISTÈNCIA AUTOMÀTICA: Desem la dada quan el usuari surt del camp de text
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onCanvi(_textController.text.trim());
      }
    });
  }

  @override
  void didUpdateWidget(covariant _CampTextInteractiu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si l'arbre es redibuixa externament, re-sincronitzem el camp de text
    if (widget.valorInicial != _textController.text && !_focusNode.hasFocus) {
      _textController.text = widget.valorInicial;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _textController,
      focusNode: _focusNode,
      maxLines: null,       // Permet que creixi cap avall dinàmicament
      minLines: 1,          // Per defecte ocupa només una línia
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.done, // Botó "Fet" al teclat virtual
      onFieldSubmitted: (valor) {
        widget.onCanvi(valor.trim());
      },
      onChanged: (text) {
        // Això només serveix perquè el botó de "X" aparegui/desaparegui
        // immediatament mentre l'usuari tecleja, sense fer canvis pesants.
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: "Escriu la descripció o dades aquí...",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        // 🔴 BOTÓ PER ESBORRAR (Només es mostra si hi ha text escrit)
        suffixIcon: _textController.text.isNotEmpty
            ? IconButton(
          icon: Icon(Icons.clear, color: Colors.grey.shade600, size: 20),
          onPressed: () {
            _textController.clear(); // Buida el camp de text visualment
            widget.onCanvi("");      // Guarda el text buit immediatament
            setState(() {});         // Amaga el propi botó d'esborrar
          },
        )
            : null,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
      ),
    );
  }
}
