import '../datos/referencias.dart';
import '../formato.dart';
import 'equipos.dart';

const _marcas = 'Equipos por marca';
const _guias = 'Guías';
const _aviso =
    'Datos orientativos: comprueba siempre la ficha técnica del modelo exacto.';

final tablasSolares = <Tabla>[
  Tabla(
    titulo: 'Paneles solares',
    categoria: _marcas,
    columnas: const ['Panel', 'W', 'Voc', 'Vmp', 'Isc', 'Imp'],
    filas: [
      for (final p in paneles)
        [
          p.nombre,
          fmt(p.w),
          '${fmt(p.voc)} V',
          '${fmt(p.vmp)} V',
          '${fmt(p.isc)} A',
          '${fmt(p.imp)} A',
        ],
    ],
    notas: const [
      'Voc: tensión en circuito abierto (sube con el frío). Vmp: tensión de trabajo. Isc: corriente de cortocircuito.',
      'Otras marcas habituales: Risen, Astronergy, DAH Solar, Sunova, Renogy (paneles pequeños de 12 V).',
      _aviso,
    ],
    palabras: const [
      'panel',
      'placa',
      'modulo',
      'jinko',
      'longi',
      'canadian',
      'trina',
      'ja solar',
      'solar',
    ],
  ),
  Tabla(
    titulo: 'Baterías para solar',
    categoria: _marcas,
    columnas: const ['Batería', 'Tipo', 'Energía', 'Descarga', 'Ciclos'],
    filas: [
      for (final b in baterias)
        [
          b.nombre,
          nombreQuimica(b.quimica),
          '${fmt(b.kwh, cifras: 3)} kWh',
          '${(b.dod * 100).round()} %',
          '≈ ${b.ciclos}',
        ],
    ],
    notas: const [
      'Litio LiFePO4: más cara al principio pero dura 3–8 veces más y se puede descargar casi entera.',
      'Plomo (abierta, AGM, gel): no bajes del 50 % o se estropea pronto.',
      'Otras marcas: BYD, Dyness, Felicity, Growatt ARK, Deye, Hoppecke, Rolls, Victron.',
      _aviso,
    ],
    palabras: const [
      'bateria',
      'litio',
      'lifepo4',
      'pylontech',
      'trojan',
      'agm',
      'gel',
      'solar',
    ],
  ),
  Tabla(
    titulo: 'Reguladores de carga',
    categoria: _marcas,
    columnas: const ['Regulador', 'Tipo', 'FV máx.', 'Corriente', 'Baterías'],
    filas: [
      for (final r in reguladores)
        [
          r.nombre,
          r.tipo == TipoRegulador.pwm ? 'PWM' : 'MPPT',
          '${fmt(r.vMaxPv)} V',
          '${fmt(r.amperios)} A',
          r.tensiones.map((v) => '$v V').join(' / '),
        ],
    ],
    notas: const [
      'Victron: el nombre indica tensión FV máxima / corriente (100/30 = 100 V y 30 A).',
      'MPPT aprovecha un 20–30 % más que PWM y admite paneles grandes en serie.',
      _aviso,
    ],
    palabras: const [
      'regulador',
      'controlador',
      'mppt',
      'pwm',
      'victron',
      'epever',
      'renogy',
      'solar',
    ],
  ),
  Tabla(
    titulo: 'Inversores para sistemas aislados',
    categoria: _marcas,
    columnas: const [
      'Inversor',
      'Batería',
      'Continua',
      'Pico',
      'MPPT integrado',
    ],
    filas: [
      for (final i in inversores)
        [
          i.nombre,
          '${i.vBateria} V',
          ing(i.w, 'W'),
          ing(i.wPico, 'W'),
          i.hibrido
              ? '${fmt(i.mpptAmperios!)} A · ${fmt(i.mpptVmax!)} V · ${fmt(i.mpptW!)} W'
              : 'No',
        ],
    ],
    notas: const [
      'Usa siempre inversores de onda senoidal pura para motores, neveras y electrónica.',
      'Los híbridos (todo en uno) traen regulador MPPT y cargador desde la red o un generador.',
      _aviso,
    ],
    palabras: const [
      'inversor',
      'growatt',
      'victron',
      'deye',
      'hibrido',
      'multiplus',
      'solar',
    ],
  ),
  Tabla(
    titulo: 'Inversores de conexión a red',
    categoria: _marcas,
    columnas: const ['Inversor', 'Potencia', 'Red'],
    filas: [
      for (final i in inversoresRed) [i.nombre, '${fmt(i.kw)} kW', i.fases],
    ],
    notas: const ['Sin baterías no dan luz durante un apagón.', _aviso],
    palabras: const [
      'inversor',
      'red',
      'autoconsumo',
      'huawei',
      'fronius',
      'sma',
      'growatt',
      'solar',
    ],
  ),
  Tabla(
    titulo: 'Horas sol pico por ciudad',
    categoria: _guias,
    descripcion: 'Media anual aproximada sobre superficie inclinada óptima.',
    columnas: const ['Ciudad', 'HSP'],
    filas: [
      for (final (c, h) in horasSolPico) [c, fmt(h)],
    ],
    notas: const [
      'En el peor mes pueden ser un 20–40 % menores. Para tu ubicación exacta consulta PVGIS o Global Solar Atlas.',
    ],
    palabras: const ['hsp', 'radiacion', 'sol', 'irradiacion', 'solar'],
  ),
  Tabla(
    titulo: 'Consumo de aparatos típicos',
    categoria: _guias,
    columnas: const ['Aparato', 'Potencia', 'Uso típico', 'Energía al día'],
    filas: [
      for (final a in aparatosTipicos)
        [
          a.nombre,
          '${fmt(a.w)} W',
          '${fmt(a.horas)} h',
          '${fmt(a.w * a.horas)} Wh',
        ],
    ],
    notas: const [
      'Mira la etiqueta del aparato o mídelo con un medidor de enchufe para más precisión.',
    ],
    palabras: const [
      'consumo',
      'aparatos',
      'electrodomesticos',
      'nevera',
      'aire',
      'solar',
    ],
  ),
  const Tabla(
    titulo: 'Conceptos de energía solar',
    categoria: _guias,
    columnas: ['Concepto', 'Qué es'],
    filas: [
      [
        'HSP',
        'Horas sol pico: horas equivalentes de sol a 1000 W/m². Un panel de 400 W da ≈ 400 × HSP × 0,8 Wh al día.',
      ],
      [
        'Wp / kWp',
        'Potencia pico del panel en condiciones de laboratorio (STC).',
      ],
      [
        'Voc',
        'Tensión del panel sin carga. Con frío sube: no debe superar la del regulador.',
      ],
      ['Vmp / Imp', 'Tensión y corriente en el punto de máxima potencia.'],
      [
        'Serie',
        'Suma tensiones (misma corriente). Se usa con MPPT para menos pérdidas.',
      ],
      [
        'Paralelo',
        'Suma corrientes (misma tensión). Con más de 2 ramas pon fusibles por rama.',
      ],
      [
        'PWM',
        'Regulador simple: conecta el panel a la batería. Solo con paneles de 12 V nominales.',
      ],
      [
        'MPPT',
        'Regulador que convierte la tensión alta de los paneles en corriente de carga. Rinde más.',
      ],
      [
        'DoD',
        'Profundidad de descarga: cuánto se vacía la batería en cada ciclo.',
      ],
      ['Autonomía', 'Días que el banco de baterías aguanta sin sol.'],
      [
        'Aislado (off-grid)',
        'Sin red: paneles + regulador + baterías + inversor.',
      ],
      [
        'Conectado a red',
        'Paneles + inversor de red; reduce la factura pero no da luz en apagones.',
      ],
      [
        'Híbrido',
        'Usa paneles, baterías y red a la vez; da respaldo en los apagones.',
      ],
      [
        'Orientación',
        'Hemisferio norte: paneles mirando al sur; sur: mirando al norte. Inclinación ≈ latitud.',
      ],
    ],
    palabras: [
      'solar',
      'fotovoltaica',
      'hsp',
      'mppt',
      'pwm',
      'off-grid',
      'conceptos',
    ],
  ),
  const Tabla(
    titulo: 'Cables y protecciones en solar',
    categoria: _guias,
    columnas: ['Tramo', 'Recomendación'],
    filas: [
      [
        'Paneles → regulador',
        'Cable solar de 4 o 6 mm² (PV1-F), conectores MC4. Caída < 3 %.',
      ],
      [
        'Regulador → baterías',
        'Sección según corriente: 30 A → 6 mm² · 60 A → 16 mm² · 100 A → 25–35 mm²',
      ],
      [
        'Baterías → inversor',
        'Corriente = W / V. 3000 W a 24 V ≈ 140 A → 35–50 mm², cable lo más corto posible.',
      ],
      [
        'Fusible de batería',
        'Junto al positivo de la batería, ≈ 1,25 × corriente máxima del inversor.',
      ],
      [
        'Strings en paralelo',
        'Fusible por rama si hay 3 o más ramas (≈ 1,5 × Isc).',
      ],
      [
        'Lado FV en continua',
        'Seccionador de CC y protección contra sobretensiones (DPS/SPD).',
      ],
      [
        'Salida de CA',
        'Magnetotérmico y diferencial de 30 mA, como cualquier instalación.',
      ],
      ['Tierra', 'Une estructuras de paneles y carcasas a tierra.'],
    ],
    notas: [
      'Calcula la caída exacta con la calculadora «Caída de tensión» (modo continua).',
    ],
    palabras: ['cable', 'fusible', 'mc4', 'proteccion', 'solar'],
  ),
];
