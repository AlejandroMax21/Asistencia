class Asistencia {
  int idasistencia;
  int nhorario;
  String fecha;
  int asistencia;

  Asistencia({
    required this.idasistencia,
    required this.nhorario,
    required this.fecha,
    required this.asistencia,
  });

  Map<String, dynamic> toJSON() {
    return {
      'IDASISTENCIA': idasistencia,
      'NHORARIO': nhorario,
      'FECHA': fecha,
      'ASISTENCIA': asistencia,
    };
  }

  factory Asistencia.fromJSON(Map<String, dynamic> json) {
    return Asistencia(
      idasistencia: json['IDASISTENCIA'],
      nhorario: json['NHORARIO'],
      fecha: json['FECHA'],
      asistencia: json['ASISTENCIA'],
    );
  }
}