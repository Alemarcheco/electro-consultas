import 'package:flutter/material.dart';

import 'catalogo.dart';

void main() => runApp(const ElectroConsultasApp());

class ElectroConsultasApp extends StatelessWidget {
  const ElectroConsultasApp({super.key});

  @override
  Widget build(BuildContext context) {
    const semilla = Color(0xFF1565C0);
    return MaterialApp(
      title: 'Electro Consultas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: semilla)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: semilla,
          brightness: Brightness.dark,
        ),
      ),
      home: const Inicio(),
    );
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  var _seccion = Seccion.calculadoras;

  static const _nombres = {
    Seccion.solar: 'Solar',
    Seccion.calculadoras: 'Calculadoras',
    Seccion.pinouts: 'Pinouts',
    Seccion.referencias: 'Referencias',
  };

  @override
  Widget build(BuildContext context) {
    final entradas = catalogo.where((e) => e.seccion == _seccion).toList();
    final categorias = <String>[];
    for (final e in entradas) {
      if (!categorias.contains(e.categoria)) categorias.add(e.categoria);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electro Consultas'),
        actions: [
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search),
            onPressed: () =>
                showSearch(context: context, delegate: _Busqueda()),
          ),
        ],
      ),
      body: ListView(
        key: PageStorageKey(_seccion),
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          for (final c in categorias) ...[
            _Cabecera(c),
            for (final e in entradas.where((e) => e.categoria == c))
              TileEntrada(e),
          ],
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion.index,
        onDestinationSelected: (i) =>
            setState(() => _seccion = Seccion.values[i]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.solar_power_outlined),
            selectedIcon: const Icon(Icons.solar_power),
            label: _nombres[Seccion.solar]!,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calculate_outlined),
            selectedIcon: const Icon(Icons.calculate),
            label: _nombres[Seccion.calculadoras]!,
          ),
          NavigationDestination(
            icon: const Icon(Icons.developer_board_outlined),
            selectedIcon: const Icon(Icons.developer_board),
            label: _nombres[Seccion.pinouts]!,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: _nombres[Seccion.referencias]!,
          ),
        ],
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final String texto;
  const _Cabecera(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        texto.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class TileEntrada extends StatelessWidget {
  final Entrada entrada;
  const TileEntrada(this.entrada, {super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: esquema.primaryContainer,
        foregroundColor: esquema.onPrimaryContainer,
        child: Icon(entrada.icono),
      ),
      title: Text(entrada.titulo),
      subtitle: entrada.subtitulo.isEmpty
          ? null
          : Text(
              entrada.subtitulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: entrada.abrir)),
    );
  }
}

class _Busqueda extends SearchDelegate<void> {
  _Busqueda() : super(searchFieldLabel: 'Buscar: usb, 555, led, cable…');

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const BackButtonIcon(),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final r = buscar(query);
    if (query.trim().isEmpty) {
      return const Center(child: Text('Escribe lo que buscas'));
    }
    if (r.isEmpty) return const Center(child: Text('Sin resultados'));
    return ListView(children: [for (final e in r) TileEntrada(e)]);
  }
}
