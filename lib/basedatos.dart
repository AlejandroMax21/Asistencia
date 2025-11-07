import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'materia.dart';
import 'profesor.dart';
import 'horario.dart';
import 'asistencia.dart';

class DB {
  static Future<Database> _conexion() async {
    return openDatabase(
        join(await getDatabasesPath(), "asistencia.db"),
        version: 1,
        onCreate: (db, version) async {
          // Crear tabla MATERIA
          await db.execute(
              "CREATE TABLE MATERIA(NMAT TEXT PRIMARY KEY, DESCRIPCION TEXT)"
          );

          // Crear tabla PROFESOR
          await db.execute(
              "CREATE TABLE PROFESOR(NPROFESOR TEXT PRIMARY KEY, NOMBRE TEXT, CARRERA TEXT)"
          );

          // Crear tabla HORARIO
          await db.execute(
              "CREATE TABLE HORARIO(NHORARIO INTEGER PRIMARY KEY, NPROFESOR TEXT, NMAT TEXT, HORA TEXT, EDIFICIO TEXT, SALON TEXT, FOREIGN KEY(NPROFESOR) REFERENCES PROFESOR(NPROFESOR), FOREIGN KEY(NMAT) REFERENCES MATERIA(NMAT))"
          );

          // Crear tabla ASISTENCIA
          await db.execute(
              "CREATE TABLE ASISTENCIA(IDASISTENCIA INTEGER PRIMARY KEY, NHORARIO INTEGER, FECHA TEXT, ASISTENCIA INTEGER, FOREIGN KEY(NHORARIO) REFERENCES HORARIO(NHORARIO))"
          );
        }
    );
  }

  // ==================== CRUD MATERIA ====================

