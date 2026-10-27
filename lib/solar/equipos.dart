/// Catálogo orientativo de equipos solares por marca. Los datos son típicos
/// de cada modelo; compruébalos siempre en la ficha técnica del fabricante.
library;

class Panel {
  final String id;
  final String marca;
  final String modelo;
  final double w;
  final double voc;
  final double vmp;
  final double isc;
  final double imp;

  const Panel(
    this.id,
    this.marca,
    this.modelo,
    this.w,
    this.voc,
    this.vmp,
    this.isc,
    this.imp,
  );

  String get nombre => '$marca $modelo';

  /// Panel de "12 V nominales" (36 células), el único que sirve con PWM.
  bool get de12V => vmp >= 16 && vmp <= 21;
}

enum Quimica { plomoAbierto, agm, gel, litio }

String nombreQuimica(Quimica q) => switch (q) {
  Quimica.plomoAbierto => 'Plomo-ácido abierta',
  Quimica.agm => 'AGM',
  Quimica.gel => 'Gel',
  Quimica.litio => 'Litio LiFePO4',
};

class Bateria {
  final String id;
  final String marca;
  final String modelo;
  final Quimica quimica;

  /// Tensión del sistema a la que equivale (6, 12, 24 o 48 V).
  final int vNominal;
  final double vReal;
  final double ah;

  /// Profundidad de descarga recomendada (0–1).
  final double dod;
  final int ciclos;

  const Bateria(
    this.id,
    this.marca,
    this.modelo,
    this.quimica,
    this.vNominal,
    this.vReal,
    this.ah,
    this.dod,
    this.ciclos,
  );

  String get nombre => '$marca $modelo';
  double get kwh => vReal * ah / 1000;
}

enum TipoRegulador { pwm, mppt }

class Regulador {
  final String id;
  final String marca;
  final String modelo;
  final TipoRegulador tipo;
  final double vMaxPv;
  final double amperios;
  final List<int> tensiones;

  const Regulador(
    this.id,
    this.marca,
    this.modelo,
    this.tipo,
    this.vMaxPv,
    this.amperios,
    this.tensiones,
  );

  String get nombre => '$marca $modelo';
}

class Inversor {
  final String id;
  final String marca;
  final String modelo;
  final int vBateria;
  final double w;
  final double wPico;

  /// Regulador MPPT integrado (inversor híbrido / todo en uno).
  final double? mpptAmperios;
  final double? mpptVmax;
  final double? mpptW;
  final bool conRed;
  final String nota;

  const Inversor(
    this.id,
    this.marca,
    this.modelo,
    this.vBateria,
    this.w,
    this.wPico, {
    this.mpptAmperios,
    this.mpptVmax,
    this.mpptW,
    this.conRed = false,
    this.nota = '',
  });

  String get nombre => '$marca $modelo';
  bool get hibrido => mpptAmperios != null;
}

/// Inversor de conexión a red (sin baterías) para autoconsumo.
class InversorRed {
  final String marca;
  final String modelo;
  final double kw;
  final String fases;
  const InversorRed(this.marca, this.modelo, this.kw, this.fases);
  String get nombre => '$marca $modelo';
}

const paneles = <Panel>[
  Panel(
    'gen100',
    'Genérico',
    '100 W 12 V (36 células)',
    100,
    22.5,
    18.5,
    5.9,
    5.4,
  ),
  Panel(
    'gen200',
    'Genérico',
    '200 W 12 V (36 células)',
    200,
    24.3,
    20.3,
    10.6,
    9.85,
  ),
  Panel(
    'cs410',
    'Canadian Solar',
    'HiKu6 CS6R-410MS',
    410,
    37.4,
    31.2,
    13.9,
    13.1,
  ),
  Panel('ja415', 'JA Solar', 'JAM54S30-415/MR', 415, 37.3, 31.3, 14.0, 13.3),
  Panel(
    'longi430',
    'LONGi',
    'Hi-MO 6 LR5-54HTH-430M',
    430,
    38.6,
    32.3,
    14.0,
    13.3,
  ),
  Panel(
    'trina550',
    'Trina Solar',
    'Vertex TSM-DE19R 550 W',
    550,
    38.1,
    31.8,
    18.4,
    17.3,
  ),
  Panel(
    'jinko580',
    'Jinko Solar',
    'Tiger Neo JKM580N-72HL4',
    580,
    51.3,
    42.4,
    14.4,
    13.7,
  ),
  Panel(
    'cs665',
    'Canadian Solar',
    'HiKu7 CS7N-665MS',
    665,
    45.6,
    38.5,
    18.5,
    17.3,
  ),
];

