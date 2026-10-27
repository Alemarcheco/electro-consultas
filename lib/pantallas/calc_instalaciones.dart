import 'dart:math';

import 'package:flutter/material.dart';

import '../formato.dart';
import '../widgets.dart';
import 'calc_basicos.dart';

/// Secciones normalizadas de cable en mm².
const seccionesCable = [
  0.5, 0.75, 1.0, 1.5, 2.5, 4.0, 6.0, 10.0, 16.0, 25.0, 35.0, 50.0, 70.0, //
  95.0, 120.0, 150.0, 185.0, 240.0, 300.0,
];

/// Conductividad (m / Ω·mm²) según material y temperatura del conductor.
const conductividades = {
  ('Cobre', 20): 56.0,
  ('Cobre', 70): 48.0,
  ('Cobre', 90): 44.0,
  ('Aluminio', 20): 35.0,
  ('Aluminio', 70): 30.0,
  ('Aluminio', 90): 28.0,
};

/// Caída de tensión en voltios.
double caidaTension({
  required Sistema sistema,
  required double longitud,
  required double corriente,
  required double seccion,
  required double conductividad,
  double cosPhi = 1,
}) {
  final k = sistema == Sistema.trifasica ? sqrt(3) : 2.0;
  final c = sistema == Sistema.continua ? 1.0 : cosPhi;
  return k * longitud * corriente * c / (conductividad * seccion);
}

class CaidaTension extends StatefulWidget {
  const CaidaTension({super.key});
  @override
  State<CaidaTension> createState() => _CaidaTensionState();
}

class _CaidaTensionState extends EstadoCalculo<CaidaTension> {
  late final _sistema = reg(Modo(Sistema.monofasica));
  late final _v = val(uVoltios, i: 1, ini: '230');
  late final _i = val(uAmperios, i: 2, ini: '16');
  late final _l = simple('m', ini: '25');
  late final _cos = simple('cos φ', ini: '1');
  late final _max = simple('%', ini: '3');
  late final _seccion = reg(Modo(2.5));
  late final _material = reg(Modo('Cobre'));
  late final _temp = reg(Modo(70));

