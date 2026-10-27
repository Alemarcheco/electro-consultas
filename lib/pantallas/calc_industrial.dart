import 'package:flutter/material.dart';

import '../formato.dart';
import '../widgets.dart';

// ───────────────────────── Escalado 4–20 mA ─────────────────────────

/// Señales analógicas: (nombre, mínimo, máximo, unidad).
const senalesAnalogicas = <(String, double, double, String)>[
  ('4–20 mA', 4, 20, 'mA'),
  ('0–20 mA', 0, 20, 'mA'),
  ('0–10 V', 0, 10, 'V'),
  ('1–5 V', 1, 5, 'V'),
];

/// Convierte una señal en el valor de proceso, de forma lineal.
double escalar(
  double senal,
  double sMin,
  double sMax,
  double vMin,
  double vMax,
) => vMin + (senal - sMin) / (sMax - sMin) * (vMax - vMin);

class Escalado420 extends StatefulWidget {
  const Escalado420({super.key});
  @override
  State<Escalado420> createState() => _Escalado420State();
}

class _Escalado420State extends EstadoCalculo<Escalado420> {
  late final _senalTipo = reg(Modo(0));
  late final _vMin = simple('', ini: '0');
  late final _vMax = simple('', ini: '10');
  late final _unidad = TextEditingController(text: 'bar');
  late final _senal = simple('', ini: '12');
  late final _valor = simple('', ini: '5');

  @override
  void initState() {
    super.initState();
    _unidad.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _unidad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (nombre, sMin, sMax, u) = senalesAnalogicas[_senalTipo.value];
    final vMin = _vMin.v, vMax = _vMax.v, senal = _senal.v, valor = _valor.v;
    final uv = _unidad.text.trim();
    final rangoOk = vMin != null && vMax != null && vMax != vMin;
    return PantallaCalculo(
      titulo: 'Escalado de señal analógica',
      formulas: [
        'Valor = mín. + (señal − ${fmt(sMin)}) / ${fmt(sMax - sMin)} × (máx. − mín.)',
        'Señal = ${fmt(sMin)} + (valor − mín.) / (máx. − mín.) × ${fmt(sMax - sMin)}',
        '4–20 mA: < 3,6 mA o > 21 mA = fallo del sensor o del cable (NAMUR NE43)',
        'Lectura en una resistencia de 250 Ω: V = I × 250 (4–20 mA → 1–5 V)',
      ],
      children: [
        SelectorModo(
          valor: _senalTipo.value,
          opciones: [
            for (var i = 0; i < senalesAnalogicas.length; i++)
              (i, senalesAnalogicas[i].$1),
          ],
          alCambiar: (v) => _senalTipo.value = v,
        ),
        const Titulo('Rango del sensor'),
        Row(
          children: [
            Expanded(
              child: CampoValor(
                _vMin,
                'Valor a ${fmt(sMin)} $u',
                conSigno: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CampoValor(
                _vMax,
                'Valor a ${fmt(sMax)} $u',
                conSigno: true,
              ),
            ),
          ],
        ),
        TextField(
          controller: _unidad,
          decoration: const InputDecoration(
            labelText: 'Unidad (bar, °C, m, %, m³/h…)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Titulo('De señal a valor'),
        CampoValor(_senal, 'Señal medida ($u)'),
        if (rangoOk && senal != null)
          Resultados(
            [
              ('Valor', '${fmt(escalar(senal, sMin, sMax, vMin, vMax))} $uv'),
              ('Porcentaje', '${fmt((senal - sMin) / (sMax - sMin) * 100)} %'),
            ],
            nota: nombre == '4–20 mA' && (senal < 3.6 || senal > 21)
                ? 'Fuera de rango: posible fallo del sensor o cable cortado.'
                : null,
          ),
        const Titulo('De valor a señal'),
        CampoValor(
          _valor,
          'Valor de proceso${uv.isEmpty ? '' : ' ($uv)'}',
          conSigno: true,
        ),
        if (rangoOk && valor != null)
          Resultados([
            ('Señal', '${fmt(escalar(valor, vMin, vMax, sMin, sMax))} $u'),
            if (u == 'mA')
              (
                'En 250 Ω',
                '${fmt(escalar(valor, vMin, vMax, sMin, sMax) * 0.25)} V',
              ),
          ]),
        if (!rangoOk)
          const Aviso(
            'Escribe el rango del sensor (mínimo y máximo distintos).',
          ),
      ],
    );
  }
}

// ───────────────────────── CRC Modbus ─────────────────────────

/// CRC-16/MODBUS (polinomio 0xA001 reflejado, valor inicial 0xFFFF).
int crcModbus(List<int> bytes) {
  var crc = 0xFFFF;
  for (final b in bytes) {
    crc ^= b;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xA001 : crc >> 1;
    }
  }
  return crc;
}

/// LRC de Modbus ASCII: complemento a dos de la suma de los bytes.
int lrcModbus(List<int> bytes) => (-bytes.fold(0, (a, b) => a + b)) & 0xFF;

/// Lee bytes en hexadecimal: "01 03 00 00 00 0A" o "010300000000A".
List<int>? leerHex(String texto) {
  final limpio = texto.replaceAll(
    RegExp(r'0x|[\s,;:-]', caseSensitive: false),
    '',
  );
  if (limpio.isEmpty ||
      limpio.length.isOdd ||
      !RegExp(r'^[0-9a-fA-F]+$').hasMatch(limpio)) {
    return null;
  }
  return [
    for (var i = 0; i < limpio.length; i += 2)
      int.parse(limpio.substring(i, i + 2), radix: 16),
  ];
}

String _hex(int b) => b.toRadixString(16).toUpperCase().padLeft(2, '0');

class CrcModbus extends StatefulWidget {
  const CrcModbus({super.key});
  @override
  State<CrcModbus> createState() => _CrcModbusState();
}

class _CrcModbusState extends State<CrcModbus> {
  final _trama = TextEditingController(text: '01 03 00 00 00 0A');

  @override
  void initState() {
    super.initState();
    _trama.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _trama.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bytes = leerHex(_trama.text);
    Widget res;
    if (bytes == null) {
      res = const Aviso(
        'Escribe los bytes en hexadecimal, por pares: 01 03 00 00 00 0A',
      );
    } else {
      final crc = crcModbus(bytes);
      final bajo = crc & 0xFF, alto = crc >> 8;
      res = Resultados(
        [
          ('CRC-16', '0x${_hex(alto)}${_hex(bajo)}'),
          ('Bytes a añadir', '${_hex(bajo)} ${_hex(alto)}'),
          ('Trama completa', [...bytes, bajo, alto].map(_hex).join(' ')),
          ('LRC (Modbus ASCII)', _hex(lrcModbus(bytes))),
          if (bytes.length >= 2)
            ('Esclavo / función', '${bytes[0]} / ${bytes[1]}'),
        ],
        nota: 'Si pegas una trama que ya trae el CRC al final, el CRC calculado sobre toda ella da 0x0000.',
      );
    }
    return PantallaCalculo(
      titulo: 'CRC Modbus',
      formulas: const [
        'Modbus RTU: CRC-16 con polinomio 0xA001 y valor inicial 0xFFFF.',
        'Se envía primero el byte BAJO y luego el alto.',
        'Ejemplo: 01 03 00 00 00 0A → leer 10 registros desde el 40001 del esclavo 1 → CRC C5 CD.',
      ],
      children: [
        TextField(
          controller: _trama,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
          decoration: const InputDecoration(
            labelText: 'Trama en hexadecimal (sin CRC)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        res,
      ],
    );
  }
}
