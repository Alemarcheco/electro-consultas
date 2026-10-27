import 'dart:math';

import 'package:flutter/material.dart';

import '../calc/codigos.dart';
import '../formato.dart';
import '../widgets.dart';
import 'calc_basicos.dart';

// ───────────────────────── 555 ─────────────────────────

class Temporizador555 extends StatefulWidget {
  const Temporizador555({super.key});
  @override
  State<Temporizador555> createState() => _Temporizador555State();
}

class _Temporizador555State extends EstadoCalculo<Temporizador555> {
  late final _modo = reg(Modo(0));
  late final _r1 = val(uOhmios, i: 1, ini: '1');
  late final _r2 = val(uOhmios, i: 1, ini: '10');
  late final _c = val(uFaradios, i: 2, ini: '10');

  @override
  Widget build(BuildContext context) {
    final r1 = _r1.v, r2 = _r2.v, c = _c.v;
    final astable = _modo.value == 0;
    Widget res;
    if (r1 == null || c == null || (astable && r2 == null)) {
      res = const Aviso('Completa los datos.');
    } else if (astable) {
      final th = 0.693 * (r1 + r2!) * c;
      final tl = 0.693 * r2 * c;
      final t = th + tl;
      res = Resultados(
        [
          ('Frecuencia', ing(1 / t, 'Hz')),
          ('Periodo', ing(t, 's')),
          ('Tiempo en alto', ing(th, 's')),
          ('Tiempo en bajo', ing(tl, 's')),
          ('Ciclo de trabajo', '${fmt(100 * th / t)} %'),
        ],
        nota: r1 < 1000
            ? 'R1 debería ser de al menos 1 kΩ para no forzar la descarga (pin 7).'
            : null,
      );
    } else {
      res = Resultados([('Duración del pulso', ing(1.1 * r1 * c, 's'))]);
    }
    return PantallaCalculo(
      titulo: 'Temporizador 555',
      formulas: astable
          ? const [
              'Alto: t₁ = 0,693 × (R1 + R2) × C',
              'Bajo: t₂ = 0,693 × R2 × C',
              'f = 1,44 / ((R1 + 2·R2) × C)',
              'R1 entre VCC y pin 7; R2 entre pin 7 y pines 6-2; C de 6-2 a GND.',
            ]
          : const [
              'T = 1,1 × R × C',
              'R entre VCC y pines 6-7; C de 6-7 a GND; disparo por pin 2.',
            ],
      children: [
        SelectorModo(
          valor: _modo.value,
          opciones: const [(0, 'Astable'), (1, 'Monoestable')],
          alCambiar: (v) => _modo.value = v,
        ),
        CampoValor(_r1, astable ? 'R1' : 'R'),
        if (astable) CampoValor(_r2, 'R2'),
        CampoValor(_c, 'C'),
        res,
      ],
    );
  }
}

// ───────────────────────── Filtro / constante de tiempo ─────────────────────────

class FiltroRC extends StatefulWidget {
  const FiltroRC({super.key});
  @override
  State<FiltroRC> createState() => _FiltroRCState();
}

class _FiltroRCState extends EstadoCalculo<FiltroRC> {
  late final _modo = reg(Modo(0));
  late final _r = val(uOhmios, i: 1, ini: '10');
  late final _c = val(uFaradios, i: 1, ini: '100');
  late final _l = val(uHenrios, i: 2, ini: '10');

