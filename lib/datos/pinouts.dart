import 'package:flutter/material.dart';

/// Colores de cables usados en los pinouts.
const cRojo = Color(0xFFE53935);
const cNegro = Color(0xFF212121);
const cBlanco = Color(0xFFF5F5F5);
const cVerde = Color(0xFF43A047);
const cNaranja = Color(0xFFFF8F00);
const cAzul = Color(0xFF1E88E5);
const cMarron = Color(0xFF7B3F00);
const cAmarillo = Color(0xFFFDD835);
const cGris = Color(0xFF9E9E9E);
const cVioleta = Color(0xFF8E24AA);

class Pin {
  final String id;
  final String nombre;
  final String descripcion;
  final Color? color;

  /// Segundo color para cables con raya (p. ej. blanco-naranja).
  final Color? raya;

  const Pin(
    this.id,
    this.nombre, [
    this.descripcion = '',
    this.color,
    this.raya,
  ]);
}

enum TipoDiagrama { rejilla, dip, fila }

/// Disposición de los pines para dibujarlos.
class Diagrama {
  final TipoDiagrama tipo;

  /// Filas de identificadores de pin (null = hueco). Las filas más cortas se
  /// centran, como en los conectores D-sub o HDMI.
  final List<List<String?>> filas;
  final String? cuerpo;
  final String? vista;

  const Diagrama.rejilla(this.filas, {this.vista})
    : tipo = TipoDiagrama.rejilla,
      cuerpo = null;

  Diagrama.dip(int n, {this.cuerpo, this.vista})
    : tipo = TipoDiagrama.dip,
      filas = [
        for (var i = 1; i <= n ~/ 2; i++) ['$i', '${n + 1 - i}'],
      ];

  Diagrama.fila(List<String> pines, {this.cuerpo, this.vista})
    : tipo = TipoDiagrama.fila,
      filas = [pines];
}

class Pinout {
  final String titulo;
  final String categoria;
  final String descripcion;
  final Diagrama? diagrama;
  final List<Pin> pines;
  final List<String> notas;
  final List<String> palabras;

  const Pinout({
    required this.titulo,
    required this.categoria,
    this.descripcion = '',
    this.diagrama,
    required this.pines,
    this.notas = const [],
    this.palabras = const [],
  });
}

List<String> _rango(int a, int b) => [for (var i = a; i <= b; i++) '$i'];

const _avisoTransistor =
    'El orden de patillas puede variar según el fabricante: compruébalo en la hoja de datos.';

