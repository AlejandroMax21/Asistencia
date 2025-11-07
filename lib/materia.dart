class Materia {
  String nmat;
  String descripcion;

  Materia({
    required this.nmat,
    required this.descripcion,
  });

  Map<String, dynamic> toJSON() {
    return {
      'NMAT': nmat,
      'DESCRIPCION': descripcion,
    };
  }

  factory Materia.fromJSON(Map<String, dynamic> json) {
    return Materia(
      nmat: json['NMAT'],
      descripcion: json['DESCRIPCION'],
    );
  }
}