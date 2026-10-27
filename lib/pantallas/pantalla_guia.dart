import 'dart:math';

import 'package:flutter/material.dart';

import '../guias/modelo.dart';

/// Índice de capítulos de una guía.
class PantallaGuia extends StatelessWidget {
  final Guia guia;
  const PantallaGuia(this.guia, {super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(guia.titulo)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              guia.subtitulo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (var i = 0; i < guia.capitulos.length; i++)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: esquema.primaryContainer,
                foregroundColor: esquema.onPrimaryContainer,
                child: Icon(guia.capitulos[i].icono),
              ),
              title: Text('${i + 1}. ${guia.capitulos[i].titulo}'),
              subtitle: Text(guia.capitulos[i].resumen),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PantallaCapitulo(guia, i)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Un capítulo, con botones para pasar al anterior y al siguiente.
class PantallaCapitulo extends StatelessWidget {
  final Guia guia;
  final int indice;
  const PantallaCapitulo(this.guia, this.indice, {super.key});

  void _ir(BuildContext context, int i) => Navigator.of(context)
      .pushReplacement(
        MaterialPageRoute(builder: (_) => PantallaCapitulo(guia, i)),
      );

  @override
  Widget build(BuildContext context) {
    final c = guia.capitulos[indice];
    return Scaffold(
      appBar: AppBar(title: Text(c.titulo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            '${guia.titulo} · ${indice + 1} de ${guia.capitulos.length}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          for (final b in c.bloques) VistaBloque(b),
          const SizedBox(height: 16),
          Row(
            children: [
              if (indice > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _ir(context, indice - 1),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(
                      guia.capitulos[indice - 1].titulo,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 8),
              if (indice < guia.capitulos.length - 1)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _ir(context, indice + 1),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      guia.capitulos[indice + 1].titulo,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class VistaBloque extends StatelessWidget {
  final Bloque bloque;
  const VistaBloque(this.bloque, {super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    switch (bloque) {
      case Subtitulo(:final texto):
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            texto,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: esquema.primary, fontWeight: FontWeight.bold),
          ),
        );
      case Parrafo(texto: final t):
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(t, style: texto.bodyLarge),
        );
      case Pasos(:final pasos):
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < pasos.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: esquema.primary,
                        foregroundColor: esquema.onPrimary,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(pasos[i], style: texto.bodyLarge)),
                    ],
                  ),
                ),
            ],
          ),
        );
      case Vinetas(:final items):
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              for (final it in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 10),
                        child: Icon(
                          Icons.circle,
                          size: 7,
                          color: esquema.primary,
                        ),
                      ),
                      Expanded(child: Text(it, style: texto.bodyLarge)),
                    ],
                  ),
                ),
            ],
          ),
        );
      case Nota(texto: final t, :final peligro):
        final fondo = peligro
            ? esquema.errorContainer
            : esquema.secondaryContainer;
        final frente = peligro
            ? esquema.onErrorContainer
            : esquema.onSecondaryContainer;
        return Card(
          color: fondo,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  peligro ? Icons.warning_amber : Icons.lightbulb_outline,
                  color: frente,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(t, style: TextStyle(color: frente)),
                ),
              ],
            ),
          ),
        );
      case TablaGuia(:final columnas, :final filas):
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              horizontalMargin: 8,
              dataRowMinHeight: 36,
              dataRowMaxHeight: double.infinity,
              headingTextStyle: texto.titleSmall?.copyWith(
                color: esquema.primary,
              ),
              border: TableBorder.all(color: esquema.outlineVariant),
              columns: [for (final c in columnas) DataColumn(label: Text(c))],
              rows: [
                for (final f in filas)
                  DataRow(
                    cells: [
                      for (var j = 0; j < columnas.length; j++)
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 230),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                j < f.length ? f[j] : '',
                                style: j == 0
                                    ? const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      case DibujoEquipo():
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: SizedBox(
              width: 320,
              child: AspectRatio(
                aspectRatio: 0.62,
                child: CustomPaint(painter: PintorCalibrador(texto.bodySmall!)),
              ),
            ),
          ),
        );
      case Conexion():
        return DibujoConexion(bloque as Conexion);
    }
  }
}

// ───────────────────────── Esquemas de conexión ─────────────────────────

