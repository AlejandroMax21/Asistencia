import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'basedatos.dart';

class ConsultasScreen extends StatefulWidget {
  const ConsultasScreen({super.key});

  @override
  State<ConsultasScreen> createState() => _ConsultasScreenState();
}

class _ConsultasScreenState extends State<ConsultasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _queries = [
    {
      'icon': Icons.schedule,
      'title': 'Hora y Edificio',
      'widget': const Query1Widget(),
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Por Fecha',
      'widget': const Query2Widget(),
    },
    {
      'icon': Icons.assessment,
      'title': 'Reporte',
      'widget': const Query3Widget(),
    },
    {
      'icon': Icons.trending_down,
      'title': 'Más Faltas',
      'widget': const Query4Widget(),
    },
    {
      'icon': Icons.warning,
      'title': 'Sin Registro',
      'widget': const Query5Widget(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _queries.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultas Avanzadas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _queries.map((query) {
            return Tab(
              icon: Icon(query['icon']),
              text: query['title'],
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _queries.map((query) => query['widget'] as Widget).toList(),
      ),
    );
  }
}

// Query 1: Profesores por hora y edificio
class Query1Widget extends StatefulWidget {
  const Query1Widget({super.key});

  @override
  State<Query1Widget> createState() => _Query1WidgetState();
}

class _Query1WidgetState extends State<Query1Widget> {
  final _horaController = TextEditingController(text: '08:00');
  final _edificioController = TextEditingController(text: 'UD');
  List<Map<String, dynamic>> _results = [];
  bool _searched = false;
  bool _isLoading = false;

  Future<void> _search() async {
    setState(() => _isLoading = true);
    final results = await DB.getProfesoresPorHoraYEdificio(
      _horaController.text,
      _edificioController.text,
    );
    setState(() {
      _results = results;
      _searched = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profesores por Hora y Edificio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Busca profesores con clase a una hora en un edificio',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _horaController,
            decoration: const InputDecoration(
              labelText: 'Hora (ej: 08:00)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _edificioController,
            decoration: const InputDecoration(
              labelText: 'Edificio (ej: UD)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _search,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.search),
              label: Text(_isLoading ? 'Buscando...' : 'Buscar'),
            ),
          ),
          const SizedBox(height: 24),
          if (_searched && !_isLoading)
            _results.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No se encontraron resultados',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_results.length} resultado(s) encontrado(s)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._results.map((profesor) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        profesor['NOMBRE'][0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      profesor['NOMBRE'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Carrera: ${profesor['CARRERA']}'),
                        Text('Materia: ${profesor['MATERIA']}'),
                        Text('Salón: ${profesor['EDIFICIO']} ${profesor['SALON']}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                )),
              ],
            ),
        ],
      ),
    );
  }
}

// Query 2: Profesores que asistieron en una fecha
class Query2Widget extends StatefulWidget {
  const Query2Widget({super.key});

  @override
  State<Query2Widget> createState() => _Query2WidgetState();
}

class _Query2WidgetState extends State<Query2Widget> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _results = [];
  bool _searched = false;
  bool _isLoading = false;

  Future<void> _search() async {
    setState(() => _isLoading = true);
    final fecha = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final results = await DB.getProfesoresAsistieronFecha(fecha);
    setState(() {
      _results = results;
      _searched = true;
      _isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profesores que Asistieron',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Profesores que asistieron en una fecha específica',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha seleccionada'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _selectDate,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _search,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.search),
              label: Text(_isLoading ? 'Buscando...' : 'Buscar'),
            ),
          ),
          const SizedBox(height: 24),
          if (_searched && !_isLoading)
            _results.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No hay asistencias para esta fecha',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_results.length} profesor(es) asistieron',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._results.map((profesor) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text(
                      profesor['NOMBRE'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Materia: ${profesor['MATERIA']}'),
                        Text('Hora: ${profesor['HORA']}'),
                        Text('Salón: ${profesor['EDIFICIO']} ${profesor['SALON']}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                )),
              ],
            ),
        ],
      ),
    );
  }
}

