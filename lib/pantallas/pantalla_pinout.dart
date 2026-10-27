import 'package:flutter/material.dart';

import '../datos/pinouts.dart';

class PantallaPinout extends StatefulWidget {
  final Pinout pinout;
  const PantallaPinout(this.pinout, {super.key});

  @override
  State<PantallaPinout> createState() => _PantallaPinoutState();
}

class _PantallaPinoutState extends State<PantallaPinout> {
  String? _elegido;

  void _elegir(String id) =>
      setState(() => _elegido = _elegido == id ? null : id);

  @override
  Widget build(BuildContext context) {
    final p = widget.pinout;
    final texto = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final porId = {for (final pin in p.pines) pin.id: pin};
    return Scaffold(
      appBar: AppBar(title: Text(p.titulo)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          if (p.descripcion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(p.descripcion, style: texto.bodyLarge),
            ),
          if (p.diagrama != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DibujoPinout(
                    p.diagrama!,
                    porId,
                    elegido: _elegido,
                    alTocar: _elegir,
                  ),
                ),
              ),
            ),
            if (p.diagrama!.vista != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  p.diagrama!.vista!,
                  textAlign: TextAlign.center,
                  style: texto.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
          ],
          for (final pin in p.pines)
            Material(
              color: pin.id == _elegido
                  ? esquema.secondaryContainer
                  : Colors.transparent,
              child: ListTile(
                dense: true,
                onTap: () => _elegir(pin.id),
                leading: CirculoPin(pin),
                title: Text(
                  pin.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: pin.descripcion.isEmpty
                    ? null
                    : Text(pin.descripcion),
              ),
            ),
          if (p.notas.isNotEmpty)
            Card(
              margin: const EdgeInsets.all(16),
              color: esquema.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final n in p.notas)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  '),
                            Expanded(child: Text(n)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Círculo con el número del pin, relleno con el color del cable si lo tiene.
class CirculoPin extends StatelessWidget {
  final Pin pin;
  final bool elegido;
  final double tamano;

  const CirculoPin(
    this.pin, {
    super.key,
    this.elegido = false,
    this.tamano = 34,
  });

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final fondo = pin.color ?? esquema.surfaceContainerHigh;
    final colorTexto = fondo.computeLuminance() > 0.45
        ? Colors.black
        : Colors.white;
    final etiqueta = pin.id;
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: pin.raya == null ? fondo : null,
        gradient: pin.raya == null
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [fondo, fondo, pin.raya!, pin.raya!, fondo, fondo],
                stops: const [0, 0.3, 0.3, 0.7, 0.7, 1],
              ),
        border: Border.all(
          color: elegido ? esquema.primary : Colors.grey.shade600,
          width: elegido ? 3 : 1,
        ),
      ),
      child: Text(
        etiqueta,
        maxLines: 1,
        style: TextStyle(
          fontSize: etiqueta.length <= 2 ? tamano * 0.4 : tamano * 0.28,
          fontWeight: FontWeight.bold,
          color: pin.color == null ? esquema.onSurface : colorTexto,
          shadows: pin.raya != null
              ? const [Shadow(blurRadius: 3, color: Colors.white)]
              : null,
        ),
      ),
    );
  }
}

/// Dibujo esquemático del conector o encapsulado.
class DibujoPinout extends StatelessWidget {
  final Diagrama diagrama;
  final Map<String, Pin> pines;
  final String? elegido;
  final ValueChanged<String> alTocar;

  const DibujoPinout(
    this.diagrama,
    this.pines, {
    super.key,
    this.elegido,
    required this.alTocar,
  });

  Widget _pin(String? id) {
    if (id == null) return const SizedBox(width: 40, height: 40);
    final pin = pines[id] ?? Pin(id, id);
    return Padding(
      padding: const EdgeInsets.all(3),
      child: GestureDetector(
        onTap: () => alTocar(id),
        child: CirculoPin(pin, elegido: id == elegido),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    switch (diagrama.tipo) {
      case TipoDiagrama.rejilla:
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: esquema.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: esquema.outline, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final fila in diagrama.filas)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [for (final id in fila) _pin(id)],
                ),
            ],
          ),
        );
      case TipoDiagrama.dip:
        final n = diagrama.filas.length;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(children: [for (final f in diagrama.filas) _pin(f[0])]),
            Container(
              width: 90,
              height: n * 40.0 + 10,
              decoration: BoxDecoration(
                color: const Color(0xFF263238),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 26,
                      height: 13,
                      decoration: const BoxDecoration(
                        color: Color(0xFF546E7A),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(13),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 8,
                    top: 18,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFF546E7A),
                    ),
                  ),
                  Center(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        diagrama.cuerpo ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(children: [for (final f in diagrama.filas) _pin(f[1])]),
          ],
        );
      case TipoDiagrama.fila:
        final ids = diagrama.filas.first;
        final ancho = ids.length * 46.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ancho + 16,
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF263238),
                borderRadius: diagrama.cuerpo == 'TO-92'
                    ? const BorderRadius.vertical(
                        top: Radius.circular(40),
                        bottom: Radius.circular(4),
                      )
                    : BorderRadius.circular(4),
              ),
              child: Text(
                diagrama.cuerpo ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final id in ids)
                  SizedBox(
                    width: 46,
                    child: Column(
                      children: [
                        Container(width: 4, height: 30, color: Colors.grey),
                        _pin(id),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
    }
  }
}