class DibujoConexion extends StatelessWidget {
  final Conexion conexion;
  const DibujoConexion(this.conexion, {super.key});

  static const fila = 42.0, cabecera = 44.0;

  @override
  Widget build(BuildContext context) {
    final filas = conexion.equipos.map((e) => e.bornes.length).reduce(max);
    final alto = cabecera + filas * fila + 40;
    final esquema = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: esquema.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schema_outlined, color: esquema.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    conexion.titulo,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: alto,
              width: double.infinity,
              child: CustomPaint(
                painter: _PintorConexion(
                  conexion,
                  esquema.onSurface,
                  esquema.surface,
                  Theme.of(context).textTheme.bodySmall!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PintorConexion extends CustomPainter {
  final Conexion c;
  final Color tinta;
  final Color fondo;
  final TextStyle base;
  _PintorConexion(this.c, this.tinta, this.fondo, this.base);

  static const fila = DibujoConexion.fila, cabecera = DibujoConexion.cabecera;

  late double _anchoCaja;
  late List<double> _xCaja;

  Lado _lado(int e, int b) {
    final borne = c.equipos[e].bornes[b];
    if (borne.lado != null) return borne.lado!;
    return e == c.equipos.length - 1 && e > 0 ? Lado.izquierda : Lado.derecha;
  }

  Offset _punto(int e, int b) {
    final x = _lado(e, b) == Lado.derecha ? _xCaja[e] + _anchoCaja : _xCaja[e];
    return Offset(x, cabecera + fila * b + fila / 2 + 10);
  }

  void _texto(
    Canvas canvas,
    String t,
    Offset o,
    double ancho, {
    Color? color,
    double tam = 11,
    TextAlign alinear = TextAlign.left,
    bool negrita = false,
    int lineas = 2,
    bool centrarV = true,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: base.copyWith(
          color: color ?? tinta,
          fontSize: tam,
          fontWeight: negrita ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textAlign: alinear,
      textDirection: TextDirection.ltr,
      maxLines: lineas,
      ellipsis: '…',
    )..layout(maxWidth: ancho);
    final dx = switch (alinear) {
      TextAlign.right => o.dx - tp.width,
      TextAlign.center => o.dx - tp.width / 2,
      _ => o.dx,
    };
    tp.paint(canvas, Offset(dx, centrarV ? o.dy - tp.height / 2 : o.dy));
  }

  @override
  void paint(Canvas canvas, Size s) {
    final n = c.equipos.length;
    final hueco = n == 2 ? s.width * 0.26 : s.width * 0.1;
    _anchoCaja = (s.width - hueco * (n - 1)) / n;
    _xCaja = [for (var i = 0; i < n; i++) i * (_anchoCaja + hueco)];

    // Cajas.
    for (var e = 0; e < n; e++) {
      final eq = c.equipos[e];
      final alto = cabecera + eq.bornes.length * fila + 10;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(_xCaja[e], 0, _anchoCaja, alto),
        const Radius.circular(10),
      );
      canvas.drawRRect(r, Paint()..color = eq.color);
      _texto(
        canvas,
        eq.nombre,
        Offset(_xCaja[e] + _anchoCaja / 2, cabecera / 2 + 2),
        _anchoCaja - 10,
        color: Colors.white,
        tam: 12,
        alinear: TextAlign.center,
        negrita: true,
      );
      for (var b = 0; b < eq.bornes.length; b++) {
        final p = _punto(e, b);
        final izq = _lado(e, b) == Lado.izquierda;
        _texto(
          canvas,
          eq.bornes[b].etiqueta,
          Offset(izq ? p.dx + 12 : p.dx - 12, p.dy),
          _anchoCaja - 22,
          color: Colors.white,
          tam: 10.5,
          alinear: izq ? TextAlign.left : TextAlign.right,
        );
      }
    }

    // Cables.
    for (final cab in c.cables) {
      final a = _punto(cab.desde.$1, cab.desde.$2);
      final b = _punto(cab.hasta.$1, cab.hasta.$2);
      final dx = (b.dx - a.dx).abs() * 0.5;
      final sa = _lado(cab.desde.$1, cab.desde.$2) == Lado.derecha ? 1 : -1;
      final sb = _lado(cab.hasta.$1, cab.hasta.$2) == Lado.derecha ? 1 : -1;
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx + sa * dx, a.dy, b.dx + sb * dx, b.dy, b.dx, b.dy);
      final manguera = cab.tipo == TipoCable.manguera;
      if (manguera) {
        canvas.drawPath(
          path,
          Paint()
            ..color = cab.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFCFD8DC)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      } else {
        // Borde para que los cables claros se vean sobre cualquier fondo.
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0x66000000)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5.5,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = cab.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5,
        );
      }
      if (cab.etiqueta != null) {
        final m = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
        final tp = TextPainter(
          text: TextSpan(
            text: cab.etiqueta,
            style: base.copyWith(
              color: tinta,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          maxLines: 3,
        )..layout(maxWidth: max(70, (b.dx - a.dx).abs() + 20));
        final rect = Rect.fromCenter(
          center: m.translate(0, -tp.height / 2 - 6),
          width: tp.width + 6,
          height: tp.height + 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = fondo.withValues(alpha: 0.9),
        );
        tp.paint(canvas, Offset(rect.left + 3, rect.top + 1));
      }
    }

    // Puntos de los bornes, encima de los cables.
    for (var e = 0; e < n; e++) {
      for (var b = 0; b < c.equipos[e].bornes.length; b++) {
        final p = _punto(e, b);
        canvas.drawCircle(p, 7, Paint()..color = Colors.white);
        canvas.drawCircle(p, 5, Paint()..color = c.equipos[e].bornes[b].color);
      }
    }
  }

  @override
  bool shouldRepaint(_PintorConexion old) => old.c != c || old.tinta != tinta;
}

// ───────────────────────── Frente del calibrador ─────────────────────────

class PintorCalibrador extends CustomPainter {
  final TextStyle base;
  const PintorCalibrador(this.base);

  void _t(
    Canvas canvas,
    String t,
    Offset centro,
    double tam,
    Color color, {
    double ancho = 200,
    bool negrita = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: base.copyWith(
          fontSize: tam,
          color: color,
          fontWeight: negrita ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: ancho);
    tp.paint(canvas, centro - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    // Funda amarilla y cuerpo gris.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & s, Radius.circular(w * 0.08)),
      Paint()..color = const Color(0xFFF2B705),
    );
    final cuerpo = Rect.fromLTWH(w * 0.05, h * 0.03, w * 0.9, h * 0.94);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cuerpo, Radius.circular(w * 0.05)),
      Paint()..color = const Color(0xFF37474F),
    );

    // Bornes superiores.
    final yB = h * 0.085;
    final grupos = <(String, List<Color>, double)>[
      (
        'MEAS\nV Ω RTD',
        [Colors.red, Colors.black, Colors.red, Colors.black],
        0.25,
      ),
      ('MEAS\nmA', [Colors.red, Colors.black], 0.5),
      ('SOURCE\nV mA Ω Hz', [Colors.red, Colors.black], 0.75),
    ];
    for (final (nombre, colores, cx) in grupos) {
      final paso = w * 0.055;
      final x0 = w * cx - paso * (colores.length - 1) / 2;
      for (var i = 0; i < colores.length; i++) {
        canvas.drawCircle(
          Offset(x0 + i * paso, yB),
          w * 0.022,
          Paint()..color = const Color(0xFFBDBDBD),
        );
        canvas.drawCircle(
          Offset(x0 + i * paso, yB),
          w * 0.016,
          Paint()..color = colores[i],
        );
      }
      _t(
        canvas,
        nombre,
        Offset(w * cx, yB + h * 0.045),
        w * 0.03,
        Colors.white,
        ancho: w * 0.3,
      );
    }
    _t(
      canvas,
      'TC · presión · USB',
      Offset(w * 0.5, h * 0.165),
      w * 0.032,
      const Color(0xFFFFE082),
    );

    // Pantalla.
    final pant = Rect.fromLTWH(w * 0.12, h * 0.2, w * 0.76, h * 0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pant, const Radius.circular(6)),
      Paint()..color = const Color(0xFFC5E1A5),
    );
    _t(
      canvas,
      'GENERAR  Presión',
      Offset(pant.center.dx, pant.top + pant.height * 0.12),
      w * 0.035,
      Colors.black87,
    );
    _t(
      canvas,
      '5,000 bar',
      Offset(pant.center.dx, pant.top + pant.height * 0.3),
      w * 0.07,
      Colors.black,
      negrita: true,
    );
    canvas.drawLine(
      Offset(pant.left + 8, pant.center.dy),
      Offset(pant.right - 8, pant.center.dy),
      Paint()..color = Colors.black45,
    );
    _t(
      canvas,
      'MEDIR  mA  · lazo 24 V',
      Offset(pant.center.dx, pant.top + pant.height * 0.6),
      w * 0.035,
      Colors.black87,
    );
    _t(
      canvas,
      '12,003 mA',
      Offset(pant.center.dx, pant.top + pant.height * 0.78),
      w * 0.07,
      Colors.black,
      negrita: true,
    );
    _t(
      canvas,
      'Escala   Mín/Máx   Paso   Más',
      Offset(pant.center.dx, pant.bottom - pant.height * 0.07),
      w * 0.03,
      Colors.black54,
    );

    // Teclas programables.
    final yS = h * 0.535;
    for (var i = 0; i < 4; i++) {
      final r = Rect.fromCenter(
        center: Offset(pant.left + pant.width * (i + 0.5) / 4, yS),
        width: w * 0.15,
        height: h * 0.03,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        Paint()..color = const Color(0xFF90A4AE),
      );
    }

    // Teclas de modo y función.
    void tecla(String t, Offset c, double ancho, Color color) {
      final r = Rect.fromCenter(center: c, width: ancho, height: h * 0.045);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(5)),
        Paint()..color = color,
      );
      _t(canvas, t, c, w * 0.032, Colors.white, ancho: ancho, negrita: true);
    }

