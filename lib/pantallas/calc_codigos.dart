import 'package:flutter/material.dart';

import '../calc/codigos.dart';
import '../formato.dart';
import '../widgets.dart';

// ───────────────────────── Código de colores ─────────────────────────

class CodigoColores extends StatefulWidget {
  const CodigoColores({super.key});
  @override
  State<CodigoColores> createState() => _CodigoColoresState();
}

enum _TipoBanda { cifra, multiplicador, tolerancia, ppm }

class _CodigoColoresState extends EstadoCalculo<CodigoColores> {
  late final _bandas = reg(Modo(4));
  late final _valor = val(uOhmios, i: 1);
  // Colores elegidos: 3 cifras, multiplicador, tolerancia y ppm.
  var _cifras = [banda('Amarillo'), banda('Violeta'), banda('Negro')];
  var _mult = banda('Rojo');
  var _tol = banda('Oro');
  var _ppm = banda('Marrón');

  int get _nCifras => _bandas.value == 4 ? 2 : 3;

  List<ColorBanda> get _colores => [
    ..._cifras.take(_nCifras),
    _mult,
    _tol,
    if (_bandas.value == 6) _ppm,
  ];

  List<_TipoBanda> get _tipos => [
    for (var i = 0; i < _nCifras; i++) _TipoBanda.cifra,
    _TipoBanda.multiplicador,
    _TipoBanda.tolerancia,
    if (_bandas.value == 6) _TipoBanda.ppm,
  ];

  List<ColorBanda> _opciones(_TipoBanda t) => [
    for (final c in coloresBanda)
      if (switch (t) {
        _TipoBanda.cifra => c.digito != null,
        _TipoBanda.multiplicador => c.multiplicador != null,
        _TipoBanda.tolerancia =>
          c.tolerancia != null && (c.nombre != 'Ninguno' || _bandas.value == 4),
        _TipoBanda.ppm => c.ppm != null,
      })
        c,
  ];

  void _elegir(int i, ColorBanda c) {
    setState(() {
      switch (_tipos[i]) {
        case _TipoBanda.cifra:
          _cifras[i] = c;
        case _TipoBanda.multiplicador:
          _mult = c;
        case _TipoBanda.tolerancia:
          _tol = c;
        case _TipoBanda.ppm:
          _ppm = c;
      }
    });
  }

