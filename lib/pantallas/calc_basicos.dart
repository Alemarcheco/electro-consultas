import 'dart:math';

import 'package:flutter/material.dart';

import '../calc/codigos.dart';
import '../formato.dart';
import '../widgets.dart';

/// Potencias normalizadas de resistencias, en W.
const potenciasResistencia = [0.125, 0.25, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0];

/// Potencia comercial recomendada (con margen ×2).
String potenciaRecomendada(double w) {
  for (final p in potenciasResistencia) {
    if (p >= 2 * w) {
      return switch (p) {
        0.125 => '1/8 W',
        0.25 => '1/4 W',
        0.5 => '1/2 W',
        _ => '${fmt(p)} W',
      };
    }
  }
  return 'más de 10 W';
}

// ───────────────────────── Ley de Ohm ─────────────────────────

class LeyOhm extends StatefulWidget {
  const LeyOhm({super.key});
  @override
  State<LeyOhm> createState() => _LeyOhmState();
}

class _LeyOhmState extends EstadoCalculo<LeyOhm> {
  late final _v = val(uVoltios, i: 1);
  late final _i = val(uAmperios, i: 2);
  late final _r = val(uOhmios);
  late final _p = val(uVatios, i: 1);

  @override
  Widget build(BuildContext context) {
    final llenos = [_v, _i, _r, _p].where((x) => x.v != null).length;
    Widget resultado;
    if (llenos < 2) {
      resultado = const Aviso(
        'Escribe dos valores cualesquiera y se calculan los otros dos.',
      );
    } else if (llenos > 2) {
      resultado = const Aviso(
        'Hay más de dos valores: deja vacíos los que quieras calcular.',
      );
    } else {
      double? v = _v.v, i = _i.v, r = _r.v, p = _p.v;
      if (v != null && i != null) {
        r = v / i;
        p = v * i;
      } else if (v != null && r != null) {
        i = v / r;
        p = v * v / r;
      } else if (v != null && p != null) {
        i = p / v;
        r = v * v / p;
      } else if (i != null && r != null) {
        v = i * r;
        p = i * i * r;
      } else if (i != null && p != null) {
        v = p / i;
        r = p / (i * i);
      } else {
        v = sqrt(p! * r!);
        i = sqrt(p / r);
      }
      resultado = Resultados([
        ('Tensión (V)', ing(v, 'V')),
        ('Corriente (I)', ing(i, 'A')),
        ('Resistencia (R)', ing(r, 'Ω')),
        ('Potencia (P)', ing(p, 'W')),
      ]);
    }
    return PantallaCalculo(
      titulo: 'Ley de Ohm',
      formulas: const [
        'V = I × R',
        'I = V / R',
        'R = V / I',
        'P = V × I = I² × R = V² / R',
      ],
      children: [
        CampoValor(_v, 'Tensión (V)'),
        CampoValor(_i, 'Corriente (I)'),
        CampoValor(_r, 'Resistencia (R)'),
        CampoValor(_p, 'Potencia (P)'),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              for (final x in [_v, _i, _r, _p]) {
                x.limpiar();
              }
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpiar'),
          ),
        ),
        resultado,
      ],
    );
  }
}

// ───────────────────────── Serie y paralelo ─────────────────────────

enum TipoComponente { resistencia, condensador, bobina }

class SerieParalelo extends StatefulWidget {
  final TipoComponente inicial;
  const SerieParalelo({super.key, this.inicial = TipoComponente.resistencia});
  @override
  State<SerieParalelo> createState() => _SerieParaleloState();
}

class _SerieParaleloState extends EstadoCalculo<SerieParalelo> {
  late final _tipo = reg(Modo(widget.inicial));
  final _listas = <TipoComponente, List<Valor>>{};

  List<Unidad> _unidades(TipoComponente t) => switch (t) {
    TipoComponente.resistencia => uOhmios,
    TipoComponente.condensador => uFaradios,
    TipoComponente.bobina => uHenrios,
  };

