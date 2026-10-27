import 'package:flutter/material.dart';

/// Guía de uso de un equipo, dividida en capítulos.
class Guia {
  final String titulo;
  final String subtitulo;
  final List<Capitulo> capitulos;
  const Guia(this.titulo, this.subtitulo, this.capitulos);
}

class Capitulo {
  final String titulo;
  final String resumen;
  final IconData icono;
  final List<Bloque> bloques;
  final List<String> palabras;
  const Capitulo(
    this.titulo,
    this.resumen,
    this.icono,
    this.bloques, {
    this.palabras = const [],
  });
}

sealed class Bloque {
  const Bloque();
}

class Subtitulo extends Bloque {
  final String texto;
  const Subtitulo(this.texto);
}

class Parrafo extends Bloque {
  final String texto;
  const Parrafo(this.texto);
}

class Pasos extends Bloque {
  final List<String> pasos;
  const Pasos(this.pasos);
}

class Vinetas extends Bloque {
  final List<String> items;
  const Vinetas(this.items);
}

class Nota extends Bloque {
  final String texto;
  final bool peligro;
  const Nota(this.texto, {this.peligro = false});
}

class TablaGuia extends Bloque {
  final List<String> columnas;
  final List<List<String>> filas;
  const TablaGuia(this.columnas, this.filas);
}

/// Dibujo esquemático del frente del calibrador.
class DibujoEquipo extends Bloque {
  const DibujoEquipo();
}

/// Esquema de conexión entre equipos (2 o 3 columnas).
class Conexion extends Bloque {
  final String titulo;
  final List<EquipoDibujo> equipos;
  final List<Cable> cables;
  const Conexion(this.titulo, this.equipos, this.cables);
}

class EquipoDibujo {
  final String nombre;
  final List<Borne> bornes;
  final Color color;
  const EquipoDibujo(
    this.nombre,
    this.bornes, {
    this.color = const Color(0xFF455A64),
  });
}

/// Lado del recuadro donde se dibuja el borne.
enum Lado { izquierda, derecha }

class Borne {
  final String etiqueta;
  final Color color;
  final Lado? lado;
  const Borne(this.etiqueta, {this.color = const Color(0xFF9E9E9E), this.lado});
}

enum TipoCable { electrico, manguera }

class Cable {
  /// (índice del equipo, índice del borne).
  final (int, int) desde;
  final (int, int) hasta;
  final Color color;
  final String? etiqueta;
  final TipoCable tipo;
  const Cable(
    this.desde,
    this.hasta,
    this.color, {
    this.etiqueta,
    this.tipo = TipoCable.electrico,
  });
}

// Colores habituales de las puntas.
const rojoPunta = Color(0xFFD32F2F);
const negroPunta = Color(0xFF212121);
const azulCable = Color(0xFF1E88E5);
const verdeCable = Color(0xFF43A047);
const amarilloCable = Color(0xFFF9A825);
const grisManguera = Color(0xFF78909C);