  void _usarValor(List<ColorBanda> cifras, ColorBanda mult) {
    setState(() {
      _cifras = [
        ...cifras,
        ...[banda('Negro'), banda('Negro'), banda('Negro')],
      ].take(3).toList();
      _mult = mult;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (_bandas.value != 4 && _tol.nombre == 'Ninguno') _tol = banda('Marrón');
    final ohm = valorBandas(_cifras.take(_nCifras).toList(), _mult);
    final t = _tol.tolerancia!;
    final inverso = _valor.v == null ? null : bandasPara(_valor.v!, _nCifras);
    return PantallaCalculo(
      titulo: 'Código de colores',
      children: [
        SelectorModo(
          valor: _bandas.value,
          opciones: const [(4, '4 bandas'), (5, '5 bandas'), (6, '6 bandas')],
          alCambiar: (v) => _bandas.value = v,
        ),
        DibujoResistencia(_colores),
        const SizedBox(height: 12),
        Resultados([
          ('Resistencia', ing(ohm, 'Ω')),
          ('Tolerancia', '±${fmt(t)} %'),
          ('Mínimo', ing(ohm * (1 - t / 100), 'Ω')),
          ('Máximo', ing(ohm * (1 + t / 100), 'Ω')),
          if (_bandas.value == 6) ('Coef. temperatura', '${_ppm.ppm} ppm/K'),
        ]),
        for (var i = 0; i < _colores.length; i++)
          _SelectorBanda(
            key: ValueKey('${_bandas.value}-$i-${_colores[i].nombre}'),
            etiqueta: switch (_tipos[i]) {
              _TipoBanda.cifra => '${i + 1}.ª cifra',
              _TipoBanda.multiplicador => 'Multiplicador',
              _TipoBanda.tolerancia => 'Tolerancia',
              _TipoBanda.ppm => 'Coef. temperatura',
            },
            tipo: _tipos[i],
            elegido: _colores[i],
            opciones: _opciones(_tipos[i]),
            alElegir: (c) => _elegir(i, c),
          ),
        const Divider(height: 32),
        const Titulo('De valor a colores'),
        CampoValor(_valor, 'Valor de la resistencia'),
        if (_valor.v != null && inverso == null)
          const Aviso('No se puede representar con bandas de colores.'),
        if (inverso != null) ...[
          DibujoResistencia([
            ...inverso.$1,
            inverso.$2,
            _tol,
            if (_bandas.value == 6) _ppm,
          ]),
          const SizedBox(height: 8),
          Text(
            [...inverso.$1, inverso.$2, _tol].map((c) => c.nombre).join(' · '),
            textAlign: TextAlign.center,
          ),
          if ((inverso.$3 - _valor.v!).abs() > _valor.v! * 1e-9)
            Aviso(
              'Con $_nCifras cifras se redondea a ${ing(inverso.$3, 'Ω')}.',
            ),
          Builder(
            builder: (context) {
              final serie = _nCifras == 2 ? serieE24 : null;
              if (serie == null) return const SizedBox.shrink();
              final n = valorNormalizado(_valor.v!, serie);
              return Aviso('Valor comercial E24 más cercano: ${ing(n, 'Ω')}');
            },
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () => _usarValor(inverso.$1, inverso.$2),
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Mostrar arriba'),
          ),
        ],
      ],
    );
  }
}

class _SelectorBanda extends StatelessWidget {
  final String etiqueta;
  final _TipoBanda tipo;
  final ColorBanda elegido;
  final List<ColorBanda> opciones;
  final ValueChanged<ColorBanda> alElegir;

  const _SelectorBanda({
    super.key,
    required this.etiqueta,
    required this.tipo,
    required this.elegido,
    required this.opciones,
    required this.alElegir,
  });

  String _detalle(ColorBanda c) => switch (tipo) {
    _TipoBanda.cifra => '${c.digito}',
    _TipoBanda.multiplicador => '× ${ing(c.multiplicador!, 'Ω')}',
    _TipoBanda.tolerancia => '±${fmt(c.tolerancia!)} %',
    _TipoBanda.ppm => '${c.ppm} ppm/K',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: elegido.nombre,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: [
          for (final c in opciones)
            DropdownMenuItem(
              value: c.nombre,
              child: Row(
                children: [
                  MuestraColor(c.color),
                  const SizedBox(width: 12),
                  Expanded(child: Text(c.nombre)),
                  Text(_detalle(c)),
                ],
              ),
            ),
        ],
        onChanged: (n) => alElegir(banda(n!)),
      ),
    );
  }
}

/// Cuadradito de color con borde (el transparente se ve tachado).
class MuestraColor extends StatelessWidget {
  final Color color;
  final double tamano;
  const MuestraColor(this.color, {super.key, this.tamano = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: color.a == 0
          ? Icon(Icons.block, size: tamano * 0.8, color: Colors.grey)
          : null,
    );
  }
}

/// Dibujo de una resistencia de inserción con sus bandas.
class DibujoResistencia extends StatelessWidget {
  final List<ColorBanda> bandas;
  const DibujoResistencia(this.bandas, {super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3.2,
      child: CustomPaint(painter: _PintorResistencia(bandas)),
    );
  }
}

class _PintorResistencia extends CustomPainter {
  final List<ColorBanda> bandas;
  _PintorResistencia(this.bandas);

  @override
  void paint(Canvas canvas, Size s) {
    final h = s.height;
    final patas = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = h * 0.06;
    canvas.drawLine(Offset(0, h / 2), Offset(s.width, h / 2), patas);
    final cuerpo = Rect.fromLTWH(
      s.width * 0.15,
      h * 0.12,
      s.width * 0.7,
      h * 0.76,
    );
    final rr = RRect.fromRectAndRadius(cuerpo, Radius.circular(h * 0.3));
    canvas.drawRRect(rr, Paint()..color = const Color(0xFFE8CFA0));
    canvas.save();
    canvas.clipRRect(rr);
    final ancho = cuerpo.width * 0.07;
    final n = bandas.length;
    // Las bandas de valor van juntas a la izquierda; la de tolerancia,
    // separada a la derecha.
    final inicio = cuerpo.left + cuerpo.width * 0.14;
    final paso = cuerpo.width * 0.12;
    for (var i = 0; i < n; i++) {
      final esTol = i == n - 1 || (n == 6 && i == n - 2);
      final x = esTol
          ? cuerpo.right - cuerpo.width * 0.12 - (n - 1 - i) * paso - ancho
          : inicio + i * paso;
      final c = bandas[i].color;
      if (c.a == 0) continue;
      canvas.drawRect(
        Rect.fromLTWH(x, cuerpo.top, ancho, cuerpo.height),
        Paint()..color = c,
      );
    }
    canvas.restore();
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x55000000)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_PintorResistencia old) => true;
}

