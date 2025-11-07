class Horario {
  int nhorario;
  String nprofesor;
  String nmat;
  String hora;
  String edificio;
  String salon;

  Horario({
    required this.nhorario,
    required this.nprofesor,
    required this.nmat,
    required this.hora,
    required this.edificio,
    required this.salon,
  });

  Map<String, dynamic> toJSON() {
    return {
      'NHORARIO': nhorario,
      'NPROFESOR': nprofesor,
      'NMAT': nmat,
      'HORA': hora,
      'EDIFICIO': edificio,
      'SALON': salon,
    };
  }

  factory Horario.fromJSON(Map<String, dynamic> json) {
    return Horario(
      nhorario: json['NHORARIO'],
      nprofesor: json['NPROFESOR'],
      nmat: json['NMAT'],
      hora: json['HORA'],
      edificio: json['EDIFICIO'],
      salon: json['SALON'],
    );
  }
}