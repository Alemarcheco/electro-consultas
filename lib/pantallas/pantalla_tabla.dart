import 'package:flutter/material.dart';

import '../datos/referencias.dart';

class PantallaTabla extends StatelessWidget {
  final Tabla tabla;
  const PantallaTabla(this.tabla, {super.key});

  Widget _muestra(int fila) {
    final color = tabla.colores?[fila];
    if (color == null) return const SizedBox(width: 22);
    final raya = tabla.rayas?[fila];
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade600),
        color: raya == null ? color : null,
        gradient: raya == null
            ? null
            : LinearGradient(
                colors: [color, color, raya, raya, color, color],
                stops: const [0, 0.33, 0.33, 0.66, 0.66, 1],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(tabla.titulo)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          if (tabla.descripcion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(tabla.descripcion, style: texto.bodyLarge),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DataTable(
              columnSpacing: 20,
              horizontalMargin: 8,
              dataRowMinHeight: 40,
              dataRowMaxHeight: double.infinity,
              headingTextStyle: texto.titleSmall?.copyWith(
                color: esquema.primary,
              ),
              columns: [
                for (final c in tabla.columnas) DataColumn(label: Text(c)),
              ],
              rows: [
                for (var i = 0; i < tabla.filas.length; i++)
                  DataRow(
                    color: WidgetStatePropertyAll(
                      i.isOdd
                          ? esquema.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            )
                          : null,
                    ),
                    cells: [
                      for (var j = 0; j < tabla.columnas.length; j++)
                        DataCell(
                          j == 0 && tabla.colores != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _muestra(i),
                                    const SizedBox(width: 8),
                                    Text(
                                      tabla.filas[i][j],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 260,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      j < tabla.filas[i].length
                                          ? tabla.filas[i][j]
                                          : '',
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
          if (tabla.notas.isNotEmpty)
            Card(
              margin: const EdgeInsets.all(16),
              color: esquema.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final n in tabla.notas)
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
