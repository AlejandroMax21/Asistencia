class Profesor {
  String nprofesor;
  String nombre;
  String carrera;

  Profesor({
    required this.nprofesor,
    required this.nombre,
    required this.carrera,
  });

  Map<String, dynamic> toJSON() {
    return {
      'NPROFESOR': nprofesor,
      'NOMBRE': nombre,
      'CARRERA': carrera,
    };
  }

  factory Profesor.fromJSON(Map<String, dynamic> json) {
    return Profesor(
      nprofesor: json['NPROFESOR'],
      nombre: json['NOMBRE'],
      carrera: json['CARRERA'],
    );
  }
}