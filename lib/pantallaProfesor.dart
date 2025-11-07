import 'package:flutter/material.dart';
import 'basedatos.dart';
import 'profesor.dart';

class pantallaProfesor extends StatefulWidget {
  const pantallaProfesor({super.key});

  @override
  State<pantallaProfesor> createState() => _pantallaProfesorState();
}

class _pantallaProfesorState extends State<pantallaProfesor> {
  List<Profesor> _profesores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfesores();
  }

  Future<void> _loadProfesores() async {
    setState(() => _isLoading = true);
    final data = await DB.mostrarProfesores();
    setState(() {
      _profesores = data;
      _isLoading = false;
    });
  }

  void _showProfesorDialog({Profesor? profesor}) {
    final nprofesorController = TextEditingController(text: profesor?.nprofesor ?? '');
    final nombreController = TextEditingController(text: profesor?.nombre ?? '');
    final carreraController = TextEditingController(text: profesor?.carrera ?? '');
    final isEdit = profesor != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Editar Profesor' : 'Nuevo Profesor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nprofesorController,
                decoration: const InputDecoration(
                  labelText: 'Número de Profesor',
                  border: OutlineInputBorder(),
                ),
                enabled: !isEdit,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: carreraController,
                decoration: const InputDecoration(
                  labelText: 'Carrera',
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
              if (nprofesorController.text.isEmpty ||
                  nombreController.text.isEmpty ||
                  carreraController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todos los campos son obligatorios')),
                );
                return;
              }

              final nuevoProfesor = Profesor(
                nprofesor: nprofesorController.text,
                nombre: nombreController.text,
                carrera: carreraController.text,
              );

              try {
                if (isEdit) {
                  await DB.actualizarProfesor(nuevoProfesor);
                } else {
                  await DB.insertarProfesor(nuevoProfesor);
                }
                Navigator.pop(context);
                _loadProfesores();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Profesor actualizado' : 'Profesor creado')),
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
    );
  }

  void _deleteProfesor(String nprofesor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este profesor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await DB.eliminarProfesor(nprofesor);
                Navigator.pop(context);
                _loadProfesores();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profesor eliminado')),
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
        title: const Text('Profesores'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profesores.isEmpty
          ? const Center(
        child: Text(
          'No hay profesores registrados',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _profesores.length,
        itemBuilder: (context, index) {
          final profesor = _profesores[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Text(
                  profesor.nombre[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                profesor.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${profesor.nprofesor}'),
                  Text('Carrera: ${profesor.carrera}'),
                ],
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showProfesorDialog(profesor: profesor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProfesor(profesor.nprofesor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProfesorDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}