  List<Valor> get _lista => _listas.putIfAbsent(
    _tipo.value,
    () => [
      for (var k = 0; k < 2; k++)
        val(
          _unidades(_tipo.value),
          i: _tipo.value == TipoComponente.resistencia ? 1 : 2,
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final t = _tipo.value;
    final (unidad, nombre) = switch (t) {
      TipoComponente.resistencia => ('Ω', 'R'),
      TipoComponente.condensador => ('F', 'C'),
      TipoComponente.bobina => ('H', 'L'),
    };
    final valores = [for (final x in _lista) x.v].whereType<double>().toList();
    final suma = valores.fold(0.0, (a, b) => a + b);
    final inversa = valores.any((x) => x == 0)
        ? double.infinity
        : valores.fold(0.0, (a, b) => a + 1 / b);
    final enSerie = t == TipoComponente.condensador ? 1 / inversa : suma;
    final enParalelo = t == TipoComponente.condensador ? suma : 1 / inversa;
    return PantallaCalculo(
      titulo: 'Serie y paralelo',
      formulas: t == TipoComponente.condensador
          ? const ['Serie: 1/C = 1/C1 + 1/C2 + …', 'Paralelo: C = C1 + C2 + …']
          : [
              'Serie: $nombre = ${nombre}1 + ${nombre}2 + …',
              'Paralelo: 1/$nombre = 1/${nombre}1 + 1/${nombre}2 + …',
              'Dos en paralelo: $nombre = (${nombre}1 × ${nombre}2) / (${nombre}1 + ${nombre}2)',
            ],
      children: [
        SelectorModo(
          valor: t,
          opciones: const [
            (TipoComponente.resistencia, 'Resistencias'),
            (TipoComponente.condensador, 'Condensadores'),
            (TipoComponente.bobina, 'Bobinas'),
          ],
          alCambiar: (v) => _tipo.value = v,
        ),
        for (var k = 0; k < _lista.length; k++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: CampoValor(_lista[k], '$nombre${k + 1}')),
              if (_lista.length > 2)
                IconButton(
                  tooltip: 'Quitar',
                  onPressed: () => setState(() => _lista.removeAt(k)),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(
              () => _lista.add(val(_unidades(t), i: _lista.first.indice)),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Añadir otro'),
          ),
        ),
        const SizedBox(height: 8),
        if (valores.length < 2)
          const Aviso('Escribe al menos dos valores.')
        else
          Resultados([
            ('En serie', ing(enSerie, unidad)),
            ('En paralelo', ing(enParalelo, unidad)),
          ]),
      ],
    );
  }
}

// ───────────────────────── Divisor de tensión ─────────────────────────

class DivisorTension extends StatefulWidget {
  const DivisorTension({super.key});
  @override
  State<DivisorTension> createState() => _DivisorTensionState();
}

class _DivisorTensionState extends EstadoCalculo<DivisorTension> {
  late final _modo = reg(Modo(0));
  late final _vin = val(uVoltios, i: 1, ini: '12');
  late final _r1 = val(uOhmios, i: 1, ini: '10');
  late final _r2 = val(uOhmios, i: 1, ini: '10');
  late final _vout = val(uVoltios, i: 1, ini: '5');

  @override
  Widget build(BuildContext context) {
    final vin = _vin.v, r1 = _r1.v, r2 = _r2.v, vout = _vout.v;
    Widget res;
    if (_modo.value == 0) {
      if (vin == null || r1 == null || r2 == null || r1 + r2 == 0) {
        res = const Aviso('Escribe Vin, R1 y R2.');
      } else {
        final i = vin / (r1 + r2);
        res = Resultados(
          [
            ('Vout', ing(vin * r2 / (r1 + r2), 'V')),
            ('Corriente', ing(i, 'A')),
            ('Potencia en R1', ing(i * i * r1, 'W')),
            ('Potencia en R2', ing(i * i * r2, 'W')),
          ],
          nota:
              'Sin carga. Si conectas una carga a Vout, va en paralelo con R2.',
        );
      }
    } else {
      if (vin == null || r1 == null || vout == null) {
        res = const Aviso('Escribe Vin, Vout y R1.');
      } else if (vout >= vin || vout <= 0) {
        res = const Aviso('Vout tiene que ser menor que Vin y mayor que 0.');
      } else {
        final r2 = r1 * vout / (vin - vout);
        final n = valorNormalizado(r2, serieE24);
        res = Resultados([
          ('R2 exacta', ing(r2, 'Ω')),
          ('R2 comercial (E24)', ing(n, 'Ω')),
          ('Vout con R2 comercial', ing(vin * n / (r1 + n), 'V')),
        ]);
      }
    }
    return PantallaCalculo(
      titulo: 'Divisor de tensión',
      formulas: const [
        'Vout = Vin × R2 / (R1 + R2)',
        'R2 = R1 × Vout / (Vin − Vout)',
        'Vin ── R1 ──┬── Vout\n                    R2\n                    ⏚',
      ],
      children: [
        SelectorModo(
          valor: _modo.value,
          opciones: const [(0, 'Calcular Vout'), (1, 'Calcular R2')],
          alCambiar: (v) => _modo.value = v,
        ),
        CampoValor(_vin, 'Tensión de entrada (Vin)'),
        if (_modo.value == 1)
          CampoValor(_vout, 'Tensión de salida deseada (Vout)'),
        CampoValor(_r1, 'R1 (arriba)'),
        if (_modo.value == 0) CampoValor(_r2, 'R2 (abajo)'),
        res,
      ],
    );
  }
}

// ───────────────────────── Resistencia para LED ─────────────────────────

/// Tensión directa típica por color de LED.
const tensionesLed = <(String, double, Color)>[
  ('Infrarrojo', 1.3, Color(0xFF5D4037)),
  ('Rojo', 1.9, Color(0xFFE53935)),
  ('Naranja', 2.0, Color(0xFFFF8F00)),
  ('Amarillo', 2.1, Color(0xFFFDD835)),
  ('Verde', 2.2, Color(0xFF43A047)),
  ('Verde puro', 3.1, Color(0xFF00C853)),
  ('Azul', 3.2, Color(0xFF1E88E5)),
  ('Blanco', 3.2, Color(0xFFF5F5F5)),
  ('Ultravioleta', 3.4, Color(0xFF7C4DFF)),
];

class ResistenciaLed extends StatefulWidget {
  const ResistenciaLed({super.key});
  @override
  State<ResistenciaLed> createState() => _ResistenciaLedState();
}

class _ResistenciaLedState extends EstadoCalculo<ResistenciaLed> {
  late final _vs = val(uVoltios, i: 1, ini: '5');
  late final _vf = val(uVoltios, i: 1, ini: '2');
  late final _if = val(uAmperios, i: 1, ini: '20');
  late final _n = simple('LED', ini: '1');

  @override
  Widget build(BuildContext context) {
    final vs = _vs.v, vf = _vf.v, i = _if.v, n = _n.v?.round();
    Widget res;
    if (vs == null || vf == null || i == null || n == null || n < 1 || i <= 0) {
      res = const Aviso('Completa todos los datos.');
    } else if (vs <= n * vf) {
      res = Aviso(
        'La alimentación (${fmt(vs)} V) tiene que ser mayor que la suma de '
        'tensiones de los LED (${fmt(n * vf)} V).',
      );
    } else {
      final r = (vs - n * vf) / i;
      final rc = valorNormalizado(r, serieE24, porArriba: true);
      final ic = (vs - n * vf) / rc;
      final p = ic * ic * rc;
      res = Resultados([
        ('Resistencia exacta', ing(r, 'Ω')),
        ('Comercial (E24)', ing(rc, 'Ω')),
        ('Corriente real', ing(ic, 'A')),
        ('Potencia en R', ing(p, 'W')),
        ('Resistencia de', potenciaRecomendada(p)),
        ('Consumo total', ing(vs * ic, 'W')),
      ]);
    }
    return PantallaCalculo(
      titulo: 'Resistencia para LED',
      formulas: const [
        'R = (Vfuente − n × Vled) / I',
        'P = I² × R',
        'Se redondea al valor comercial superior para no pasar de la corriente.',
      ],
      children: [
        CampoValor(_vs, 'Tensión de la fuente'),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final (nombre, v, c) in tensionesLed)
              ActionChip(
                avatar: CircleAvatar(backgroundColor: c),
                label: Text(nombre),
                onPressed: () {
                  _vf.cambiarUnidad(1);
                  _vf.texto.text = fmt(v);
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        CampoValor(_vf, 'Tensión del LED (Vf)'),
        CampoValor(
          _if,
          'Corriente del LED',
          ayuda: 'Normal: 10–20 mA; alta luminosidad: hasta 30 mA',
        ),
        CampoValor(_n, 'LED en serie'),
        res,
      ],
    );
  }
}

// ───────────────────────── Potencia eléctrica ─────────────────────────

enum Sistema { continua, monofasica, trifasica }

class PotenciaElectrica extends StatefulWidget {
  const PotenciaElectrica({super.key});
  @override
  State<PotenciaElectrica> createState() => _PotenciaElectricaState();
}

class _PotenciaElectricaState extends EstadoCalculo<PotenciaElectrica> {
  late final _sistema = reg(Modo(Sistema.monofasica));
  late final _modo = reg(Modo(0));
  late final _v = val(uVoltios, i: 1, ini: '230');
  late final _i = val(uAmperios, i: 2, ini: '10');
  late final _p = val(uVatios, i: 2, ini: '2');
  late final _cos = simple('cos φ', ini: '0,9');

  @override
  Widget build(BuildContext context) {
    final s = _sistema.value;
    final k = s == Sistema.trifasica ? sqrt(3) : 1.0;
    final cos = s == Sistema.continua ? 1.0 : _cos.v;
    final v = _v.v;
    Widget res;
    if (v == null || cos == null || cos <= 0 || cos > 1) {
      res = const Aviso('Completa los datos (cos φ entre 0 y 1).');
    } else {
      double? i, p;
      if (_modo.value == 0) {
        i = _i.v;
        if (i != null) p = k * v * i * cos;
      } else {
        p = _p.v;
        if (p != null) i = p / (k * v * cos);
      }
      if (i == null || p == null) {
        res = const Aviso('Completa los datos.');
      } else {
        final sAp = k * v * i;
        final q = sAp * sin(acos(cos));
        res = Resultados([
          ('Potencia activa (P)', ing(p, 'W')),
          if (s != Sistema.continua) ...[
            ('Potencia aparente (S)', ing(sAp, 'VA')),
            ('Potencia reactiva (Q)', ing(q, 'VAr')),
          ],
          ('Corriente (I)', ing(i, 'A')),
          ('En caballos (CV)', '${fmt(p / 735.5)} CV'),
        ]);
      }
    }
    return PantallaCalculo(
      titulo: 'Potencia eléctrica',
      formulas: const [
        'Continua: P = V × I',
        'Monofásica: P = V × I × cos φ · S = V × I',
        'Trifásica: P = √3 × V × I × cos φ (V entre fases)',
        'Q = S × sen φ · 1 CV = 735,5 W · 1 HP = 745,7 W',
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
        SelectorModo(
          valor: _modo.value,
          opciones: const [(0, 'Calcular potencia'), (1, 'Calcular corriente')],
          alCambiar: (x) => _modo.value = x,
        ),
        CampoValor(
          _v,
          s == Sistema.trifasica ? 'Tensión entre fases' : 'Tensión',
        ),
        if (_modo.value == 0)
          CampoValor(_i, 'Corriente')
        else
          CampoValor(_p, 'Potencia activa'),
        if (s != Sistema.continua)
          CampoValor(
            _cos,
            'Factor de potencia',
            ayuda: 'Resistivo = 1; motores ≈ 0,8–0,9',
          ),
        res,
      ],
    );
  }
}