  @override
  Widget build(BuildContext context) {
    final rc = _modo.value == 0;
    final r = _r.v, c = _c.v, l = _l.v;
    Widget res;
    if (r == null || r <= 0 || (rc ? c == null : l == null)) {
      res = const Aviso('Completa los datos.');
    } else {
      final tau = rc ? r * c! : l! / r;
      res = Resultados([
        ('Constante de tiempo τ', ing(tau, 's')),
        ('Frecuencia de corte', ing(1 / (2 * pi * tau), 'Hz')),
        ('Carga al 63 % (1τ)', ing(tau, 's')),
        ('Carga al 99 % (5τ)', ing(5 * tau, 's')),
      ]);
    }
    return PantallaCalculo(
      titulo: 'Filtro y constante RC / RL',
      formulas: rc
          ? const [
              'τ = R × C',
              'fc = 1 / (2π × R × C)',
              'Vc(t) = V × (1 − e^(−t/τ))',
            ]
          : const ['τ = L / R', 'fc = R / (2π × L)'],
      children: [
        SelectorModo(
          valor: _modo.value,
          opciones: const [(0, 'RC'), (1, 'RL')],
          alCambiar: (v) => _modo.value = v,
        ),
        CampoValor(_r, 'Resistencia'),
        if (rc) CampoValor(_c, 'Capacidad') else CampoValor(_l, 'Inductancia'),
        res,
      ],
    );
  }
}

// ───────────────────────── Reactancia y resonancia ─────────────────────────

class Reactancia extends StatefulWidget {
  const Reactancia({super.key});
  @override
  State<Reactancia> createState() => _ReactanciaState();
}

class _ReactanciaState extends EstadoCalculo<Reactancia> {
  late final _f = val(uHercios, ini: '50');
  late final _c = val(uFaradios, i: 2, ini: '10');
  late final _l = val(uHenrios, i: 2, ini: '100');

  @override
  Widget build(BuildContext context) {
    final f = _f.v, c = _c.v, l = _l.v;
    return PantallaCalculo(
      titulo: 'Reactancia y resonancia',
      formulas: const [
        'Xc = 1 / (2π × f × C)',
        'Xl = 2π × f × L',
        'f₀ = 1 / (2π × √(L × C))',
      ],
      children: [
        CampoValor(_f, 'Frecuencia'),
        CampoValor(_c, 'Capacidad'),
        CampoValor(_l, 'Inductancia'),
        Resultados([
          (
            'Reactancia capacitiva Xc',
            f != null && c != null && f * c > 0
                ? ing(1 / (2 * pi * f * c), 'Ω')
                : '—',
          ),
          (
            'Reactancia inductiva Xl',
            f != null && l != null ? ing(2 * pi * f * l, 'Ω') : '—',
          ),
          (
            'Resonancia LC f₀',
            l != null && c != null && l * c > 0
                ? ing(1 / (2 * pi * sqrt(l * c)), 'Hz')
                : '—',
          ),
        ]),
      ],
    );
  }
}

// ───────────────────────── LM317 ─────────────────────────

class Regulador317 extends StatefulWidget {
  const Regulador317({super.key});
  @override
  State<Regulador317> createState() => _Regulador317State();
}

class _Regulador317State extends EstadoCalculo<Regulador317> {
  late final _modo = reg(Modo(0));
  late final _r1 = val(uOhmios, ini: '240');
  late final _r2 = val(uOhmios, i: 1, ini: '2,2');
  late final _vout = val(uVoltios, i: 1, ini: '12');

  static const _vref = 1.25, _iadj = 50e-6;