const baterias = <Bateria>[
  Bateria(
    't105',
    'Trojan',
    'T-105 (6 V 225 Ah)',
    Quimica.plomoAbierto,
    6,
    6,
    225,
    0.5,
    1200,
  ),
  Bateria(
    'ritar100',
    'Ritar',
    'DC12-100 AGM (12 V 100 Ah)',
    Quimica.agm,
    12,
    12,
    100,
    0.5,
    500,
  ),
  Bateria(
    'ultra100',
    'Ultracell',
    'UCG100-12 Gel (12 V 100 Ah)',
    Quimica.gel,
    12,
    12,
    100,
    0.5,
    800,
  ),
  Bateria(
    'lfp12_100',
    'Genérica',
    'LiFePO4 12,8 V 100 Ah',
    Quimica.litio,
    12,
    12.8,
    100,
    0.9,
    4000,
  ),
  Bateria(
    'lfp12_200',
    'Genérica',
    'LiFePO4 12,8 V 200 Ah',
    Quimica.litio,
    12,
    12.8,
    200,
    0.9,
    4000,
  ),
  Bateria(
    'victron200',
    'Victron',
    'LiFePO4 Smart 12,8 V 200 Ah',
    Quimica.litio,
    12,
    12.8,
    200,
    0.9,
    2500,
  ),
  Bateria(
    'lfp24_100',
    'Genérica',
    'LiFePO4 25,6 V 100 Ah',
    Quimica.litio,
    24,
    25.6,
    100,
    0.9,
    4000,
  ),
  Bateria(
    'us3000',
    'Pylontech',
    'US3000C (48 V 74 Ah)',
    Quimica.litio,
    48,
    48,
    74,
    0.95,
    6000,
  ),
  Bateria(
    'us5000',
    'Pylontech',
    'US5000 (48 V 100 Ah)',
    Quimica.litio,
    48,
    48,
    100,
    0.95,
    6000,
  ),
  Bateria(
    'rack100',
    'Genérica de rack',
    'LiFePO4 51,2 V 100 Ah',
    Quimica.litio,
    48,
    51.2,
    100,
    0.9,
    6000,
  ),
];

const reguladores = <Regulador>[
  Regulador('pwm30', 'Genérico', 'PWM 30 A', TipoRegulador.pwm, 50, 30, [
    12,
    24,
  ]),
  Regulador('ep3210', 'EPEver', 'Tracer 3210AN', TipoRegulador.mppt, 100, 30, [
    12,
    24,
  ]),
  Regulador('ep4215', 'EPEver', 'Tracer 4215BN', TipoRegulador.mppt, 150, 40, [
    12,
    24,
  ]),
  Regulador('rover40', 'Renogy', 'Rover 40 A', TipoRegulador.mppt, 100, 40, [
    12,
    24,
    48,
  ]),
  Regulador(
    'v7515',
    'Victron',
    'SmartSolar MPPT 75/15',
    TipoRegulador.mppt,
    75,
    15,
    [12, 24],
  ),
  Regulador(
    'v10030',
    'Victron',
    'SmartSolar MPPT 100/30',
    TipoRegulador.mppt,
    100,
    30,
    [12, 24],
  ),
  Regulador(
    'v10050',
    'Victron',
    'SmartSolar MPPT 100/50',
    TipoRegulador.mppt,
    100,
    50,
    [12, 24],
  ),
  Regulador(
    'v15035',
    'Victron',
    'SmartSolar MPPT 150/35',
    TipoRegulador.mppt,
    150,
    35,
    [12, 24, 48],
  ),
  Regulador(
    'v15060',
    'Victron',
    'SmartSolar MPPT 150/60',
    TipoRegulador.mppt,
    150,
    60,
    [12, 24, 48],
  ),
  Regulador(
    'v250100',
    'Victron',
    'SmartSolar MPPT 250/100',
    TipoRegulador.mppt,
    250,
    100,
    [12, 24, 48],
  ),
];

