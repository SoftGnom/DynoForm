

// El node atòmic de la memòria RAM
class InstanceNode {
  final String id;                // ID de la instància (ex: "ARREL_vehicle_1")
  String? idPare;           // Qui el va engendrar (null si és l'arrel)
  final String titol;             // Text net (ex: "Vehicle de Rescat 1")
  final String tipusPlantilla;    // Quin formulari JSON de preguntes utilitza
  int profunditat;          // LA TEVA MARCA: 0 = dalt de tot, 1 = fill, 2 = net...
  final Map<String, String> respostes; // Les claus estàtiques i els seus valors

  InstanceNode({
    required this.id,
    this.idPare,
    required this.titol,
    required this.tipusPlantilla,
    required this.profunditat,
    required this.respostes,
  });

  InstanceNode copyWith({
    String? id,
    String? idPare,
    String? titol,
    String? tipusPlantilla,
    int? profunditat,
    Map<String, String>? respostes,
  }) {
    return InstanceNode(
      // Si passem un paràmetre nou, agafa el nou. Si no, clona el que ja té (this)
      id: id ?? this.id,
      idPare: idPare ?? this.idPare,
      titol: titol ?? this.titol,
      tipusPlantilla: tipusPlantilla ?? this.tipusPlantilla,
      profunditat: profunditat ?? this.profunditat,

      // CRÍTIC: Amb Map.from() creem un mapa nou a la RAM i trenquem el punter!
      respostes: respostes ?? Map<String, String>.from(this.respostes),
    );
  }

  // Converteix a Map per a que Sembast ho pugui xifrar i escriure
  Map<String, dynamic> toJson() => {
    'id': id,
    'idPare': idPare,
    'titol': titol,
    'tipusPlantilla': tipusPlantilla,
    'profunditat': profunditat,
    'respostes': respostes,
  };

  // Recupera del Map en carregar de Sembast
  factory InstanceNode.fromJson(Map<String, dynamic> json) => InstanceNode(
    id: json['id'] as String,
    idPare: json['idPare'] as String?,
    titol: json['titol'] as String,
    tipusPlantilla: json['tipusPlantilla'] as String,
    profunditat: json['profunditat'] as int,
    respostes: Map<String, String>.from(json['respostes'] as Map),
  );
}