final pinouts = <Pinout>[
  // ───────────── Ordenador ─────────────
  Pinout(
    titulo: 'USB 2.0 tipo A / B',
    categoria: 'USB',
    descripcion: 'Conector USB clásico de 4 contactos.',
    diagrama: Diagrama.rejilla([_rango(1, 4)], vista: 'Vista frontal'),
    pines: const [
      Pin('1', 'VBUS', '+5 V', cRojo),
      Pin('2', 'D−', 'Datos −', cBlanco),
      Pin('3', 'D+', 'Datos +', cVerde),
      Pin('4', 'GND', 'Masa', cNegro),
    ],
    notas: const ['USB 2.0 entrega hasta 500 mA; USB 3.x hasta 900 mA.'],
    palabras: const ['usb', 'cable', 'colores'],
  ),
  Pinout(
    titulo: 'Micro USB / Mini USB',
    categoria: 'USB',
    descripcion: 'Conectores pequeños de 5 contactos.',
    diagrama: Diagrama.rejilla([_rango(1, 5)], vista: 'Vista frontal'),
    pines: const [
      Pin('1', 'VBUS', '+5 V', cRojo),
      Pin('2', 'D−', 'Datos −', cBlanco),
      Pin('3', 'D+', 'Datos +', cVerde),
      Pin('4', 'ID', 'OTG: a masa = host; libre = dispositivo'),
      Pin('5', 'GND', 'Masa', cNegro),
    ],
    palabras: const ['usb', 'micro', 'mini', 'otg', 'cargador'],
  ),
  Pinout(
    titulo: 'USB 3.0 tipo A',
    categoria: 'USB',
    descripcion: '4 contactos USB 2.0 delante y 5 de SuperSpeed detrás.',
    diagrama: Diagrama.rejilla([
      _rango(1, 4),
      _rango(5, 9),
    ], vista: 'Vista frontal'),
    pines: const [
      Pin('1', 'VBUS', '+5 V', cRojo),
      Pin('2', 'D−', 'Datos USB 2.0 −', cBlanco),
      Pin('3', 'D+', 'Datos USB 2.0 +', cVerde),
      Pin('4', 'GND', 'Masa', cNegro),
      Pin('5', 'SSRX−', 'Recepción SuperSpeed −', cAzul),
      Pin('6', 'SSRX+', 'Recepción SuperSpeed +', cAmarillo),
      Pin('7', 'GND_DRAIN', 'Masa de señal'),
      Pin('8', 'SSTX−', 'Transmisión SuperSpeed −', cVioleta),
      Pin('9', 'SSTX+', 'Transmisión SuperSpeed +', cNaranja),
    ],
    palabras: const ['usb', 'superspeed'],
  ),
  Pinout(
    titulo: 'USB tipo C',
    categoria: 'USB',
    descripcion: 'Reversible, 24 contactos (12 por cara).',
    diagrama: Diagrama.rejilla([
      [for (var i = 1; i <= 12; i++) 'A$i'],
      [for (var i = 12; i >= 1; i--) 'B$i'],
    ], vista: 'Vista frontal del receptáculo'),
    pines: const [
      Pin('A1', 'GND', 'Masa'),
      Pin('A2', 'TX1+', 'SuperSpeed'),
      Pin('A3', 'TX1−', 'SuperSpeed'),
      Pin('A4', 'VBUS', '5 V (hasta 20 V/48 V con Power Delivery)'),
      Pin('A5', 'CC1', 'Configuración / Power Delivery'),
      Pin('A6', 'D+', 'USB 2.0'),
      Pin('A7', 'D−', 'USB 2.0'),
      Pin('A8', 'SBU1', 'Banda lateral (modos alternativos)'),
      Pin('A9', 'VBUS', 'Alimentación'),
      Pin('A10', 'RX2−', 'SuperSpeed'),
      Pin('A11', 'RX2+', 'SuperSpeed'),
      Pin('A12', 'GND', 'Masa'),
      Pin('B1', 'GND', 'Masa'),
      Pin('B2', 'TX2+', 'SuperSpeed'),
      Pin('B3', 'TX2−', 'SuperSpeed'),
      Pin('B4', 'VBUS', 'Alimentación'),
      Pin('B5', 'CC2 / VCONN', 'Configuración o alimentación del cable'),
      Pin('B6', 'D+', 'USB 2.0'),
      Pin('B7', 'D−', 'USB 2.0'),
      Pin('B8', 'SBU2', 'Banda lateral'),
      Pin('B9', 'VBUS', 'Alimentación'),
      Pin('B10', 'RX1−', 'SuperSpeed'),
      Pin('B11', 'RX1+', 'SuperSpeed'),
      Pin('B12', 'GND', 'Masa'),
    ],
    notas: const [
      'Un dispositivo pide 5 V poniendo 5,1 kΩ de CC1 y de CC2 a masa.',
      'Un cable C a A lleva 56 kΩ de CC a VBUS.',
    ],
    palabras: const ['usb', 'type c', 'usb-c', 'power delivery', 'cc'],
  ),
  Pinout(
    titulo: 'ATX 24 pines (placa base)',
    categoria: 'Fuente de PC',
    descripcion: 'Conector principal de alimentación de la placa base.',
    diagrama: Diagrama.rejilla([
      for (var i = 1; i <= 12; i++) ['${i + 12}', '$i'],
    ], vista: 'Dos filas: 1–12 y 13–24 (números grabados en el conector)'),
    pines: const [
      Pin('1', '+3,3 V', '', cNaranja),
      Pin('2', '+3,3 V', '', cNaranja),
      Pin('3', 'GND', '', cNegro),
      Pin('4', '+5 V', '', cRojo),
      Pin('5', 'GND', '', cNegro),
      Pin('6', '+5 V', '', cRojo),
      Pin('7', 'GND', '', cNegro),
      Pin('8', 'PWR_OK', 'Power Good: la fuente está estable', cGris),
      Pin('9', '+5 VSB', 'Tensión de reposo (siempre encendida)', cVioleta),
      Pin('10', '+12 V', '', cAmarillo),
      Pin('11', '+12 V', '', cAmarillo),
      Pin('12', '+3,3 V', '', cNaranja),
      Pin('13', '+3,3 V', 'A veces con hilo marrón de sensado', cNaranja),
      Pin('14', '−12 V', '', cAzul),
      Pin('15', 'GND', '', cNegro),
      Pin('16', 'PS_ON#', 'A masa = encender la fuente', cVerde),
      Pin('17', 'GND', '', cNegro),
      Pin('18', 'GND', '', cNegro),
      Pin('19', 'GND', '', cNegro),
      Pin('20', 'NC', 'Antes −5 V (blanco)'),
      Pin('21', '+5 V', '', cRojo),
      Pin('22', '+5 V', '', cRojo),
      Pin('23', '+5 V', '', cRojo),
      Pin('24', 'GND', '', cNegro),
    ],
    notas: const [
      'Para encender una fuente sin placa, puentea el cable verde (16) con un negro.',
      'El conector de 20 pines antiguo es igual sin los pines 11, 12, 23 y 24.',
    ],
    palabras: const [
      'fuente',
      'atx',
      'pc',
      'ordenador',
      'computadora',
      'placa base',
    ],
  ),
  Pinout(
    titulo: 'CPU 4/8 pines (ATX12V / EPS)',
    categoria: 'Fuente de PC',
    descripcion: 'Alimentación del procesador.',
    diagrama: Diagrama.rejilla([
      ['5', '6', '7', '8'],
      ['1', '2', '3', '4'],
    ], vista: 'Fila de 1–4 (GND) y fila de 5–8 (+12 V)'),
    pines: const [
      Pin('1', 'GND', '', cNegro),
      Pin('2', 'GND', '', cNegro),
      Pin('3', 'GND', '', cNegro),
      Pin('4', 'GND', '', cNegro),
      Pin('5', '+12 V', '', cAmarillo),
      Pin('6', '+12 V', '', cAmarillo),
      Pin('7', '+12 V', '', cAmarillo),
      Pin('8', '+12 V', '', cAmarillo),
    ],
    notas: const [
      'El de 4 pines (P4) tiene 2 GND y 2 +12 V.',
      'No lo confundas con el PCIe de 8 pines: no son compatibles.',
    ],
    palabras: const ['fuente', 'cpu', 'eps', 'p4', 'pc'],
  ),
  Pinout(
    titulo: 'PCI Express 6/8 pines',
    categoria: 'Fuente de PC',
    descripcion: 'Alimentación de tarjetas gráficas.',
    diagrama: Diagrama.rejilla([
      ['1', '2', '3', '4'],
      ['5', '6', '7', '8'],
    ], vista: 'Vista del conector de 8 pines'),
    pines: const [
      Pin('1', '+12 V', '', cAmarillo),
      Pin('2', '+12 V', '', cAmarillo),
      Pin('3', '+12 V', '', cAmarillo),
      Pin('4', 'Sense1 / GND', '', cNegro),
      Pin('5', 'GND', '', cNegro),
      Pin('6', 'Sense0 / GND', '', cNegro),
      Pin('7', 'GND', '', cNegro),
      Pin('8', 'GND', '', cNegro),
    ],
    notas: const [
      '6 pines: 3 × +12 V y 3 × GND, hasta 75 W.',
      '8 pines: hasta 150 W.',
    ],
    palabras: const ['pcie', 'grafica', 'gpu', 'fuente'],
  ),
  Pinout(
    titulo: 'SATA alimentación (15 pines)',
    categoria: 'Fuente de PC',
    descripcion: 'Alimentación de discos y unidades SATA.',
    diagrama: Diagrama.rejilla([_rango(1, 15)]),
    pines: const [
      Pin('1', '+3,3 V', '', cNaranja),
      Pin('2', '+3,3 V', '', cNaranja),
      Pin('3', '+3,3 V / PWDIS', 'En discos nuevos apaga el disco', cNaranja),
      Pin('4', 'GND', '', cNegro),
      Pin('5', 'GND', '', cNegro),
      Pin('6', 'GND', '', cNegro),
      Pin('7', '+5 V', '', cRojo),
      Pin('8', '+5 V', '', cRojo),
      Pin('9', '+5 V', '', cRojo),
      Pin('10', 'GND', '', cNegro),
      Pin('11', 'Staggered spin-up', 'Arranque escalonado / LED de actividad'),
      Pin('12', 'GND', '', cNegro),
      Pin('13', '+12 V', '', cAmarillo),
      Pin('14', '+12 V', '', cAmarillo),
      Pin('15', '+12 V', '', cAmarillo),
    ],
    palabras: const ['sata', 'disco', 'fuente'],
  ),
  Pinout(
    titulo: 'SATA datos (7 pines)',
    categoria: 'Ordenador',
    diagrama: Diagrama.rejilla([_rango(1, 7)]),
    pines: const [
      Pin('1', 'GND'),
      Pin('2', 'A+', 'Transmisión +'),
      Pin('3', 'A−', 'Transmisión −'),
      Pin('4', 'GND'),
      Pin('5', 'B−', 'Recepción −'),
      Pin('6', 'B+', 'Recepción +'),
      Pin('7', 'GND'),
    ],
    palabras: const ['sata', 'disco'],
  ),
  Pinout(
    titulo: 'Molex 4 pines (periféricos)',
    categoria: 'Fuente de PC',
    diagrama: Diagrama.rejilla([_rango(1, 4)]),
    pines: const [
      Pin('1', '+12 V', '', cAmarillo),
      Pin('2', 'GND', '', cNegro),
      Pin('3', 'GND', '', cNegro),
      Pin('4', '+5 V', '', cRojo),
    ],
    palabras: const ['molex', 'fuente', 'ventilador'],
  ),
  Pinout(
    titulo: 'Ventilador 3/4 pines',
    categoria: 'Ordenador',
    descripcion: 'Conector de ventiladores de placa base.',
    diagrama: Diagrama.rejilla([_rango(1, 4)]),
    pines: const [
      Pin('1', 'GND', '', cNegro),
      Pin('2', '+12 V', '', cAmarillo),
      Pin('3', 'Tacómetro', '2 pulsos por vuelta', cVerde),
      Pin('4', 'PWM', 'Control de velocidad, 25 kHz (solo 4 pines)', cAzul),
    ],
    notas: const ['Los colores varían mucho entre fabricantes.'],
    palabras: const ['ventilador', 'fan', 'pwm'],
  ),
  Pinout(
    titulo: 'PS/2 (teclado y ratón)',
    categoria: 'Ordenador',
    descripcion: 'Mini-DIN de 6 pines.',
    diagrama: const Diagrama.rejilla([
      ['6', '5'],
      ['4', '3'],
      ['2', '1'],
    ], vista: 'Conector hembra del ordenador, visto de frente'),
    pines: const [
      Pin('1', 'Data', 'Datos'),
      Pin('2', 'NC', 'Sin conexión'),
      Pin('3', 'GND', 'Masa'),
      Pin('4', 'VCC', '+5 V'),
      Pin('5', 'Clock', 'Reloj'),
      Pin('6', 'NC', 'Sin conexión'),
    ],
    palabras: const ['ps2', 'teclado', 'raton', 'mini din'],
  ),
  Pinout(
    titulo: 'RS-232 DB9 (puerto serie)',
    categoria: 'Ordenador',
    descripcion: 'Puerto serie de PC (DTE, macho).',
    diagrama: Diagrama.rejilla([
      _rango(1, 5),
      _rango(6, 9),
    ], vista: 'Vista frontal del macho'),
    pines: const [
      Pin('1', 'DCD', 'Detección de portadora'),
      Pin('2', 'RXD', 'Recepción de datos'),
      Pin('3', 'TXD', 'Transmisión de datos'),
      Pin('4', 'DTR', 'Terminal de datos listo'),
      Pin('5', 'GND', 'Masa de señal'),
      Pin('6', 'DSR', 'Equipo de datos listo'),
      Pin('7', 'RTS', 'Petición de envío'),
      Pin('8', 'CTS', 'Listo para enviar'),
      Pin('9', 'RI', 'Indicador de llamada'),
    ],
    notas: const [
      'Niveles RS-232: 1 lógico = −3 a −15 V; 0 lógico = +3 a +15 V. No conectar directo a un microcontrolador: usa un MAX232.',
      'Cable null-modem: cruza 2↔3, 7↔8 y 4↔6.',
    ],
    palabras: const ['serie', 'serial', 'rs232', 'db9', 'de9', 'com'],
  ),

  // ───────────── Audio y vídeo ─────────────
  Pinout(
    titulo: 'HDMI tipo A',
    categoria: 'Audio y vídeo',
    descripcion: '19 contactos en dos filas.',
    diagrama: Diagrama.rejilla([
      [for (var i = 1; i <= 19; i += 2) '$i'],
      [for (var i = 2; i <= 18; i += 2) '$i'],
    ], vista: 'Vista frontal del receptáculo'),
    pines: const [
      Pin('1', 'TMDS Data2+'),
      Pin('2', 'Data2 Shield', 'Pantalla'),
      Pin('3', 'TMDS Data2−'),
      Pin('4', 'TMDS Data1+'),
      Pin('5', 'Data1 Shield', 'Pantalla'),
      Pin('6', 'TMDS Data1−'),
      Pin('7', 'TMDS Data0+'),
      Pin('8', 'Data0 Shield', 'Pantalla'),
      Pin('9', 'TMDS Data0−'),
      Pin('10', 'TMDS Clock+'),
      Pin('11', 'Clock Shield', 'Pantalla'),
      Pin('12', 'TMDS Clock−'),
      Pin('13', 'CEC', 'Control entre equipos'),
      Pin('14', 'Utility / HEAC+', 'Reservado / Ethernet y ARC'),
      Pin('15', 'SCL', 'Reloj DDC (I²C)'),
      Pin('16', 'SDA', 'Datos DDC (I²C)'),
      Pin('17', 'DDC/CEC GND', 'Masa'),
      Pin('18', '+5 V', 'Alimentación (máx. 55 mA)'),
      Pin('19', 'Hot Plug Detect', 'Detección de conexión / HEAC−'),
    ],
    palabras: const ['hdmi', 'video', 'tv'],
  ),
  Pinout(
    titulo: 'VGA (DE-15)',
    categoria: 'Audio y vídeo',
    descripcion: 'Vídeo analógico, 15 pines en 3 filas.',
    diagrama: Diagrama.rejilla([
      _rango(1, 5),
      _rango(6, 10),
      _rango(11, 15),
    ], vista: 'Vista frontal del macho'),
    pines: const [
      Pin('1', 'Rojo', 'Vídeo rojo (0,7 V, 75 Ω)', cRojo),
      Pin('2', 'Verde', 'Vídeo verde', cVerde),
      Pin('3', 'Azul', 'Vídeo azul', cAzul),
      Pin('4', 'ID2 / Reservado'),
      Pin('5', 'GND', 'Masa'),
      Pin('6', 'Retorno rojo'),
      Pin('7', 'Retorno verde'),
      Pin('8', 'Retorno azul'),
      Pin('9', '+5 V', 'Alimentación DDC'),
      Pin('10', 'GND sincronismo'),
      Pin('11', 'ID0 / Reservado'),
      Pin('12', 'SDA', 'Datos DDC'),
      Pin('13', 'HSync', 'Sincronismo horizontal'),
      Pin('14', 'VSync', 'Sincronismo vertical'),
      Pin('15', 'SCL', 'Reloj DDC'),
    ],
    palabras: const ['vga', 'monitor', 'video', 'db15'],
  ),
  Pinout(
    titulo: 'DisplayPort',
    categoria: 'Audio y vídeo',
    diagrama: Diagrama.rejilla([
      [for (var i = 1; i <= 19; i += 2) '$i'],
      [for (var i = 2; i <= 20; i += 2) '$i'],
    ], vista: 'Vista frontal'),
    pines: const [
      Pin('1', 'ML_Lane 0+'),
      Pin('2', 'GND'),
      Pin('3', 'ML_Lane 0−'),
      Pin('4', 'ML_Lane 1+'),
      Pin('5', 'GND'),
      Pin('6', 'ML_Lane 1−'),
      Pin('7', 'ML_Lane 2+'),
      Pin('8', 'GND'),
      Pin('9', 'ML_Lane 2−'),
      Pin('10', 'ML_Lane 3+'),
      Pin('11', 'GND'),
      Pin('12', 'ML_Lane 3−'),
      Pin('13', 'CONFIG1', 'A masa'),
      Pin('14', 'CONFIG2', 'A masa'),
      Pin('15', 'AUX CH+', 'Canal auxiliar'),
      Pin('16', 'GND'),
      Pin('17', 'AUX CH−', 'Canal auxiliar'),
      Pin('18', 'Hot Plug Detect'),
      Pin('19', 'Retorno DP_PWR'),
      Pin('20', 'DP_PWR', '+3,3 V'),
    ],
    palabras: const ['displayport', 'dp', 'video', 'monitor'],
  ),
  Pinout(
    titulo: 'Jack 3,5 mm (TRS / TRRS)',
    categoria: 'Audio y vídeo',
    descripcion: 'Auriculares y micrófono.',
    diagrama: Diagrama.fila(
      ['T', 'R1', 'R2', 'S'],
      cuerpo: 'Jack TRRS',
      vista: 'De la punta a la base',
    ),
    pines: const [
      Pin('T', 'Punta (Tip)', 'Canal izquierdo', cBlanco),
      Pin('R1', 'Anillo 1', 'Canal derecho', cRojo),
      Pin('R2', 'Anillo 2', 'TRRS CTIA: masa · OMTP: micrófono'),
      Pin('S', 'Manguito (Sleeve)', 'TRS: masa · CTIA: micrófono · OMTP: masa'),
    ],
    notas: const [
      'TRS (3 contactos): punta = izquierdo, anillo = derecho, manguito = masa.',
      'CTIA es el estándar actual (Apple, la mayoría de Android). OMTP es el antiguo.',
    ],
    palabras: const ['jack', 'auriculares', 'audio', 'trs', 'trrs', 'minijack'],
  ),
  Pinout(
    titulo: 'XLR 3 pines',
    categoria: 'Audio y vídeo',
    descripcion: 'Audio balanceado profesional (micrófonos).',
    diagrama: const Diagrama.rejilla([
      ['1', '2'],
      ['3'],
    ], vista: 'Los números vienen grabados junto a cada contacto'),
    pines: const [
      Pin('1', 'Masa', 'Malla / pantalla'),
      Pin('2', 'Vivo (+)', 'Señal en fase (hot)'),
      Pin('3', 'Retorno (−)', 'Señal invertida (cold)'),
    ],
    notas: const [
      'La alimentación phantom (+48 V) va por los pines 2 y 3 respecto al 1.',
    ],
    palabras: const ['xlr', 'microfono', 'audio', 'balanceado', 'canon'],
  ),
  Pinout(
    titulo: 'MIDI (DIN 5)',
    categoria: 'Audio y vídeo',
    diagrama: const Diagrama.rejilla([
      ['3', null, null, null, '1'],
      [null, '5', null, '4', null],
      [null, null, '2', null, null],
    ], vista: 'Disposición en arco: 3 · 5 · 2 · 4 · 1'),
    pines: const [
      Pin('1', 'NC', 'Sin conexión'),
      Pin('2', 'Masa', 'Pantalla (solo en la salida)'),
      Pin('3', 'NC', 'Sin conexión'),
      Pin('4', 'Fuente de corriente', '+5 V a través de 220 Ω'),
      Pin('5', 'Datos', 'Sumidero de corriente (UART 31 250 baudios)'),
    ],
    notas: const ['La entrada MIDI va siempre aislada con un optoacoplador.'],
    palabras: const ['midi', 'din', 'musica'],
  ),

  // ───────────── Redes y comunicaciones ─────────────
  Pinout(
    titulo: 'RJ45 Ethernet T568B',
    categoria: 'Redes',
    descripcion: 'La norma más usada para cables de red.',
    diagrama: Diagrama.rejilla([
      _rango(1, 8),
    ], vista: 'Clip hacia abajo, contactos hacia ti'),
    pines: const [
      Pin('1', 'Blanco-naranja', 'TX+ (10/100) · BI_DA+', cBlanco, cNaranja),
      Pin('2', 'Naranja', 'TX− · BI_DA−', cNaranja),
      Pin('3', 'Blanco-verde', 'RX+ · BI_DB+', cBlanco, cVerde),
      Pin('4', 'Azul', 'BI_DC+ (Gigabit) · PoE', cAzul),
      Pin('5', 'Blanco-azul', 'BI_DC− (Gigabit) · PoE', cBlanco, cAzul),
      Pin('6', 'Verde', 'RX− · BI_DB−', cVerde),
      Pin('7', 'Blanco-marrón', 'BI_DD+ (Gigabit) · PoE', cBlanco, cMarron),
      Pin('8', 'Marrón', 'BI_DD− (Gigabit) · PoE', cMarron),
    ],
    notas: const [
      'Cable directo: T568B en los dos extremos.',
      'Cable cruzado: T568A en un extremo y T568B en el otro (los equipos modernos no lo necesitan).',
      'Fast Ethernet (100 Mb/s) solo usa los pines 1, 2, 3 y 6.',
    ],
    palabras: const [
      'rj45',
      'ethernet',
      'red',
      'utp',
      'cable de red',
      'internet',
      'lan',
    ],
  ),
  Pinout(
    titulo: 'RJ45 Ethernet T568A',
    categoria: 'Redes',
    diagrama: Diagrama.rejilla([
      _rango(1, 8),
    ], vista: 'Clip hacia abajo, contactos hacia ti'),
    pines: const [
      Pin('1', 'Blanco-verde', 'TX+ · BI_DA+', cBlanco, cVerde),
      Pin('2', 'Verde', 'TX− · BI_DA−', cVerde),
      Pin('3', 'Blanco-naranja', 'RX+ · BI_DB+', cBlanco, cNaranja),
      Pin('4', 'Azul', 'BI_DC+', cAzul),
      Pin('5', 'Blanco-azul', 'BI_DC−', cBlanco, cAzul),
      Pin('6', 'Naranja', 'RX− · BI_DB−', cNaranja),
      Pin('7', 'Blanco-marrón', 'BI_DD+', cBlanco, cMarron),
      Pin('8', 'Marrón', 'BI_DD−', cMarron),
    ],
    notas: const [
      'Es igual que T568B intercambiando los pares naranja y verde.',
    ],
    palabras: const ['rj45', 'ethernet', 'red', 'utp', 'cable de red', 'lan'],
  ),
  Pinout(
    titulo: 'RJ11 / RJ12 teléfono',
    categoria: 'Redes',
    diagrama: Diagrama.rejilla([
      _rango(1, 6),
    ], vista: 'Clip hacia abajo, contactos hacia ti'),
    pines: const [
      Pin('1', '—', 'Solo en RJ12 (6P6C)'),
      Pin('2', 'Línea 2 (Tip)', '', cNegro),
      Pin('3', 'Línea 1 (Ring)', '', cRojo),
      Pin('4', 'Línea 1 (Tip)', '', cVerde),
      Pin('5', 'Línea 2 (Ring)', '', cAmarillo),
      Pin('6', '—', 'Solo en RJ12 (6P6C)'),
    ],
    notas: const [
      'Una línea normal usa solo los dos contactos centrales (3 y 4).',
      'Tensión en reposo ≈ 48 V CC; al sonar ≈ 90 V CA.',
    ],
    palabras: const ['rj11', 'telefono', 'linea'],
  ),
  Pinout(
    titulo: 'OBD-II (diagnóstico de coche)',
    categoria: 'Automoción',
    descripcion: 'Conector J1962 de 16 pines bajo el volante.',
    diagrama: Diagrama.rejilla([
      _rango(1, 8),
      _rango(9, 16),
    ], vista: 'Vista frontal del conector del coche'),
    pines: const [
      Pin('1', 'Fabricante', ''),
      Pin('2', 'J1850 Bus+', 'SAE J1850 PWM/VPW'),
      Pin('3', 'Fabricante', ''),
      Pin('4', 'Masa chasis', ''),
      Pin('5', 'Masa de señal', ''),
      Pin('6', 'CAN High', 'ISO 15765-4'),
      Pin('7', 'Línea K', 'ISO 9141-2 / ISO 14230 (KWP2000)'),
      Pin('8', 'Fabricante', ''),
      Pin('9', 'Fabricante', ''),
      Pin('10', 'J1850 Bus−', 'Solo J1850 PWM'),
      Pin('11', 'Fabricante', ''),
      Pin('12', 'Fabricante', ''),
      Pin('13', 'Fabricante', ''),
      Pin('14', 'CAN Low', 'ISO 15765-4'),
      Pin('15', 'Línea L', 'ISO 9141-2 / ISO 14230'),
      Pin('16', '+12 V batería', 'Siempre con tensión'),
    ],
    palabras: const [
      'obd',
      'obd2',
      'coche',
      'carro',
      'auto',
      'diagnostico',
      'can',
    ],
  ),

  // ───────────── Placas y programación ─────────────
  Pinout(
    titulo: 'Raspberry Pi (GPIO 40 pines)',
    categoria: 'Placas',
    descripcion: 'Cabecera de los modelos B+, 2, 3, 4, 5 y Zero.',
    diagrama: Diagrama.rejilla([
      for (var i = 1; i <= 39; i += 2) ['$i', '${i + 1}'],
    ], vista: 'Pin 1 arriba a la izquierda (cuadrado), puertos USB abajo'),
    pines: const [
      Pin('1', '3V3', 'Alimentación 3,3 V', cNaranja),
      Pin('2', '5V', 'Alimentación 5 V', cRojo),
      Pin('3', 'GPIO2', 'SDA1 (I²C)', cAzul),
      Pin('4', '5V', '', cRojo),
      Pin('5', 'GPIO3', 'SCL1 (I²C)', cAzul),
      Pin('6', 'GND', '', cNegro),
      Pin('7', 'GPIO4', 'GPCLK0 / 1-Wire', cVerde),
      Pin('8', 'GPIO14', 'TXD (UART)', cVioleta),
      Pin('9', 'GND', '', cNegro),
      Pin('10', 'GPIO15', 'RXD (UART)', cVioleta),
      Pin('11', 'GPIO17', '', cVerde),
      Pin('12', 'GPIO18', 'PWM0 / PCM_CLK', cVerde),
      Pin('13', 'GPIO27', '', cVerde),
      Pin('14', 'GND', '', cNegro),
      Pin('15', 'GPIO22', '', cVerde),
      Pin('16', 'GPIO23', '', cVerde),
      Pin('17', '3V3', '', cNaranja),
      Pin('18', 'GPIO24', '', cVerde),
      Pin('19', 'GPIO10', 'MOSI (SPI0)', cAmarillo),
      Pin('20', 'GND', '', cNegro),
      Pin('21', 'GPIO9', 'MISO (SPI0)', cAmarillo),
      Pin('22', 'GPIO25', '', cVerde),
      Pin('23', 'GPIO11', 'SCLK (SPI0)', cAmarillo),
      Pin('24', 'GPIO8', 'CE0 (SPI0)', cAmarillo),
      Pin('25', 'GND', '', cNegro),
      Pin('26', 'GPIO7', 'CE1 (SPI0)', cAmarillo),
      Pin('27', 'GPIO0', 'ID_SD (EEPROM HAT)', cGris),
      Pin('28', 'GPIO1', 'ID_SC (EEPROM HAT)', cGris),
      Pin('29', 'GPIO5', '', cVerde),
      Pin('30', 'GND', '', cNegro),
      Pin('31', 'GPIO6', '', cVerde),
      Pin('32', 'GPIO12', 'PWM0', cVerde),
      Pin('33', 'GPIO13', 'PWM1', cVerde),
      Pin('34', 'GND', '', cNegro),
      Pin('35', 'GPIO19', 'PCM_FS / MISO (SPI1)', cVerde),
      Pin('36', 'GPIO16', 'CE2 (SPI1)', cVerde),
      Pin('37', 'GPIO26', '', cVerde),
      Pin('38', 'GPIO20', 'PCM_DIN / MOSI (SPI1)', cVerde),
      Pin('39', 'GND', '', cNegro),
      Pin('40', 'GPIO21', 'PCM_DOUT / SCLK (SPI1)', cVerde),
    ],
    notas: const [
      'Los GPIO trabajan a 3,3 V y NO toleran 5 V.',
      'Corriente máxima recomendada por pin: 16 mA (50 mA en total).',
    ],
    palabras: const ['raspberry', 'rpi', 'gpio', 'pi'],
  ),
  Pinout(
    titulo: 'Arduino Uno R3',
    categoria: 'Arduino',
    descripcion: 'Pines de la placa Arduino Uno (ATmega328P).',
    pines: const [
      Pin('D0', 'RX', 'Recepción serie (USB)', cVioleta),
      Pin('D1', 'TX', 'Transmisión serie (USB)', cVioleta),
      Pin('D2', 'INT0', 'Interrupción externa', cVerde),
      Pin('D3', 'PWM · INT1', '', cVerde),
      Pin('D4', 'Digital', '', cVerde),
      Pin('D5', 'PWM', '', cVerde),
      Pin('D6', 'PWM', '', cVerde),
      Pin('D7', 'Digital', '', cVerde),
      Pin('D8', 'Digital', '', cVerde),
      Pin('D9', 'PWM', '', cVerde),
      Pin('D10', 'PWM · SS', 'SPI', cAmarillo),
      Pin('D11', 'PWM · MOSI', 'SPI', cAmarillo),
      Pin('D12', 'MISO', 'SPI', cAmarillo),
      Pin('D13', 'SCK · LED', 'SPI · LED de la placa', cAmarillo),
      Pin('A0', 'Analógico 0', 'ADC 10 bits', cAzul),
      Pin('A1', 'Analógico 1', '', cAzul),
      Pin('A2', 'Analógico 2', '', cAzul),
      Pin('A3', 'Analógico 3', '', cAzul),
      Pin('A4', 'Analógico 4 · SDA', 'I²C', cAzul),
      Pin('A5', 'Analógico 5 · SCL', 'I²C', cAzul),
      Pin('VIN', 'Entrada', '7–12 V (recomendado)', cRojo),
      Pin('5V', '5 V', 'Salida del regulador', cRojo),
      Pin('3V3', '3,3 V', 'Máx. 50 mA', cNaranja),
      Pin('GND', 'Masa', '', cNegro),
      Pin('AREF', 'Referencia analógica', ''),
      Pin('IOREF', 'Tensión de E/S', '5 V en el Uno'),
      Pin('RESET', 'Reinicio', 'A masa para reiniciar'),
    ],
    notas: const [
      'Máximo 40 mA por pin (20 mA recomendado) y 200 mA en total.',
    ],
    palabras: const ['arduino', 'uno', 'atmega', 'pwm'],
  ),
  Pinout(
    titulo: 'ICSP / ISP AVR (6 pines)',
    categoria: 'Arduino',
    descripcion: 'Programación en circuito de microcontroladores AVR.',
    diagrama: const Diagrama.rejilla([
      ['1', '2'],
      ['3', '4'],
      ['5', '6'],
    ], vista: 'Vista superior'),
    pines: const [
      Pin('1', 'MISO'),
      Pin('2', 'VCC'),
      Pin('3', 'SCK'),
      Pin('4', 'MOSI'),
      Pin('5', 'RESET'),
      Pin('6', 'GND'),
    ],
    palabras: const ['icsp', 'isp', 'avr', 'programador', 'usbasp'],
  ),

  // ───────────── Componentes ─────────────
  Pinout(
    titulo: 'NE555 temporizador',
    categoria: 'Circuitos integrados',
    diagrama: Diagrama.dip(
      8,
      cuerpo: 'NE555',
      vista: 'Vista superior, muesca arriba',
    ),
    pines: const [
      Pin('1', 'GND', 'Masa'),
      Pin('2', 'TRIG', 'Disparo (< 1/3 VCC)'),
      Pin('3', 'OUT', 'Salida (hasta 200 mA)'),
      Pin('4', 'RESET', 'A VCC si no se usa'),
      Pin('5', 'CTRL', 'Control (10 nF a masa)'),
      Pin('6', 'THR', 'Umbral (> 2/3 VCC)'),
      Pin('7', 'DIS', 'Descarga'),
      Pin('8', 'VCC', '4,5–16 V'),
    ],
    palabras: const ['555', 'ne555', 'temporizador', 'timer'],
  ),
  Pinout(
    titulo: 'LM358 / doble operacional',
    categoria: 'Circuitos integrados',
    descripcion: 'Patillaje estándar de los dobles operacionales (LM358, TL072, NE5532…).',
    diagrama: Diagrama.dip(
      8,
      cuerpo: 'LM358',
      vista: 'Vista superior, muesca arriba',
    ),
    pines: const [
      Pin('1', 'OUT A', 'Salida A'),
      Pin('2', 'IN− A', 'Entrada inversora A'),
      Pin('3', 'IN+ A', 'Entrada no inversora A'),
      Pin('4', 'V− / GND', 'Alimentación negativa'),
      Pin('5', 'IN+ B', 'Entrada no inversora B'),
      Pin('6', 'IN− B', 'Entrada inversora B'),
      Pin('7', 'OUT B', 'Salida B'),
      Pin('8', 'V+', 'Alimentación positiva'),
    ],
    palabras: const [
      'lm358',
      'tl072',
      'tl082',
      'ne5532',
      'operacional',
      'opamp',
    ],
  ),
  Pinout(
    titulo: 'LM741 operacional',
    categoria: 'Circuitos integrados',
    diagrama: Diagrama.dip(
      8,
      cuerpo: 'LM741',
      vista: 'Vista superior, muesca arriba',
    ),
    pines: const [
      Pin('1', 'Offset null', 'Ajuste de offset'),
      Pin('2', 'IN−', 'Entrada inversora'),
      Pin('3', 'IN+', 'Entrada no inversora'),
      Pin('4', 'V−', 'Alimentación negativa'),
      Pin('5', 'Offset null', 'Ajuste de offset'),
      Pin('6', 'OUT', 'Salida'),
      Pin('7', 'V+', 'Alimentación positiva'),
      Pin('8', 'NC', 'Sin conexión'),
    ],
    notas: const ['El mismo patillaje usan TL071, TL081, CA3140, OP07…'],
    palabras: const ['741', 'ua741', 'operacional', 'opamp', 'tl071'],
  ),
  Pinout(
    titulo: '74HC595 registro de desplazamiento',
    categoria: 'Circuitos integrados',
    diagrama: Diagrama.dip(
      16,
      cuerpo: '74HC595',
      vista: 'Vista superior, muesca arriba',
    ),
    pines: const [
      Pin('1', 'QB', 'Salida 1'),
      Pin('2', 'QC', 'Salida 2'),
      Pin('3', 'QD', 'Salida 3'),
      Pin('4', 'QE', 'Salida 4'),
      Pin('5', 'QF', 'Salida 5'),
      Pin('6', 'QG', 'Salida 6'),
      Pin('7', 'QH', 'Salida 7'),
      Pin('8', 'GND', 'Masa'),
      Pin('9', 'QH\'', 'Salida serie (para encadenar)'),
      Pin('10', 'SRCLR', 'Borrado (activo bajo, a VCC)'),
      Pin('11', 'SRCLK', 'Reloj de desplazamiento'),
      Pin('12', 'RCLK', 'Reloj de registro (latch)'),
      Pin('13', 'OE', 'Habilitar salidas (activo bajo, a GND)'),
      Pin('14', 'SER', 'Entrada de datos'),
      Pin('15', 'QA', 'Salida 0'),
      Pin('16', 'VCC', '2–6 V'),
    ],
    palabras: const ['595', '74hc595', 'shift register', 'registro'],
  ),
  Pinout(
    titulo: 'ATmega328P (DIP-28)',
    categoria: 'Circuitos integrados',
    descripcion: 'Microcontrolador del Arduino Uno. Entre paréntesis, el pin de Arduino.',
    diagrama: Diagrama.dip(
      28,
      cuerpo: 'ATmega328P',
      vista: 'Vista superior, muesca arriba',
    ),
    pines: const [
      Pin('1', 'PC6 · RESET', ''),
      Pin('2', 'PD0 · RXD', '(D0)'),
      Pin('3', 'PD1 · TXD', '(D1)'),
      Pin('4', 'PD2 · INT0', '(D2)'),
      Pin('5', 'PD3 · INT1', '(D3, PWM)'),
      Pin('6', 'PD4', '(D4)'),
      Pin('7', 'VCC', ''),
      Pin('8', 'GND', ''),
      Pin('9', 'PB6 · XTAL1', 'Cristal'),
      Pin('10', 'PB7 · XTAL2', 'Cristal'),
      Pin('11', 'PD5', '(D5, PWM)'),
      Pin('12', 'PD6', '(D6, PWM)'),
      Pin('13', 'PD7', '(D7)'),
      Pin('14', 'PB0', '(D8)'),
      Pin('15', 'PB1', '(D9, PWM)'),
      Pin('16', 'PB2 · SS', '(D10, PWM)'),
      Pin('17', 'PB3 · MOSI', '(D11, PWM)'),
      Pin('18', 'PB4 · MISO', '(D12)'),
      Pin('19', 'PB5 · SCK', '(D13)'),
      Pin('20', 'AVCC', 'Alimentación del ADC'),
      Pin('21', 'AREF', 'Referencia analógica'),
      Pin('22', 'GND', ''),
      Pin('23', 'PC0 · ADC0', '(A0)'),
      Pin('24', 'PC1 · ADC1', '(A1)'),
      Pin('25', 'PC2 · ADC2', '(A2)'),
      Pin('26', 'PC3 · ADC3', '(A3)'),
      Pin('27', 'PC4 · SDA', '(A4)'),
      Pin('28', 'PC5 · SCL', '(A5)'),
    ],
    palabras: const ['atmega', '328', 'arduino', 'avr', 'microcontrolador'],
  ),
  Pinout(
    titulo: 'PC817 optoacoplador',
    categoria: 'Circuitos integrados',
    diagrama: Diagrama.dip(
      4,
      cuerpo: 'PC817',
      vista: 'Vista superior, punto = pin 1',
    ),
    pines: const [
      Pin('1', 'Ánodo', 'LED interno (+)'),
      Pin('2', 'Cátodo', 'LED interno (−)'),
      Pin('3', 'Emisor', 'Fototransistor'),
      Pin('4', 'Colector', 'Fototransistor'),
    ],
    palabras: const ['pc817', 'optoacoplador', 'opto', 'aislamiento'],
  ),
  Pinout(
    titulo: 'Reguladores 78xx (7805, 7812…)',
    categoria: 'Reguladores',
    diagrama: Diagrama.fila(
      ['1', '2', '3'],
      cuerpo: 'TO-220',
      vista: 'De frente, patas abajo',
    ),
    pines: const [
      Pin('1', 'IN', 'Entrada (≥ Vout + 2 V)'),
      Pin('2', 'GND', 'Masa (unida a la aleta)'),
      Pin('3', 'OUT', 'Salida regulada'),
    ],
    notas: const [
      'Pon 330 nF en la entrada y 100 nF en la salida.',
      'El 78L05 (TO-92) tiene el orden OUT · GND · IN mirando la cara plana.',
    ],
    palabras: const ['7805', '7812', '7809', '78xx', 'regulador', 'lm7805'],
  ),
  Pinout(
    titulo: 'Reguladores 79xx (7905, 7912…)',
    categoria: 'Reguladores',
    diagrama: Diagrama.fila(
      ['1', '2', '3'],
      cuerpo: 'TO-220',
      vista: 'De frente, patas abajo',
    ),
    pines: const [
      Pin('1', 'GND', 'Masa'),
      Pin('2', 'IN', 'Entrada negativa (unida a la aleta)'),
      Pin('3', 'OUT', 'Salida negativa'),
    ],
    palabras: const ['7905', '7912', '79xx', 'regulador', 'negativo'],
  ),
  Pinout(
    titulo: 'LM317 regulador ajustable',
    categoria: 'Reguladores',
    diagrama: Diagrama.fila(
      ['1', '2', '3'],
      cuerpo: 'TO-220',
      vista: 'De frente, patas abajo',
    ),
    pines: const [
      Pin('1', 'ADJ', 'Ajuste'),
      Pin('2', 'OUT', 'Salida (unida a la aleta)'),
      Pin('3', 'IN', 'Entrada'),
    ],
    notas: const ['Vout = 1,25 × (1 + R2/R1). Usa la calculadora LM317.'],
    palabras: const ['lm317', 'regulador', 'ajustable'],
  ),
  Pinout(
    titulo: 'BC547 / BC548 / BC337 (NPN)',
    categoria: 'Transistores',
    diagrama: Diagrama.fila(
      ['C', 'B', 'E'],
      cuerpo: 'TO-92',
      vista: 'Cara plana de frente, patas abajo',
    ),
    pines: const [Pin('C', 'Colector'), Pin('B', 'Base'), Pin('E', 'Emisor')],
    notas: const ['Igual en los PNP BC557 / BC558 / BC327.', _avisoTransistor],
    palabras: const [
      'bc547',
      'bc548',
      'bc337',
      'bc557',
      'transistor',
      'npn',
      'pnp',
    ],
  ),
  Pinout(
    titulo: '2N2222A / 2N3904 / 2N3906',
    categoria: 'Transistores',
    diagrama: Diagrama.fila(
      ['E', 'B', 'C'],
      cuerpo: 'TO-92',
      vista: 'Cara plana de frente, patas abajo',
    ),
    pines: const [Pin('E', 'Emisor'), Pin('B', 'Base'), Pin('C', 'Colector')],
    notas: const [
      'El 2N3906 es PNP, los otros NPN.',
      'Algunos PN2222A vienen como C-B-E en la versión P2N2222A.',
      _avisoTransistor,
    ],
    palabras: const ['2n2222', '2n3904', '2n3906', 'transistor', 'npn', 'pnp'],
  ),
  Pinout(
    titulo: '2N7000 / BS170 (MOSFET N)',
    categoria: 'Transistores',
    diagrama: Diagrama.fila(
      ['S', 'G', 'D'],
      cuerpo: 'TO-92',
      vista: 'Cara plana de frente, patas abajo',
    ),
    pines: const [
      Pin('S', 'Fuente (Source)'),
      Pin('G', 'Puerta (Gate)'),
      Pin('D', 'Drenador (Drain)'),
    ],
    notas: const ['El BS170 es D-G-S (al revés).', _avisoTransistor],
    palabras: const ['2n7000', 'bs170', 'mosfet'],
  ),
  Pinout(
    titulo: 'TIP120 / TIP31 / TIP41 / TIP3055',
    categoria: 'Transistores',
    diagrama: Diagrama.fila(
      ['B', 'C', 'E'],
      cuerpo: 'TO-220',
      vista: 'De frente, patas abajo',
    ),
    pines: const [
      Pin('B', 'Base'),
      Pin('C', 'Colector (unido a la aleta)'),
      Pin('E', 'Emisor'),
    ],
    notas: const ['TIP120 es Darlington NPN; TIP125 su PNP.', _avisoTransistor],
    palabras: const [
      'tip120',
      'tip31',
      'tip41',
      'tip122',
      'darlington',
      'transistor',
      'potencia',
    ],
  ),
  Pinout(
    titulo: 'IRF540N / IRFZ44N / IRF3205 (MOSFET N)',
    categoria: 'Transistores',
    diagrama: Diagrama.fila(
      ['G', 'D', 'S'],
      cuerpo: 'TO-220',
      vista: 'De frente, patas abajo',
    ),
    pines: const [
      Pin('G', 'Puerta (Gate)'),
      Pin('D', 'Drenador (unido a la aleta)'),
      Pin('S', 'Fuente (Source)'),
    ],
    notas: const [
      'Con 5 V de Arduino no conducen del todo: usa un MOSFET "logic level" (IRLZ44N, IRL540N).',
      _avisoTransistor,
    ],
    palabras: const ['irf540', 'irfz44', 'irf3205', 'irlz44', 'mosfet'],
  ),
  Pinout(
    titulo: 'BD139 / BD140',
    categoria: 'Transistores',
    diagrama: Diagrama.fila(
      ['E', 'C', 'B'],
      cuerpo: 'TO-126',
      vista: 'Cara con texto de frente, patas abajo',
    ),
    pines: const [Pin('E', 'Emisor'), Pin('C', 'Colector'), Pin('B', 'Base')],
    notas: const ['BD139 NPN, BD140 PNP.', _avisoTransistor],
    palabras: const ['bd139', 'bd140', 'transistor'],
  ),
  Pinout(
    titulo: 'LM35 sensor de temperatura',
    categoria: 'Sensores',
    diagrama: Diagrama.fila(
      ['1', '2', '3'],
      cuerpo: 'TO-92',
      vista: 'Cara plana de frente, patas abajo',
    ),
    pines: const [
      Pin('1', '+VS', '4–30 V'),
      Pin('2', 'VOUT', '10 mV/°C (0 °C = 0 V)'),
      Pin('3', 'GND', ''),
    ],
    palabras: const ['lm35', 'temperatura', 'sensor'],
  ),
  Pinout(
    titulo: 'DS18B20 sensor de temperatura',
    categoria: 'Sensores',
    diagrama: Diagrama.fila(
      ['1', '2', '3'],
      cuerpo: 'TO-92',
      vista: 'Cara plana de frente, patas abajo',
    ),
    pines: const [
      Pin('1', 'GND', '', cNegro),
      Pin('2', 'DQ', 'Datos 1-Wire (4,7 kΩ a VDD)', cAmarillo),
      Pin('3', 'VDD', '3–5,5 V', cRojo),
    ],
    notas: const ['Versión con cable: rojo VDD, negro GND, amarillo datos.'],
    palabras: const ['ds18b20', 'temperatura', '1-wire', 'onewire', 'sensor'],
  ),
  Pinout(
    titulo: 'LED, diodo y condensador electrolítico',
    categoria: 'Componentes básicos',
    descripcion: 'Cómo reconocer la polaridad.',
    pines: const [
      Pin('LED +', 'Ánodo', 'Pata más larga'),
      Pin(
        'LED −',
        'Cátodo',
        'Pata corta, lado plano de la cápsula, pieza grande dentro',
      ),
      Pin('Diodo −', 'Cátodo', 'Lado de la banda pintada'),
      Pin('Diodo +', 'Ánodo', 'Lado sin banda'),
      Pin('Electrolítico −', 'Negativo', 'Franja con signos − y pata corta'),
      Pin('Tántalo +', 'Positivo', 'La franja marca el POSITIVO'),
      Pin('LED RGB', 'Pata más larga', 'Común (ánodo o cátodo según modelo)'),
    ],
    palabras: const [
      'led',
      'diodo',
      'polaridad',
      'catodo',
      'anodo',
      'electrolitico',
      'condensador',
    ],
  ),
];