  @override
  Widget build(BuildContext context) {
    final r1 = _r1.v, r2 = _r2.v, vout = _vout.v;
    Widget res;
    if (r1 == null || r1 <= 0) {
      res = const Aviso('Escribe R1 (normalmente 240 Ω).');
    } else if (_modo.value == 0) {
      res = r2 == null
          ? const Aviso('Escribe R2.')
          : Resultados([
              (
                'Tensión de salida',
                ing(_vref * (1 + r2 / r1) + _iadj * r2, 'V'),
              ),
              ('Entrada mínima', ing(_vref * (1 + r2 / r1) + 3, 'V')),
            ]);
    } else if (vout == null || vout < _vref) {
      res = const Aviso('La salida mínima del LM317 es 1,25 V.');
    } else {
      final r2 = (vout - _vref) / (_vref / r1 + _iadj);
      final n = valorNormalizado(r2, serieE24);
      res = Resultados([
        ('R2 exacta', ing(r2, 'Ω')),
        ('R2 comercial (E24)', ing(n, 'Ω')),
        ('Salida con R2 comercial', ing(_vref * (1 + n / r1) + _iadj * n, 'V')),
        ('Entrada mínima', ing(vout + 3, 'V')),
      ]);
    }
    return PantallaCalculo(
      titulo: 'Regulador LM317',
      formulas: const [
        'Vout = 1,25 × (1 + R2/R1) + Iadj × R2   (Iadj ≈ 50 µA)',
        'R1 entre OUT y ADJ; R2 entre ADJ y GND.',
        'Vin ≥ Vout + 3 V. Disipa (Vin − Vout) × I: usa disipador.',
        'Patillas (TO-220, de frente): ADJ · OUT · IN',
      ],
      children: [
        SelectorModo(
          valor: _modo.value,
          opciones: const [(0, 'Calcular Vout'), (1, 'Calcular R2')],
          alCambiar: (v) => _modo.value = v,
        ),
        CampoValor(_r1, 'R1'),
        if (_modo.value == 0)
          CampoValor(_r2, 'R2')
        else
          CampoValor(_vout, 'Salida deseada'),
        res,
      ],
    );
  }
}

// ───────────────────────── Amplificador operacional ─────────────────────────

class AmpOperacional extends StatefulWidget {
  const AmpOperacional({super.key});
  @override
  State<AmpOperacional> createState() => _AmpOperacionalState();
}

class _AmpOperacionalState extends EstadoCalculo<AmpOperacional> {
  late final _modo = reg(Modo(0));
  late final _rf = val(uOhmios, i: 1, ini: '100');
  late final _rin = val(uOhmios, i: 1, ini: '10');
  late final _vin = val(uVoltios, i: 0, ini: '100');

  @override
  Widget build(BuildContext context) {
    final rf = _rf.v, rin = _rin.v, vin = _vin.v;
    final inversor = _modo.value == 0;
    Widget res;
    if (rf == null || rin == null || rin == 0) {
      res = const Aviso('Escribe Rf y R.');
    } else {
      final g = inversor ? -rf / rin : 1 + rf / rin;
      res = Resultados([
        ('Ganancia', fmt(g)),
        ('Ganancia en dB', '${fmt(20 * log(g.abs()) / ln10)} dB'),
        if (vin != null) ('Salida', ing(g * vin, 'V')),
        if (inversor) ('Impedancia de entrada', ing(rin, 'Ω')),
      ], nota: 'La salida no puede superar la alimentación del operacional.');
    }
    return PantallaCalculo(
      titulo: 'Amplificador operacional',
      formulas: inversor
          ? const [
              'G = −Rf / Rin',
              'Entrada por Rin a la patilla (−); (+) a masa.',
            ]
          : const [
              'G = 1 + Rf / Rg',
              'Entrada por (+); Rg de (−) a masa; Rf de salida a (−).',
            ],
      children: [
        SelectorModo(
          valor: _modo.value,
          opciones: const [(0, 'Inversor'), (1, 'No inversor')],
          alCambiar: (v) => _modo.value = v,
        ),
        CampoValor(_rf, 'Rf (realimentación)'),
        CampoValor(_rin, inversor ? 'Rin (entrada)' : 'Rg (a masa)'),
        CampoValor(_vin, 'Tensión de entrada (opcional)', conSigno: true),
        res,
      ],
    );
  }
}

// ───────────────────────── Decibelios ─────────────────────────

class Decibelios extends StatefulWidget {
  const Decibelios({super.key});
  @override
  State<Decibelios> createState() => _DecibeliosState();
}

class _DecibeliosState extends EstadoCalculo<Decibelios> {
  late final _ratio = simple('×', ini: '2');
  late final _db = simple('dB', ini: '3');
  late final _dbm = simple('dBm', ini: '0');

  double _log10(double x) => log(x) / ln10;

