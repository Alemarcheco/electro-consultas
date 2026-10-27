import 'package:flutter/material.dart';

import 'formato.dart';

/// Unidad con su factor respecto a la unidad base del SI.
typedef Unidad = (String simbolo, double factor);

const uOhmios = <Unidad>[('Ω', 1), ('kΩ', 1e3), ('MΩ', 1e6)];
const uFaradios = <Unidad>[
  ('pF', 1e-12),
  ('nF', 1e-9),
  ('µF', 1e-6),
  ('mF', 1e-3),
  ('F', 1),
];
const uHenrios = <Unidad>[('nH', 1e-9), ('µH', 1e-6), ('mH', 1e-3), ('H', 1)];
const uVoltios = <Unidad>[('mV', 1e-3), ('V', 1), ('kV', 1e3)];
const uAmperios = <Unidad>[('µA', 1e-6), ('mA', 1e-3), ('A', 1)];
const uVatios = <Unidad>[('mW', 1e-3), ('W', 1), ('kW', 1e3)];
const uHercios = <Unidad>[('Hz', 1), ('kHz', 1e3), ('MHz', 1e6)];
const uSegundos = <Unidad>[('µs', 1e-6), ('ms', 1e-3), ('s', 1)];

/// Valor numérico con su unidad elegida, para los campos de las calculadoras.
class Valor extends ChangeNotifier {
  final List<Unidad> unidades;
  final texto = TextEditingController();
  int indice;

  Valor(this.unidades, {this.indice = 0, String inicial = ''}) {
    texto.text = inicial;
    texto.addListener(notifyListeners);
  }

  Valor.simple(String simbolo, {String inicial = ''})
    : this([(simbolo, 1)], inicial: inicial);

  Unidad get unidad => unidades[indice];

  /// Valor en la unidad base (Ω, F, V, A…), o null si está vacío.
  double? get v {
    final n = leerNumero(texto.text);
    return n == null ? null : n * unidad.$2;
  }

  bool get vacio => texto.text.trim().isEmpty;

  void cambiarUnidad(int i) {
    indice = i;
    notifyListeners();
  }

  void limpiar() => texto.clear();

  @override
  void dispose() {
    texto.dispose();
    super.dispose();
  }
}

/// Campo de texto numérico con selector de unidad.
class CampoValor extends StatelessWidget {
  final Valor valor;
  final String etiqueta;
  final String? ayuda;
  final bool conSigno;

  const CampoValor(
    this.valor,
    this.etiqueta, {
    super.key,
    this.ayuda,
    this.conSigno = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListenableBuilder(
        listenable: valor,
        builder: (context, _) => TextField(
          controller: valor.texto,
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
            signed: conSigno,
          ),
          inputFormatters: [conSigno ? filtroDecimalConSigno : filtroDecimal],
          decoration: InputDecoration(
            labelText: etiqueta,
            helperText: ayuda,
            border: const OutlineInputBorder(),
            suffixIcon: valor.unidades.length == 1
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: valor.indice,
                        items: [
                          for (var i = 0; i < valor.unidades.length; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text(valor.unidades[i].$1),
                            ),
                        ],
                        onChanged: (i) => valor.cambiarUnidad(i!),
                      ),
                    ),
                  ),
            suffixText: valor.unidades.length == 1 ? valor.unidad.$1 : null,
          ),
        ),
      ),
    );
  }
}

/// Estado base de las calculadoras: los [Valor] y [Modo] creados con [reg]
/// redibujan la pantalla al cambiar y se liberan al cerrarla.
abstract class EstadoCalculo<W extends StatefulWidget> extends State<W> {
  final _registrados = <ChangeNotifier>[];

  T reg<T extends ChangeNotifier>(T n) {
    _registrados.add(n);
    n.addListener(_cambio);
    return n;
  }

  Valor val(List<Unidad> u, {int i = 0, String ini = ''}) =>
      reg(Valor(u, indice: i, inicial: ini));

  Valor simple(String simbolo, {String ini = ''}) =>
      reg(Valor.simple(simbolo, inicial: ini));

  void _cambio() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final n in _registrados) {
      n.dispose();
    }
    super.dispose();
  }
}

/// Esqueleto de una pantalla de cálculo.
class PantallaCalculo extends StatelessWidget {
  final String titulo;
  final List<Widget> children;
  final List<String> formulas;

  const PantallaCalculo({
    super.key,
    required this.titulo,
    required this.children,
    this.formulas = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...children,
            if (formulas.isNotEmpty) Formulas(formulas),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta con los resultados de un cálculo.
class Resultados extends StatelessWidget {
  final List<(String, String)> filas;
  final String? nota;

  const Resultados(this.filas, {super.key, this.nota});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    final color = esquema.onPrimaryContainer;
    return Card(
      color: esquema.primaryContainer,
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (etiqueta, valor) in filas)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        etiqueta,
                        style: texto.bodyLarge?.copyWith(color: color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: SelectableText(
                        valor,
                        textAlign: TextAlign.right,
                        style: texto.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (nota != null) ...[
              const SizedBox(height: 8),
              Text(
                nota!,
                style: texto.bodyMedium?.copyWith(
                  color: color,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mensaje cuando faltan datos o son incorrectos.
class Aviso extends StatelessWidget {
  final String texto;
  const Aviso(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: esquema.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto, style: TextStyle(color: esquema.secondary)),
          ),
        ],
      ),
    );
  }
}

/// Recuadro con las fórmulas usadas.
class Formulas extends StatelessWidget {
  final List<String> lineas;
  const Formulas(this.lineas, {super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      color: esquema.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fórmulas', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final l in lineas)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(l),
              ),
          ],
        ),
      ),
    );
  }
}

/// Título de sección dentro de una pantalla.
class Titulo extends StatelessWidget {
  final String texto;
  const Titulo(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Selector de modo con botones segmentados que ocupa todo el ancho.
class SelectorModo<T> extends StatelessWidget {
  final T valor;
  final List<(T, String)> opciones;
  final ValueChanged<T> alCambiar;

  const SelectorModo({
    super.key,
    required this.valor,
    required this.opciones,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<T>(
          showSelectedIcon: false,
          segments: [
            for (final (v, t) in opciones)
              ButtonSegment(
                value: v,
                label: Text(t, textAlign: TextAlign.center),
              ),
          ],
          selected: {valor},
          onSelectionChanged: (s) => alCambiar(s.first),
        ),
      ),
    );
  }
}

/// Modo de una pantalla guardado como notificador, para que [PantallaCalculo]
/// redibuje al cambiarlo.
class Modo<T> extends ValueNotifier<T> {
  Modo(super.value);
}