// ───────────────────────── SMD ─────────────────────────

class CodigoSmd extends StatefulWidget {
  const CodigoSmd({super.key});
  @override
  State<CodigoSmd> createState() => _CodigoSmdState();
}

class _CodigoSmdState extends EstadoCalculo<CodigoSmd> {
  final _codigo = TextEditingController();

  @override
  void initState() {
    super.initState();
    _codigo.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget resultado;
    if (_codigo.text.trim().isEmpty) {
      resultado = const SizedBox.shrink();
    } else {
      try {
        final r = decodificarSmd(_codigo.text);
        resultado = Resultados([('Resistencia', ing(r, 'Ω'))]);
      } on ErrorCodigo catch (e) {
        resultado = Aviso(e.mensaje);
      }
    }
    return PantallaCalculo(
      titulo: 'Resistencias SMD',
      formulas: const [
        '3 cifras: 2 cifras + nº de ceros. 472 = 47 × 10² = 4,7 kΩ',
        '4 cifras: 3 cifras + nº de ceros. 1002 = 100 × 10² = 10 kΩ',
        'R, K o M marcan la coma: 4R7 = 4,7 Ω · R10 = 0,1 Ω · 4K7 = 4,7 kΩ',
        'EIA-96: 2 cifras (tabla E96) + letra multiplicadora. 01C = 100 × 100 = 10 kΩ',
        'Letras EIA-96: Z ×0,001 · Y/R ×0,01 · X/S ×0,1 · A ×1 · B/H ×10 · C ×100 · D ×1k · E ×10k · F ×100k',
        '000 o 0 = puente de 0 Ω',
      ],
      children: [
        TextField(
          controller: _codigo,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(fontSize: 28, letterSpacing: 4),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            labelText: 'Código impreso',
            hintText: '103',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        resultado,
      ],
    );
  }
}

// ───────────────────────── Condensadores ─────────────────────────

class CodigoCondensadores extends StatefulWidget {
  const CodigoCondensadores({super.key});
  @override
  State<CodigoCondensadores> createState() => _CodigoCondensadoresState();
}

class _CodigoCondensadoresState extends EstadoCalculo<CodigoCondensadores> {
  final _codigo = TextEditingController();
  late final _cap = val(uFaradios, i: 1);

  @override
  void initState() {
    super.initState();
    _codigo.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget resultado = const SizedBox.shrink();
    if (_codigo.text.trim().isNotEmpty) {
      try {
        final (f, tol) = decodificarCondensador(_codigo.text);
        resultado = Resultados([
          ('pF', '${fmt(f / 1e-12, cifras: 5)} pF'),
          ('nF', '${fmt(f / 1e-9, cifras: 5)} nF'),
          ('µF', '${fmt(f / 1e-6, cifras: 5)} µF'),
          if (tol != null) ('Tolerancia', tol),
        ]);
      } on ErrorCodigo catch (e) {
        resultado = Aviso(e.mensaje);
      }
    }
    final codigo = _cap.v == null ? null : codigoCondensador(_cap.v!);
    return PantallaCalculo(
      titulo: 'Código de condensadores',
      formulas: const [
        '3 cifras: 2 cifras + nº de ceros, en pF. 104 = 10 × 10⁴ pF = 100 nF',
        'Tercer dígito 8 = ×0,01 y 9 = ×0,1. 109 = 1 pF',
        'Letra como coma: 4n7 = 4,7 nF · 2u2 = 2,2 µF · p47 = 0,47 pF',
        'Letra final = tolerancia: J ±5 % · K ±10 % · M ±20 % · Z +80/−20 %',
        'Decimal sin unidad (0.047) = µF',
      ],
      children: [
        TextField(
          controller: _codigo,
          style: const TextStyle(fontSize: 28, letterSpacing: 4),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            labelText: 'Código impreso',
            hintText: '104K',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        resultado,
        const Divider(height: 32),
        const Titulo('De capacidad a código'),
        CampoValor(_cap, 'Capacidad'),
        if (_cap.v != null)
          codigo == null
              ? const Aviso(
                  'Por debajo de 10 pF se escribe el valor directamente (p. ej. 4p7).',
                )
              : Resultados([('Código', codigo)]),
      ],
    );
  }
}