// Query 3: Reporte de asistencias por profesor
class Query3Widget extends StatefulWidget {
  const Query3Widget({super.key});

  @override
  State<Query3Widget> createState() => _Query3WidgetState();
}

class _Query3WidgetState extends State<Query3Widget> {
  DateTime _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fechaFin = DateTime.now();
  List<Map<String, dynamic>> _results = [];
  bool _searched = false;
  bool _isLoading = false;

  Future<void> _search() async {
    setState(() => _isLoading = true);
    final inicio = DateFormat('yyyy-MM-dd').format(_fechaInicio);
    final fin = DateFormat('yyyy-MM-dd').format(_fechaFin);
    final results = await DB.getReporteAsistenciaProfesor(inicio, fin);
    setState(() {
      _results = results;
      _searched = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reporte de Asistencias',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Estadísticas por profesor en un rango de fechas',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Fecha Inicio'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaInicio)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _fechaInicio,
                  firstDate: DateTime(2020),
                  lastDate: _fechaFin,
                );
                if (date != null) setState(() => _fechaInicio = date);
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Fecha Fin'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaFin)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _fechaFin,
                  firstDate: _fechaInicio,
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _fechaFin = date);
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _search,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.analytics),
              label: Text(_isLoading ? 'Generando...' : 'Generar Reporte'),
            ),
          ),
          const SizedBox(height: 24),
          if (_searched && !_isLoading)
            _results.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No hay datos para el rango seleccionado',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
                : Column(
              children: _results.map((data) {
                final porcentaje = data['PORCENTAJE_ASISTENCIA'] ?? 0.0;
                final color = porcentaje >= 80
                    ? Colors.green
                    : porcentaje >= 60
                    ? Colors.orange
                    : Colors.red;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Text(
                        '${porcentaje.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      data['NOMBRE'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('ID: ${data['NPROFESOR']}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatRow('Total Clases', '${data['TOTAL_CLASES']}'),
                            _buildStatRow('Asistencias', '${data['ASISTENCIAS']}', Colors.green),
                            _buildStatRow('Faltas', '${data['FALTAS']}', Colors.red),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: porcentaje / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Query 4: Materias con más faltas
class Query4Widget extends StatefulWidget {
  const Query4Widget({super.key});

  @override
  State<Query4Widget> createState() => _Query4WidgetState();
}

class _Query4WidgetState extends State<Query4Widget> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await DB.getMateriasConMasFaltas();
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Materias con Más Faltas',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ranking de materias por faltas',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Actualizar',
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
              ? const Center(
            child: Text(
              'No hay datos disponibles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final materia = _results[index];
              final porcentajeFaltas = materia['PORCENTAJE_FALTAS'] ?? 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: porcentajeFaltas > 30 ? Colors.red[50] : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    materia['DESCRIPCION'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Código: ${materia['NMAT']}'),
                      Text('Faltas: ${materia['TOTAL_FALTAS']} de ${materia['TOTAL_CLASES']}'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: porcentajeFaltas / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${porcentajeFaltas.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const Text(
                        'Faltas',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Query 5: Horarios sin asistencias
class Query5Widget extends StatefulWidget {
  const Query5Widget({super.key});

  @override
  State<Query5Widget> createState() => _Query5WidgetState();
}

class _Query5WidgetState extends State<Query5Widget> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await DB.getHorariosSinAsistencia();
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horarios Sin Registro',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sin asistencias registradas',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Actualizar',
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  '¡Excelente!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Todos los horarios tienen registros',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : Column(
            children: [
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '${_results.length} horario(s) sin registro',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final horario = _results[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.schedule, color: Colors.white),
                        ),
                        title: Text(
                          horario['PROFESOR'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Materia: ${horario['MATERIA']}'),
                            Text('Hora: ${horario['HORA']}'),
                            Text('Salón: ${horario['EDIFICIO']} ${horario['SALON']}'),
                          ],
                        ),
                        trailing: const Chip(
                          label: Text(
                            'Sin registro',
                            style: TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.orange,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}