  static Future<int> insertarMateria(Materia m) async {
    Database base = await _conexion();
    return base.insert("MATERIA", m.toJSON(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<int> eliminarMateria(String nmat) async {
    Database base = await _conexion();
    return base.delete("MATERIA", where: "NMAT = ?", whereArgs: [nmat]);
  }

  static Future<int> actualizarMateria(Materia m) async {
    Database base = await _conexion();
    return base.update("MATERIA", m.toJSON(),
        where: "NMAT = ?", whereArgs: [m.nmat]);
  }

  static Future<List<Materia>> mostrarMaterias() async {
    Database base = await _conexion();
    List<Map<String, dynamic>> temp = await base.query("MATERIA", orderBy: "NMAT");

    return List.generate(temp.length, (contador) {
      return Materia.fromJSON(temp[contador]);
    });
  }

  static Future<Materia?> buscarMateria(String nmat) async {
    Database base = await _conexion();
    List<Map<String, dynamic>> temp = await base.query("MATERIA",
        where: "NMAT = ?", whereArgs: [nmat]);

    if (temp.isEmpty) return null;
    return Materia.fromJSON(temp[0]);
  }

  // ==================== CRUD PROFESOR ====================

  static Future<int> insertarProfesor(Profesor p) async {
    Database base = await _conexion();
    return base.insert("PROFESOR", p.toJSON(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<int> eliminarProfesor(String nprofesor) async {
    Database base = await _conexion();
    return base.delete("PROFESOR", where: "NPROFESOR = ?", whereArgs: [nprofesor]);
  }

  static Future<int> actualizarProfesor(Profesor p) async {
    Database base = await _conexion();
    return base.update("PROFESOR", p.toJSON(),
        where: "NPROFESOR = ?", whereArgs: [p.nprofesor]);
  }

  static Future<List<Profesor>> mostrarProfesores() async {
    Database base = await _conexion();
    List<Map<String, dynamic>> temp = await base.query("PROFESOR", orderBy: "NOMBRE");

    return List.generate(temp.length, (contador) {
      return Profesor.fromJSON(temp[contador]);
    });
  }

  static Future<Profesor?> buscarProfesor(String nprofesor) async {
    Database base = await _conexion();
    List<Map<String, dynamic>> temp = await base.query("PROFESOR",
        where: "NPROFESOR = ?", whereArgs: [nprofesor]);

    if (temp.isEmpty) return null;
    return Profesor.fromJSON(temp[0]);
  }

  // ==================== CRUD HORARIO ====================

  static Future<int> insertarHorario(Horario h) async {
    Database base = await _conexion();
    return base.insert("HORARIO", h.toJSON(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<int> eliminarHorario(int nhorario) async {
    Database base = await _conexion();
    return base.delete("HORARIO", where: "NHORARIO = ?", whereArgs: [nhorario]);
  }

  static Future<int> actualizarHorario(Horario h) async {
    Database base = await _conexion();
    return base.update("HORARIO", h.toJSON(),
        where: "NHORARIO = ?", whereArgs: [h.nhorario]);
  }

  static Future<List<Map<String, dynamic>>> mostrarHorarios() async {
    Database base = await _conexion();
    return await base.rawQuery('''
      SELECT H.*, P.NOMBRE as NOMBRE_PROFESOR, M.DESCRIPCION as NOMBRE_MATERIA
      FROM HORARIO H
      LEFT JOIN PROFESOR P ON H.NPROFESOR = P.NPROFESOR
      LEFT JOIN MATERIA M ON H.NMAT = M.NMAT
      ORDER BY H.HORA
    ''');
  }

  static Future<List<Horario>> mostrarHorariosSimple() async {
    Database base = await _conexion();
    List<Map<String, dynamic>> temp = await base.query("HORARIO", orderBy: "HORA");

    return List.generate(temp.length, (contador) {
      return Horario.fromJSON(temp[contador]);
    });
  }

  static Future<Map<String, dynamic>?> buscarHorario(int nhorario) async {
    Database base = await _conexion();
    List<Map<String, dynamic>> temp = await base.rawQuery('''
      SELECT H.*, P.NOMBRE as NOMBRE_PROFESOR, M.DESCRIPCION as NOMBRE_MATERIA
      FROM HORARIO H
      LEFT JOIN PROFESOR P ON H.NPROFESOR = P.NPROFESOR
      LEFT JOIN MATERIA M ON H.NMAT = M.NMAT
      WHERE H.NHORARIO = ?
    ''', [nhorario]);

    if (temp.isEmpty) return null;
    return temp[0];
  }

  // ==================== CRUD ASISTENCIA ====================

  static Future<int> insertarAsistencia(Asistencia a) async {
    Database base = await _conexion();
    return base.insert("ASISTENCIA", a.toJSON(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<int> eliminarAsistencia(int idasistencia) async {
    Database base = await _conexion();
    return base.delete("ASISTENCIA", where: "IDASISTENCIA = ?", whereArgs: [idasistencia]);
  }

  static Future<int> actualizarAsistencia(Asistencia a) async {
    Database base = await _conexion();
    return base.update("ASISTENCIA", a.toJSON(),
        where: "IDASISTENCIA = ?", whereArgs: [a.idasistencia]);
  }

  static Future<List<Map<String, dynamic>>> mostrarAsistencias() async {
    Database base = await _conexion();
    return await base.rawQuery('''
      SELECT A.*, 
             H.HORA, H.EDIFICIO, H.SALON,
             P.NOMBRE as NOMBRE_PROFESOR,
             M.DESCRIPCION as NOMBRE_MATERIA
      FROM ASISTENCIA A
      INNER JOIN HORARIO H ON A.NHORARIO = H.NHORARIO
      INNER JOIN PROFESOR P ON H.NPROFESOR = P.NPROFESOR
      INNER JOIN MATERIA M ON H.NMAT = M.NMAT
      ORDER BY A.FECHA DESC, H.HORA
    ''');
  }

  static Future<List<Asistencia>> mostrarAsistenciasSimple() async {
    Database base = await _conexion();
    List<Map<String, dynamic>> temp = await base.query("ASISTENCIA", orderBy: "FECHA DESC");

    return List.generate(temp.length, (contador) {
      return Asistencia.fromJSON(temp[contador]);
    });
  }

  static Future<Asistencia?> buscarAsistencia(int idasistencia) async {
    Database base = await _conexion();
    List<Map<String, dynamic>> temp = await base.query("ASISTENCIA",
        where: "IDASISTENCIA = ?", whereArgs: [idasistencia]);

    if (temp.isEmpty) return null;
    return Asistencia.fromJSON(temp[0]);
  }

  // ==================== CONSULTAS AVANZADAS ====================


  // 1. Profesores que tienen clase a una hora específica en un edificio
  static Future<List<Map<String, dynamic>>> getProfesoresPorHoraYEdificio(
      String hora, String edificio) async {
    Database base = await _conexion();
    return await base.rawQuery('''
      SELECT DISTINCT P.NPROFESOR, P.NOMBRE, P.CARRERA,
             H.HORA, H.EDIFICIO, H.SALON,
             M.DESCRIPCION as MATERIA
      FROM PROFESOR P
      INNER JOIN HORARIO H ON P.NPROFESOR = H.NPROFESOR
      INNER JOIN MATERIA M ON H.NMAT = M.NMAT
      WHERE H.HORA = ? AND H.EDIFICIO = ?
      ORDER BY P.NOMBRE
    ''', [hora, edificio]);
  }

  // 2. Profesores que asistieron en una fecha específica
  static Future<List<Map<String, dynamic>>> getProfesoresAsistieronFecha(
      String fecha) async {
    Database base = await _conexion();
    return await base.rawQuery('''
      SELECT DISTINCT P.NPROFESOR, P.NOMBRE, P.CARRERA,
             H.HORA, H.EDIFICIO, H.SALON,
             M.DESCRIPCION as MATERIA
      FROM PROFESOR P
      INNER JOIN HORARIO H ON P.NPROFESOR = H.NPROFESOR
      INNER JOIN MATERIA M ON H.NMAT = M.NMAT
      INNER JOIN ASISTENCIA A ON H.NHORARIO = A.NHORARIO
      WHERE A.FECHA = ? AND A.ASISTENCIA = 1
      ORDER BY P.NOMBRE
    ''', [fecha]);
  }

  // 3. Reporte de asistencias por profesor en un rango de fechas
  static Future<List<Map<String, dynamic>>> getReporteAsistenciaProfesor(
      String fechaInicio, String fechaFin) async {
    Database base = await _conexion();
    return await base.rawQuery('''
      SELECT P.NPROFESOR, P.NOMBRE,
             COUNT(A.IDASISTENCIA) as TOTAL_CLASES,
             SUM(CASE WHEN A.ASISTENCIA = 1 THEN 1 ELSE 0 END) as ASISTENCIAS,
             SUM(CASE WHEN A.ASISTENCIA = 0 THEN 1 ELSE 0 END) as FALTAS,
             ROUND(CAST(SUM(CASE WHEN A.ASISTENCIA = 1 THEN 1 ELSE 0 END) AS FLOAT) / 
                   COUNT(A.IDASISTENCIA) * 100, 2) as PORCENTAJE_ASISTENCIA
      FROM PROFESOR P
      INNER JOIN HORARIO H ON P.NPROFESOR = H.NPROFESOR
      INNER JOIN ASISTENCIA A ON H.NHORARIO = A.NHORARIO
      WHERE A.FECHA BETWEEN ? AND ?
      GROUP BY P.NPROFESOR, P.NOMBRE
      ORDER BY PORCENTAJE_ASISTENCIA DESC
    ''', [fechaInicio, fechaFin]);
  }

  // 4. Materias con más faltas
  static Future<List<Map<String, dynamic>>> getMateriasConMasFaltas() async {
    Database base = await _conexion();
    return await base.rawQuery('''
      SELECT M.NMAT, M.DESCRIPCION,
             COUNT(A.IDASISTENCIA) as TOTAL_CLASES,
             SUM(CASE WHEN A.ASISTENCIA = 0 THEN 1 ELSE 0 END) as TOTAL_FALTAS,
             ROUND(CAST(SUM(CASE WHEN A.ASISTENCIA = 0 THEN 1 ELSE 0 END) AS FLOAT) / 
                   COUNT(A.IDASISTENCIA) * 100, 2) as PORCENTAJE_FALTAS
      FROM MATERIA M
      INNER JOIN HORARIO H ON M.NMAT = H.NMAT
      INNER JOIN ASISTENCIA A ON H.NHORARIO = A.NHORARIO
      GROUP BY M.NMAT, M.DESCRIPCION
      HAVING TOTAL_FALTAS > 0
      ORDER BY TOTAL_FALTAS DESC
    ''');
  }

  // 5. Horarios sin asistencias registradas
  static Future<List<Map<String, dynamic>>> getHorariosSinAsistencia() async {
    Database base = await _conexion();
    return await base.rawQuery('''
      SELECT H.NHORARIO, H.HORA, H.EDIFICIO, H.SALON,
             P.NOMBRE as PROFESOR,
             M.DESCRIPCION as MATERIA
      FROM HORARIO H
      INNER JOIN PROFESOR P ON H.NPROFESOR = P.NPROFESOR
      INNER JOIN MATERIA M ON H.NMAT = M.NMAT
      INNER JOIN ASISTENCIA A ON H.NHORARIO = A.NHORARIO
      WHERE A.IDASISTENCIA IS NULL
      ORDER BY H.HORA
    ''');
  }
}