    final modos = ['MEAS', 'SOURCE', 'MEAS/SRC', 'HART'];
    for (var i = 0; i < modos.length; i++) {
      tecla(
        modos[i],
        Offset(w * (0.17 + i * 0.22), h * 0.6),
        w * 0.19,
        const Color(0xFF1565C0),
      );
    }
    final funciones = ['V mV', 'mA', 'Ω RTD', 'TC', 'Hz', 'Presión'];
    for (var i = 0; i < funciones.length; i++) {
      tecla(
        funciones[i],
        Offset(w * (0.2 + (i % 3) * 0.3), h * (0.67 + (i ~/ 3) * 0.06)),
        w * 0.25,
        const Color(0xFF546E7A),
      );
    }
    // Teclado numérico.
    final nums = [
      '7',
      '8',
      '9',
      '4',
      '5',
      '6',
      '1',
      '2',
      '3',
      '0',
      ',',
      'ENTER',
    ];
    for (var i = 0; i < nums.length; i++) {
      tecla(
        nums[i],
        Offset(w * (0.16 + (i % 3) * 0.13), h * (0.81 + (i ~/ 3) * 0.04)),
        w * 0.11,
        const Color(0xFF263238),
      );
    }
    // Flechas (triángulos dibujados) y SETUP/CLEAR.
    final cx = w * 0.74, cy = h * 0.885;
    final flecha = Paint()..color = Colors.white;
    for (final o in const [
      Offset(0, -1),
      Offset(0, 1),
      Offset(-1, 0),
      Offset(1, 0),
    ]) {
      final c = Offset(cx + o.dx * w * 0.09, cy + o.dy * h * 0.04);
      tecla('', c, w * 0.08, const Color(0xFF263238));
      final r = w * 0.018;
      // Punta en la dirección o, base perpendicular.
      final perp = Offset(-o.dy, o.dx);
      canvas.drawPath(
        Path()
          ..moveTo(c.dx + o.dx * r, c.dy + o.dy * r)
          ..lineTo(c.dx - o.dx * r + perp.dx * r, c.dy - o.dy * r + perp.dy * r)
          ..lineTo(c.dx - o.dx * r - perp.dx * r, c.dy - o.dy * r - perp.dy * r)
          ..close(),
        flecha,
      );
    }
    tecla(
      'SETUP',
      Offset(w * 0.645, h * 0.79),
      w * 0.17,
      const Color(0xFF6A1B9A),
    );
    tecla(
      'CLEAR',
      Offset(w * 0.835, h * 0.79),
      w * 0.17,
      const Color(0xFF6A1B9A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
