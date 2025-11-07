import 'package:flutter/material.dart';
import 'basedatos.dart';
import 'materia.dart';

class pantallaMateria extends StatefulWidget {
  const pantallaMateria({super.key});

  @override
  State<pantallaMateria> createState() => _pantallaMateriaState();
}

class _pantallaMateriaState extends State<pantallaMateria> {
  List<Materia> _materias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaterias();
  }

  Future<void> _loadMaterias() async {
    setState(() => _isLoading = true);
    final data = await DB.mostrarMaterias();
    setState(() {
      _materias = data;
      _isLoading = false;
    });
  }

  void _showMateriaDialog({Materia? materia}) {
    final nmatController = TextEditingController(text: materia?.nmat ?? '');
    final descripcionController = TextEditingController(text: materia?.descripcion ?? '');
    final isEdit = materia != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Editar Materia' : 'Nueva Materia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nmatController,
              decoration: const InputDecoration(
                labelText: 'Código de Materia',
                border: OutlineInputBorder(),
              ),
              enabled: !isEdit,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nmatController.text.isEmpty || descripcionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todos los campos son obligatorios')),
                );
                return;
              }

              final nuevaMateria = Materia(
                nmat: nmatController.text,
                descripcion: descripcionController.text,
              );

              try {
                if (isEdit) {
                  await DB.actualizarMateria(nuevaMateria);
                } else {
                  await DB.insertarMateria(nuevaMateria);
                }
                Navigator.pop(context);
                _loadMaterias();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Materia actualizada' : 'Materia creada')),
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

  void _deleteMateria(String nmat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar esta materia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await DB.eliminarMateria(nmat);
                Navigator.pop(context);
                _loadMaterias();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Materia eliminada')),
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
        title: const Text('Materias'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _materias.isEmpty
          ? const Center(
        child: Text(
          'No hay materias registradas',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _materias.length,
        itemBuilder: (context, index) {
          final materia = _materias[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  materia.nmat[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                materia.nmat,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(materia.descripcion),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showMateriaDialog(materia: materia),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteMateria(materia.nmat),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMateriaDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}