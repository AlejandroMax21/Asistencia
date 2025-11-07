import 'package:flutter/material.dart';
import 'basedatos.dart';
import 'horario.dart';
import 'profesor.dart';
import 'materia.dart';

class pantallaHorario extends StatefulWidget {
  const pantallaHorario({super.key});

  @override
  State<pantallaHorario> createState() => _pantallaHorarioState();
}

class _pantallaHorarioState extends State<pantallaHorario> {
  List<Map<String, dynamic>> _horarios = [];
  List<Profesor> _profesores = [];
  List<Materia> _materias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final horarios = await DB.mostrarHorarios();
    final profesores = await DB.mostrarProfesores();
    final materias = await DB.mostrarMaterias();
    setState(() {
      _horarios = horarios;
      _profesores = profesores;
      _materias = materias;
      _isLoading = false;
    });
  }

  void _showHorarioDialog({Map<String, dynamic>? horario}) {
    final nhorarioController = TextEditingController(
      text: horario?['NHORARIO']?.toString() ?? '',
    );
    String? selectedProfesor = horario?['NPROFESOR'];
    String? selectedMateria = horario?['NMAT'];
    final horaController = TextEditingController(text: horario?['HORA'] ?? '');
    final edificioController = TextEditingController(text: horario?['EDIFICIO'] ?? '');
    final salonController = TextEditingController(text: horario?['SALON'] ?? '');
    final isEdit = horario != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Editar Horario' : 'Nuevo Horario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit)
                  TextField(
                    controller: nhorarioController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Horario',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                if (!isEdit) const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedProfesor,
                  decoration: const InputDecoration(
                    labelText: 'Profesor',
                    border: OutlineInputBorder(),
                  ),
                  items: _profesores.map((profesor) {
                    return DropdownMenuItem(
                      value: profesor.nprofesor,
                      child: Text(profesor.nombre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedProfesor = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMateria,
                  decoration: const InputDecoration(
                    labelText: 'Materia',
                    border: OutlineInputBorder(),
                  ),
                  items: _materias.map((materia) {
                    return DropdownMenuItem(
                      value: materia.nmat,
                      child: Text(materia.descripcion),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedMateria = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: horaController,
                  decoration: const InputDecoration(
                    labelText: 'Hora (ej: 08:00)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: edificioController,
                  decoration: const InputDecoration(
                    labelText: 'Edificio',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: salonController,
                  decoration: const InputDecoration(
                    labelText: 'Salón',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if ((!isEdit && nhorarioController.text.isEmpty) ||
                    selectedProfesor == null ||
                    selectedMateria == null ||
                    horaController.text.isEmpty ||
                    edificioController.text.isEmpty ||
                    salonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Todos los campos son obligatorios')),
                  );
                  return;
                }

                final nuevoHorario = Horario(
                  nhorario: isEdit
                      ? horario['NHORARIO']
                      : int.parse(nhorarioController.text),
                  nprofesor: selectedProfesor!,
                  nmat: selectedMateria!,
                  hora: horaController.text,
                  edificio: edificioController.text,
                  salon: salonController.text,
                );

                try {
                  if (isEdit) {
                    await DB.actualizarHorario(nuevoHorario);
                  } else {
                    await DB.insertarHorario(nuevoHorario);
                  }
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Horario actualizado' : 'Horario creado')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: Text(isEdit ? 'Actualizar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteHorario(int nhorario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este horario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await DB.eliminarHorario(nhorario);
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Horario eliminado')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _horarios.isEmpty
          ? const Center(
        child: Text(
          'No hay horarios registrados',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _horarios.length,
        itemBuilder: (context, index) {
          final horario = _horarios[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: const Icon(Icons.schedule, color: Colors.white),
              ),
              title: Text(
                '${horario['NOMBRE_PROFESOR']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Materia: ${horario['NOMBRE_MATERIA']}'),
                  Text('Hora: ${horario['HORA']} - ${horario['EDIFICIO']} ${horario['SALON']}'),
                ],
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showHorarioDialog(horario: horario),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteHorario(horario['NHORARIO']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHorarioDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}