  @override
  Widget build(BuildContext context) {
    final r = _ratio.v, db = _db.v, dbm = _dbm.v;
    return PantallaCalculo(
      titulo: 'Decibelios',
      formulas: const [
        'Potencia: dB = 10 × log₁₀(P2/P1)',
        'Tensión: dB = 20 × log₁₀(V2/V1)',
        'dBm = 10 × log₁₀(P / 1 mW)',
        '+3 dB ≈ doble de potencia · +6 dB ≈ doble de tensión',
      ],
      children: [
        const Titulo('De relación a dB'),
        CampoValor(_ratio, 'Relación (salida / entrada)'),
        Resultados([
          (
            'Si es de potencia',
            r != null && r > 0 ? '${fmt(10 * _log10(r))} dB' : '—',
          ),
          (
            'Si es de tensión',
            r != null && r > 0 ? '${fmt(20 * _log10(r))} dB' : '—',
          ),
        ]),
        const Titulo('De dB a relación'),
        CampoValor(_db, 'Decibelios', conSigno: true),
        Resultados([
          (
            'Relación de potencia',
            db != null ? '× ${fmt(pow(10, db / 10).toDouble())}' : '—',
          ),
          (
            'Relación de tensión',
            db != null ? '× ${fmt(pow(10, db / 20).toDouble())}' : '—',
          ),
        ]),
        const Titulo('dBm a potencia'),
        CampoValor(_dbm, 'dBm', conSigno: true),
        Resultados([
          ('Potencia', dbm != null ? ing(pow(10, dbm / 10) * 1e-3, 'W') : '—'),
          (
            'Tensión en 50 Ω',
            dbm != null ? ing(sqrt(pow(10, dbm / 10) * 1e-3 * 50), 'V') : '—',
          ),
        ]),
      ],
    );
  }
}

// ───────────────────────── Zener ─────────────────────────

class ReguladorZener extends StatefulWidget {
  const ReguladorZener({super.key});
  @override
  State<ReguladorZener> createState() => _ReguladorZenerState();
}

class _ReguladorZenerState extends EstadoCalculo<ReguladorZener> {
  late final _vin = val(uVoltios, i: 1, ini: '12');
  late final _vz = val(uVoltios, i: 1, ini: '5,1');
  late final _il = val(uAmperios, i: 1, ini: '20');
  late final _iz = val(uAmperios, i: 1, ini: '5');

  @override
  Widget build(BuildContext context) {
    final vin = _vin.v, vz = _vz.v, il = _il.v, iz = _iz.v;
    Widget res;
    if (vin == null || vz == null || il == null || iz == null) {
      res = const Aviso('Completa los datos.');
    } else if (vin <= vz) {
      res = const Aviso(
        'La entrada tiene que ser mayor que la tensión del zener.',
      );
    } else {
      final r = (vin - vz) / (il + iz);
      final rc = valorNormalizado(r, serieE24);
      final i = (vin - vz) / rc;
      final pr = i * i * rc;
      final pz = vz * i; // peor caso: sin carga
      res = Resultados(
        [
          ('Resistencia exacta', ing(r, 'Ω')),
          ('Comercial (E24)', ing(rc, 'Ω')),
          ('Potencia en R', '${ing(pr, 'W')} → ${potenciaRecomendada(pr)}'),
          ('Potencia del zener (sin carga)', ing(pz, 'W')),
        ],
        nota: 'Elige un zener de al menos el doble de esa potencia (0,5 W, 1 W…).',
      );
    }
    return PantallaCalculo(
      titulo: 'Regulador con zener',
      formulas: const [
        'R = (Vin − Vz) / (Icarga + Iz)',
        'Pz (peor caso, sin carga) = Vz × (Vin − Vz) / R',
      ],
      children: [
        CampoValor(_vin, 'Tensión de entrada'),
        CampoValor(_vz, 'Tensión del zener'),
        CampoValor(_il, 'Corriente de la carga'),
        CampoValor(_iz, 'Corriente mínima del zener', ayuda: 'Típico 5 mA'),
        res,
      ],
    );
  }
}
