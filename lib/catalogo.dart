import 'package:flutter/material.dart';

import 'datos/arduino.dart';
import 'datos/industrial.dart';
import 'datos/pinouts.dart';
import 'datos/referencias.dart';
import 'pantallas/calc_basicos.dart';
import 'pantallas/calc_circuitos.dart';
import 'pantallas/calc_codigos.dart';
import 'pantallas/calc_industrial.dart';
import 'pantallas/calc_instalaciones.dart';
import 'pantallas/pantalla_pinout.dart';
import 'pantallas/pantalla_solar.dart';
import 'pantallas/pantalla_tabla.dart';
import 'solar/ejemplos.dart';
import 'solar/tablas_solar.dart';

enum Seccion { solar, calculadoras, pinouts, referencias }

/// Una entrada de la lista principal: calculadora, pinout o tabla.
class Entrada {
  final Seccion seccion;
  final String categoria;
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final List<String> palabras;
  final WidgetBuilder abrir;

  const Entrada({
    required this.seccion,
    required this.categoria,
    required this.titulo,
    this.subtitulo = '',
    required this.icono,
    this.palabras = const [],
    required this.abrir,
  });
}

Widget _configurador(BuildContext _) => const ConfiguradorSolar();
Widget _autoconsumo(BuildContext _) => const AutoconsumoRed();

Entrada _calc(
  String cat,
  String titulo,
  String sub,
  IconData icono,
  Widget pantalla, [
  List<String> palabras = const [],
]) => Entrada(
  seccion: Seccion.calculadoras,
  categoria: cat,
  titulo: titulo,
  subtitulo: sub,
  icono: icono,
  palabras: palabras,
  abrir: (_) => pantalla,
);

IconData _iconoPinout(String categoria) => switch (categoria) {
  'USB' => Icons.usb,
  'Fuente de PC' => Icons.power,
  'Ordenador' => Icons.computer,
  'Audio y vídeo' => Icons.settings_input_hdmi,
  'Redes' => Icons.lan,
  'Automoción' => Icons.directions_car,
  'Placas' || 'Arduino' => Icons.developer_board,
  'Industrial' => Icons.precision_manufacturing,
  'Circuitos integrados' => Icons.memory,
  'Reguladores' => Icons.bolt,
  'Transistores' => Icons.call_split,
  'Sensores' => Icons.thermostat,
  _ => Icons.electrical_services,
};

IconData _iconoTabla(String categoria) => switch (categoria) {
  'Códigos' => Icons.palette_outlined,
  'Unidades y fórmulas' => Icons.functions,
  'Cables e instalaciones' => Icons.cable,
  'Materiales' => Icons.science_outlined,
  'Componentes' => Icons.memory,
  'Comunicaciones' => Icons.swap_horiz,
  'Arduino' => Icons.developer_board,
  'Industrial' => Icons.precision_manufacturing,
  _ => Icons.table_chart_outlined,
};