const inversores = <Inversor>[
  Inversor('ph12800', 'Victron', 'Phoenix 12/800', 12, 650, 1600),
  Inversor('ph241200', 'Victron', 'Phoenix 24/1200', 24, 1000, 2200),
  Inversor(
    'mp121600',
    'Victron',
    'MultiPlus 12/1600/70',
    12,
    1300,
    3000,
    nota: 'Con cargador desde red o generador',
  ),
  Inversor(
    'mp2_48_5000',
    'Victron',
    'MultiPlus-II 48/5000/70',
    48,
    4000,
    9000,
    nota: 'Con cargador; usa regulador MPPT aparte',
  ),
  Inversor(
    'gen3k24',
    'Genérico (Voltronic, EASun, Must…)',
    'Híbrido 3 kW 24 V',
    24,
    3000,
    6000,
    mpptAmperios: 80,
    mpptVmax: 145,
    mpptW: 3000,
    nota: 'Comprueba la tensión FV máxima de tu modelo',
  ),
  Inversor(
    'spf3000',
    'Growatt',
    'SPF 3000TL LVM-24',
    24,
    3000,
    6000,
    mpptAmperios: 80,
    mpptVmax: 145,
    mpptW: 4000,
  ),
  Inversor(
    'spf5000',
    'Growatt',
    'SPF 5000 ES',
    48,
    5000,
    10000,
    mpptAmperios: 100,
    mpptVmax: 450,
    mpptW: 6000,
  ),
  Inversor(
    'deye5k',
    'Deye',
    'SUN-5K-SG04LP1',
    48,
    5000,
    10000,
    mpptAmperios: 120,
    mpptVmax: 500,
    mpptW: 6500,
    conRed: true,
    nota: 'Híbrido: trabaja con red y baterías',
  ),
];

const inversoresRed = <InversorRed>[
  InversorRed('Growatt', 'MIN 3000TL-X', 3, 'Monofásico'),
  InversorRed('Huawei', 'SUN2000-3KTL-L1', 3, 'Monofásico'),
  InversorRed('Growatt', 'MIN 5000TL-X', 5, 'Monofásico'),
  InversorRed('Huawei', 'SUN2000-5KTL-L1', 5, 'Monofásico'),
  InversorRed('Fronius', 'Primo 5.0-1', 5, 'Monofásico'),
  InversorRed('SMA', 'Sunny Boy 5.0', 5, 'Monofásico'),
  InversorRed('Huawei', 'SUN2000-8KTL-M1', 8, 'Trifásico'),
  InversorRed('Fronius', 'Symo 10.0-3-M', 10, 'Trifásico'),
];

/// Aparatos típicos con potencia y horas de uso orientativas.
class Aparato {
  final String nombre;
  final double w;
  final double horas;

  /// Multiplicador del pico de arranque (motores y compresores ≈ 3).
  final double arranque;
  const Aparato(this.nombre, this.w, this.horas, [this.arranque = 1]);
}

const aparatosTipicos = <Aparato>[
  Aparato('Bombillo LED', 10, 5),
  Aparato('Tubo LED', 18, 5),
  Aparato('Celular (carga)', 10, 2),
  Aparato('Router WiFi', 10, 24),
  Aparato('Laptop', 60, 4),
  Aparato('Televisor LED 32"', 50, 4),
  Aparato('Televisor LED 50"', 100, 4),
  Aparato('Ventilador', 60, 8, 2),
  Aparato('Refrigerador', 150, 8, 3),
  Aparato('Refrigerador inverter', 100, 10, 1.5),
  Aparato('Congelador', 200, 8, 3),
  Aparato('Nevera 12 V (camper)', 45, 12),
  Aparato('Aire acondicionado inverter 12 000 BTU', 900, 6, 1.5),
  Aparato('Aire acondicionado normal 12 000 BTU', 1200, 6, 3),
  Aparato('Bomba de agua 1 HP', 750, 1, 3),
  Aparato('Bomba de agua ½ HP', 370, 1, 3),
  Aparato('Lavadora', 500, 1, 3),
  Aparato('Microondas', 1200, 0.3),
  Aparato('Olla arrocera', 700, 0.7),
  Aparato('Hervidor eléctrico', 2000, 0.2),
  Aparato('Plancha', 1200, 0.3),
  Aparato('Computadora de mesa', 200, 4),
  Aparato('Equipo de música', 50, 3),
  Aparato('Radio', 10, 3),
  Aparato('Cámaras de seguridad (DVR)', 40, 24),
];

/// Horas sol pico (HSP) medias anuales aproximadas.
const horasSolPico = <(String, double)>[
  ('La Habana', 5.3),
  ('Santiago de Cuba', 5.5),
  ('Miami', 5.2),
  ('Ciudad de México', 5.5),
  ('Monterrey', 5.0),
  ('Santo Domingo', 5.3),
  ('San Juan (PR)', 5.4),
  ('Caracas', 5.2),
  ('Bogotá', 4.2),
  ('Medellín', 4.6),
  ('Quito', 4.8),
  ('Lima', 5.0),
  ('La Paz', 5.6),
  ('Santiago de Chile', 5.1),
  ('Buenos Aires', 4.6),
  ('Montevideo', 4.5),
  ('Madrid', 4.8),
  ('Sevilla', 5.2),
  ('Barcelona', 4.3),
];