  @override
  Widget build(BuildContext context) {
    final s = _sistema.value;
    final v = _v.v, i = _i.v, l = _l.v, max = _max.v;
    final cos = s == Sistema.continua ? 1.0 : _cos.v;
    final gamma = conductividades[(_material.value, _temp.value)]!;
    Widget res;
    if (v == null || i == null || l == null || cos == null || v <= 0) {
      res = const Aviso('Completa los datos.');
    } else {
      final dv = caidaTension(
        sistema: s,
        longitud: l,
        corriente: i,
        seccion: _seccion.value,
        conductividad: gamma,
        cosPhi: cos,
      );
      final rLinea = l / (gamma * _seccion.value);
      final perdidas = (s == Sistema.trifasica ? 3 : 2) * i * i * rLinea;
      double? sMin;
      double? sNorm;
      if (max != null && max > 0) {
        sMin =
            caidaTension(
              sistema: s,
              longitud: l,
              corriente: i,
              seccion: 1,
              conductividad: gamma,
              cosPhi: cos,
            ) /
            (v * max / 100);
        sNorm = seccionesCable.firstWhere(
          (x) => x >= sMin! - 1e-9,
          orElse: () => double.nan,
        );
      }
      final pct = 100 * dv / v;
      res = Resultados(
        [
          ('Caída de tensión', ing(dv, 'V')),
          ('Caída en %', '${fmt(pct)} %'),
          ('Tensión al final', ing(v - dv, 'V')),
          ('Pérdidas en el cable', ing(perdidas, 'W')),
          if (sMin != null)
            ('Sección mínima (≤ ${fmt(max!)} %)', '${fmt(sMin)} mm²'),
          if (sNorm != null)
            (
              'Sección comercial',
              sNorm.isNaN ? '> 300 mm²' : '${fmt(sNorm)} mm²',
            ),
        ],
        nota:
            'Comprueba también que la sección aguanta la corriente (tabla de intensidades admisibles). '
            'Límites habituales: 3 % alumbrado, 5 % otros usos.',
      );
    }
    return PantallaCalculo(
      titulo: 'Caída de tensión',
      formulas: const [
        'Monofásica / continua: ΔV = 2 × L × I × cos φ / (γ × S)',
        'Trifásica: ΔV = √3 × L × I × cos φ / (γ × S)',
        'L = longitud del cable (solo ida), S en mm²',
        'γ cobre: 56 (20 °C) · 48 (70 °C) · 44 (90 °C)',
        'γ aluminio: 35 (20 °C) · 30 (70 °C) · 28 (90 °C)',
      ],
      children: [
        SelectorModo(
          valor: s,
          opciones: const [
            (Sistema.continua, 'Continua'),
            (Sistema.monofasica, 'Monofásica'),
            (Sistema.trifasica, 'Trifásica'),
          ],
          alCambiar: (x) => _sistema.value = x,
        ),
        CampoValor(
          _v,
          s == Sistema.trifasica ? 'Tensión entre fases' : 'Tensión',
        ),
        CampoValor(_i, 'Corriente'),
        CampoValor(_l, 'Longitud del cable (ida)'),
        if (s != Sistema.continua) CampoValor(_cos, 'Factor de potencia'),
        Row(
          children: [
            Expanded(
              child: Desplegable<double>(
                etiqueta: 'Sección',
                valor: _seccion.value,
                opciones: [
                  for (final x in seccionesCable) (x, '${fmt(x)} mm²'),
                ],
                alCambiar: (x) => _seccion.value = x,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Desplegable<String>(
                etiqueta: 'Material',
                valor: _material.value,
                opciones: const [('Cobre', 'Cobre'), ('Aluminio', 'Aluminio')],
                alCambiar: (x) => _material.value = x,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Desplegable<int>(
          etiqueta: 'Temperatura del conductor',
          valor: _temp.value,
          opciones: const [
            (20, '20 °C (sin carga)'),
            (70, '70 °C (aislamiento PVC)'),
            (90, '90 °C (XLPE / EPR)'),
          ],
          alCambiar: (x) => _temp.value = x,
        ),
        const SizedBox(height: 12),
        CampoValor(_max, 'Caída máxima admitida'),
        res,
      ],
    );
  }
}

// ───────────────────────── Consumo y coste ─────────────────────────

class ConsumoElectrico extends StatefulWidget {
  const ConsumoElectrico({super.key});
  @override
  State<ConsumoElectrico> createState() => _ConsumoElectricoState();
}

class _ConsumoElectricoState extends EstadoCalculo<ConsumoElectrico> {
  late final _p = val(uVatios, i: 1, ini: '1000');
  late final _h = simple('h/día', ini: '2');
  late final _d = simple('días', ini: '30');
  late final _precio = simple('por kWh', ini: '0,15');

  @override
  Widget build(BuildContext context) {
    final p = _p.v, h = _h.v, d = _d.v, precio = _precio.v;
    Widget res;
    if (p == null || h == null || d == null) {
      res = const Aviso('Completa los datos.');
    } else {
      final kwhDia = p * h / 1000;
      res = Resultados([
        ('Energía al día', '${fmt(kwhDia)} kWh'),
        ('Energía en el periodo', '${fmt(kwhDia * d)} kWh'),
        if (precio != null) ...[
          ('Coste al día', fmt(kwhDia * precio, cifras: 3)),
          ('Coste en el periodo', fmt(kwhDia * d * precio, cifras: 4)),
          ('Coste al año', fmt(kwhDia * 365 * precio, cifras: 4)),
        ],
      ]);
    }
    return PantallaCalculo(
      titulo: 'Consumo y coste',
      formulas: const [
        'Energía (kWh) = Potencia (W) × horas / 1000',
        'Coste = kWh × precio del kWh',
      ],
      children: [
        CampoValor(_p, 'Potencia del aparato'),
        CampoValor(_h, 'Horas de uso al día'),
        CampoValor(_d, 'Días'),
        CampoValor(_precio, 'Precio del kWh (en tu moneda)'),
        res,
      ],
    );
  }
}

// ───────────────────────── Batería ─────────────────────────

class DuracionBateria extends StatefulWidget {
  const DuracionBateria({super.key});
  @override
  State<DuracionBateria> createState() => _DuracionBateriaState();
}

class _DuracionBateriaState extends EstadoCalculo<DuracionBateria> {
  late final _cap = simple('mAh', ini: '2000');
  late final _consumo = val(uAmperios, i: 1, ini: '100');
  late final _ef = simple('%', ini: '80');

  String _duracion(double horas) {
    if (horas < 1) return '${fmt(horas * 60)} min';
    if (horas < 48) return '${fmt(horas)} h';
    return '${fmt(horas / 24)} días';
  }

  @override
  Widget build(BuildContext context) {
    final cap = _cap.v, i = _consumo.v, ef = _ef.v;
    Widget res;
    if (cap == null || i == null || i <= 0 || ef == null) {
      res = const Aviso('Completa los datos.');
    } else {
      final h = cap / 1000 / i * ef / 100;
      res = Resultados([
        ('Duración estimada', _duracion(h)),
        ('Tasa de descarga', '${fmt(i / (cap / 1000))} C'),
      ]);
    }
    return PantallaCalculo(
      titulo: 'Duración de batería',
      formulas: const [
        'Horas = Capacidad (Ah) / Consumo (A) × eficiencia',
        'Eficiencia: 70–90 % según química, temperatura y corte por tensión.',
        'C = consumo / capacidad (1 C = se descarga en 1 hora)',
      ],
      children: [
        CampoValor(_cap, 'Capacidad de la batería'),
        CampoValor(_consumo, 'Consumo medio'),
        CampoValor(_ef, 'Eficiencia / capacidad útil'),
        res,
      ],
    );
  }
}

// ───────────────────────── AWG ─────────────────────────

/// Diámetro en mm de un calibre AWG (0000 = −3).
double diametroAwg(int n) => 0.127 * pow(92, (36 - n) / 39);
double seccionAwg(int n) => pi / 4 * pow(diametroAwg(n), 2);

String nombreAwg(int n) => n >= 0 ? '$n' : '${'0' * (1 - n)} (${1 - n}/0)';

class ConversorAwg extends StatefulWidget {
  const ConversorAwg({super.key});
  @override
  State<ConversorAwg> createState() => _ConversorAwgState();
}

class _ConversorAwgState extends EstadoCalculo<ConversorAwg> {
  late final _awg = reg(Modo(14));
  late final _mm2 = simple('mm²', ini: '2,5');

  @override
  Widget build(BuildContext context) {
    final n = _awg.value;
    final s = seccionAwg(n);
    final mm2 = _mm2.v;
    int? cercano;
    if (mm2 != null && mm2 > 0) {
      cercano = [for (var k = -3; k <= 40; k++) k].reduce(
        (a, b) =>
            (log(seccionAwg(a) / mm2)).abs() < (log(seccionAwg(b) / mm2)).abs()
            ? a
            : b,
      );
    }
    return PantallaCalculo(
      titulo: 'Calibre AWG',
      formulas: const [
        'd (mm) = 0,127 × 92^((36 − AWG) / 39)',
        'S = π/4 × d²',
        'Cada 3 AWG menos ≈ doble de sección.',
      ],
      children: [
        DropdownButtonFormField<int>(
          initialValue: n,
          decoration: const InputDecoration(
            labelText: 'Calibre AWG',
            border: OutlineInputBorder(),
          ),
          items: [
            for (var k = -3; k <= 40; k++)
              DropdownMenuItem(value: k, child: Text('AWG ${nombreAwg(k)}')),
          ],
          onChanged: (k) => _awg.value = k!,
        ),
        const SizedBox(height: 12),
        Resultados([
          ('Diámetro', '${fmt(diametroAwg(n))} mm'),
          ('Sección', '${fmt(s)} mm²'),
          ('Resistencia (cobre)', '${fmt(17.24 / s)} Ω/km'),
        ]),
        const Divider(height: 32),
        const Titulo('De mm² a AWG'),
        CampoValor(_mm2, 'Sección'),
        if (cercano != null)
          Resultados([
            ('AWG más cercano', nombreAwg(cercano)),
            ('Su sección', '${fmt(seccionAwg(cercano))} mm²'),
          ]),
      ],
    );
  }
}