final List<Entrada> catalogo = [
  const Entrada(
    seccion: Seccion.solar,
    categoria: 'Configurar',
    titulo: 'Sistema solar aislado',
    subtitulo: 'Paneles, baterías, regulador e inversor para tus aparatos',
    icono: Icons.solar_power,
    palabras: [
      'solar',
      'off-grid',
      'aislado',
      'apagones',
      'paneles',
      'baterias',
      'inversor',
      'dimensionar',
    ],
    abrir: _configurador,
  ),
  const Entrada(
    seccion: Seccion.solar,
    categoria: 'Configurar',
    titulo: 'Autoconsumo con red',
    subtitulo: 'Paneles e inversor para bajar la factura',
    icono: Icons.home_work,
    palabras: ['solar', 'red', 'autoconsumo', 'factura', 'kwp'],
    abrir: _autoconsumo,
  ),
  for (final e in ejemplosSolares)
    Entrada(
      seccion: Seccion.solar,
      categoria: 'Ejemplos',
      titulo: e.titulo,
      subtitulo: e.descripcion,
      icono: Icons.wb_sunny_outlined,
      palabras: [
        'solar',
        'ejemplo',
        e.lugar,
        e.panel,
        e.bateria,
        e.inversor ?? '',
        e.regulador ?? '',
      ],
      abrir: (_) => ConfiguradorSolar(ejemplo: e),
    ),
  for (final t in tablasSolares)
    Entrada(
      seccion: Seccion.solar,
      categoria: t.categoria,
      titulo: t.titulo,
      subtitulo: t.descripcion,
      icono: Icons.table_chart_outlined,
      palabras: [
        ...t.palabras,
        ...t.columnas,
        for (final f in t.filas) f.first,
      ],
      abrir: (_) => PantallaTabla(t),
    ),
  _calc(
    'Códigos',
    'Código de colores',
    'Resistencias de 4, 5 y 6 bandas',
    Icons.palette,
    const CodigoColores(),
    ['resistencia', 'bandas'],
  ),
  _calc(
    'Códigos',
    'Resistencias SMD',
    '103, 4R7, 1002, EIA-96',
    Icons.crop_square,
    const CodigoSmd(),
    ['smd', 'resistencia'],
  ),
  _calc(
    'Códigos',
    'Código de condensadores',
    '104, 4n7, 2u2…',
    Icons.battery_charging_full,
    const CodigoCondensadores(),
    ['condensador', 'capacitor', 'ceramico'],
  ),
  _calc(
    'Básicos',
    'Ley de Ohm',
    'Tensión, corriente, resistencia y potencia',
    Icons.calculate,
    const LeyOhm(),
    ['ohm', 'voltaje', 'amperios'],
  ),
  _calc(
    'Básicos',
    'Serie y paralelo',
    'Resistencias, condensadores y bobinas',
    Icons.linear_scale,
    const SerieParalelo(),
    ['serie', 'paralelo', 'equivalente'],
  ),
  _calc(
    'Básicos',
    'Divisor de tensión',
    'Vout o R2',
    Icons.call_split,
    const DivisorTension(),
    ['divisor', 'voltaje'],
  ),
  _calc(
    'Básicos',
    'Resistencia para LED',
    'Valor y potencia de la resistencia',
    Icons.lightbulb,
    const ResistenciaLed(),
    ['led'],
  ),
  _calc(
    'Básicos',
    'Potencia eléctrica',
    'Continua, monofásica y trifásica',
    Icons.bolt,
    const PotenciaElectrica(),
    ['potencia', 'watts', 'vatios', 'trifasica', 'cos'],
  ),
  _calc(
    'Circuitos',
    'Temporizador 555',
    'Astable y monoestable',
    Icons.timer,
    const Temporizador555(),
    ['555', 'ne555', 'oscilador'],
  ),
  _calc(
    'Circuitos',
    'Filtro RC / RL',
    'Constante de tiempo y frecuencia de corte',
    Icons.filter_alt,
    const FiltroRC(),
    ['filtro', 'rc', 'tau'],
  ),
  _calc(
    'Circuitos',
    'Reactancia y resonancia',
    'Xc, Xl y frecuencia LC',
    Icons.waves,
    const Reactancia(),
    ['reactancia', 'resonancia', 'impedancia'],
  ),
  _calc(
    'Circuitos',
    'Regulador LM317',
    'Resistencias para la tensión deseada',
    Icons.tune,
    const Regulador317(),
    ['lm317', 'regulador', 'fuente'],
  ),
  _calc(
    'Circuitos',
    'Regulador con zener',
    'Resistencia y potencias',
    Icons.trending_flat,
    const ReguladorZener(),
    ['zener'],
  ),
  _calc(
    'Circuitos',
    'Amplificador operacional',
    'Inversor y no inversor',
    Icons.change_history,
    const AmpOperacional(),
    ['opamp', 'ganancia', 'operacional'],
  ),
  _calc(
    'Circuitos',
    'Decibelios',
    'dB, relaciones y dBm',
    Icons.graphic_eq,
    const Decibelios(),
    ['db', 'decibel', 'dbm'],
  ),
  _calc(
    'Instalaciones',
    'Caída de tensión',
    'Y sección mínima del cable',
    Icons.cable,
    const CaidaTension(),
    ['seccion', 'cable', 'caida', 'mm2'],
  ),
  _calc(
    'Instalaciones',
    'Calibre AWG',
    'AWG ↔ mm²',
    Icons.straighten,
    const ConversorAwg(),
    ['awg', 'calibre', 'gauge'],
  ),
  _calc(
    'Instalaciones',
    'Consumo y coste',
    'kWh y precio de la luz',
    Icons.receipt_long,
    const ConsumoElectrico(),
    ['kwh', 'factura', 'consumo', 'luz'],
  ),
  _calc(
    'Instalaciones',
    'Duración de batería',
    'Autonomía según el consumo',
    Icons.battery_std,
    const DuracionBateria(),
    ['bateria', 'pila', 'mah', 'autonomia'],
  ),
  _calc(
    'Industrial',
    'Escalado 4–20 mA',
    '4–20 mA, 0–10 V… a valor de proceso',
    Icons.speed,
    const Escalado420(),
    ['4-20', '420', 'analogico', 'escalar', 'plc', 'transmisor', 'industrial'],
  ),
  _calc(
    'Industrial',
    'CRC Modbus',
    'CRC-16 y LRC de una trama',
    Icons.tag,
    const CrcModbus(),
    ['modbus', 'crc', 'trama', 'rtu', 'hex', 'industrial'],
  ),
  for (final p in [...pinouts, ...pinoutsArduino, ...pinoutsIndustrial])
    Entrada(
      seccion: Seccion.pinouts,
      categoria: p.categoria,
      titulo: p.titulo,
      subtitulo: p.descripcion,
      icono: _iconoPinout(p.categoria),
      palabras: [
        ...p.palabras,
        'pinout',
        'patillaje',
        'pines',
        for (final pin in p.pines) pin.nombre,
      ],
      abrir: (_) => PantallaPinout(p),
    ),
  for (final t in [...referencias, ...tablasArduino, ...tablasIndustrial])
    Entrada(
      seccion: Seccion.referencias,
      categoria: t.categoria,
      titulo: t.titulo,
      subtitulo: t.descripcion,
      icono: _iconoTabla(t.categoria),
      palabras: [...t.palabras, ...t.columnas],
      abrir: (_) => PantallaTabla(t),
    ),
];

/// Quita tildes y pasa a minúsculas para buscar.
String normalizar(String s) {
  const de = 'áéíóúüñàèìòù';
  const a = 'aeiouunaeiou';
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = de.indexOf(c);
    b.write(i >= 0 ? a[i] : c);
  }
  return b.toString();
}

List<Entrada> buscar(String consulta) {
  final palabras = normalizar(consulta)
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty);
  if (palabras.isEmpty) return [];
  return [
    for (final e in catalogo)
      if (palabras.every(
        (p) => normalizar(
          '${e.titulo} ${e.subtitulo} ${e.categoria} ${e.palabras.join(' ')}',
        ).contains(p),
      ))
        e,
  ];
}
