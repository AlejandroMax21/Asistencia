import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'basedatos.dart';
import 'asistencia.dart';

class pantallaAsistencias extends StatefulWidget {
  const pantallaAsistencias({super.key});

  @override
  State<pantallaAsistencias> createState() => _pantallaAsistenciasState();
}

class _pantallaAsistenciasState extends State<pantallaAsistencias> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _asistencias = [];
  List<Map<String, dynamic>> _horarios = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final asistencias = await DB.mostrarAsistencias();
    final horarios = await DB.mostrarHorarios();
    setState(() {
      _asistencias = asistencias;
      _horarios = horarios;
      _isLoading = false;
    });
  }

  void _showAsistenciaDialog({Map<String, dynamic>? asistencia}) {
    final idasistenciaController = TextEditingController(
      text: asistencia?['IDASISTENCIA']?.toString() ?? '',
    );
    int? selectedHorario = asistencia?['NHORARIO'];
    DateTime selectedDate = asistencia != null
        ? DateTime.parse(asistencia['FECHA'])
        : DateTime.now();
    bool asistio = asistencia?['ASISTENCIA'] == 1;
    final isEdit = asistencia != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Editar Asistencia' : 'Nueva Asistencia'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit)
                  TextField(
                    controller: idasistenciaController,
                    decoration: const InputDecoration(
                      labelText: 'ID Asistencia',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                if (!isEdit) const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedHorario,
                  decoration: const InputDecoration(
                    labelText: 'Horario',
                    border: OutlineInputBorder(),
                  ),
                  items: _horarios.map<DropdownMenuItem<int>>((horario) {
                    return DropdownMenuItem<int>(
                      value: horario['NHORARIO'] as int,
                      child: Text(
                        '${horario['NOMBRE_PROFESOR']} - ${horario['HORA']}',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedHorario = value);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Fecha'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Asistió'),
                  value: asistio,
                  onChanged: (value) {
                    setDialogState(() => asistio = value);
                  },
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
                if ((!isEdit && idasistenciaController.text.isEmpty) ||
                    selectedHorario == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Todos los campos son obligatorios')),
                  );
                  return;
                }

                final nuevaAsistencia = Asistencia(
                  idasistencia: isEdit
                      ? asistencia['IDASISTENCIA']
                      : int.parse(idasistenciaController.text),
                  nhorario: selectedHorario!,
                  fecha: DateFormat('yyyy-MM-dd').format(selectedDate),
                  asistencia: asistio ? 1 : 0,
                );

                try {
                  if (isEdit) {
                    await DB.actualizarAsistencia(nuevaAsistencia);
                  } else {
                    await DB.insertarAsistencia(nuevaAsistencia);
                  }
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Asistencia actualizada' : 'Asistencia registrada')),
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

  void _deleteAsistencia(int idasistencia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar esta asistencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await DB.eliminarAsistencia(idasistencia);
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Asistencia eliminada')),
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

  void _showQuickAttendance() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return QuickAttendanceSheet(
            horarios: _horarios,
            onComplete: _loadData,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencias'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Registros'),
            Tab(icon: Icon(Icons.how_to_reg), text: 'Pasar Lista'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAsistenciasList(),
          _buildQuickAttendanceTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAsistenciaDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAsistenciasList() {
    if (_asistencias.isEmpty) {
      return const Center(
        child: Text(
          'No hay asistencias registradas',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _asistencias.length,
      itemBuilder: (context, index) {
        final asistencia = _asistencias[index];
        final asistio = asistencia['ASISTENCIA'] == 1;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: asistio ? Colors.green : Colors.red,
              child: Icon(
                asistio ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(
              asistencia['NOMBRE_PROFESOR'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Materia: ${asistencia['NOMBRE_MATERIA']}'),
                Text('Fecha: ${asistencia['FECHA']} - ${asistencia['HORA']}'),
                Text('${asistencia['EDIFICIO']} ${asistencia['SALON']}'),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showAsistenciaDialog(asistencia: asistencia),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteAsistencia(asistencia['IDASISTENCIA']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAttendanceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.how_to_reg, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Pasar Lista Rápida',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Seleccione múltiples clases para hoy'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showQuickAttendance,
            icon: const Icon(Icons.playlist_add_check),
            label: const Text('Iniciar Pase de Lista'),
          ),
        ],
      ),
    );
  }
}

class QuickAttendanceSheet extends StatefulWidget {
  final List<Map<String, dynamic>> horarios;
  final VoidCallback onComplete;
  final ScrollController scrollController;

  const QuickAttendanceSheet({
    super.key,
    required this.horarios,
    required this.onComplete,
    required this.scrollController,
  });

  @override
  State<QuickAttendanceSheet> createState() => _QuickAttendanceSheetState();
}

class _QuickAttendanceSheetState extends State<QuickAttendanceSheet> {
  final Map<int, bool> _attendance = {};
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pase de Lista - ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: widget.horarios.length,
              itemBuilder: (context, index) {
                final horario = widget.horarios[index];
                final nhorario = horario['NHORARIO'];

                return CheckboxListTile(
                  title: Text(horario['NOMBRE_PROFESOR']),
                  subtitle: Text(
                    '${horario['NOMBRE_MATERIA']}\n${horario['HORA']} - ${horario['EDIFICIO']} ${horario['SALON']}',
                  ),
                  isThreeLine: true,
                  value: _attendance[nhorario] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _attendance[nhorario] = value ?? false;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (_attendance.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleccione al menos un horario')),
                  );
                  return;
                }

                try {
                  final fecha = DateFormat('yyyy-MM-dd').format(_selectedDate);
                  int nextId = await _getNextAsistenciaId();

                  for (var entry in _attendance.entries) {
                    final nuevaAsistencia = Asistencia(
                      idasistencia: nextId++,
                      nhorario: entry.key,
                      fecha: fecha,
                      asistencia: entry.value ? 1 : 0,
                    );
                    await DB.insertarAsistencia(nuevaAsistencia);
                  }

                  Navigator.pop(context);
                  widget.onComplete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_attendance.length} asistencias registradas')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar Asistencias'),
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _getNextAsistenciaId() async {
    final asistencias = await DB.mostrarAsistencias();
    if (asistencias.isEmpty) return 1;
    final maxId = asistencias.map((a) => a['IDASISTENCIA'] as int).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }
}