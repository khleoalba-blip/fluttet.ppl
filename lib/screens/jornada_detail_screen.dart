import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/jornada_model.dart';
import '../providers/jornadas_provider.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/status_badge.dart';

class JornadaDetailScreen extends StatefulWidget {
  const JornadaDetailScreen({super.key});

  @override
  State<JornadaDetailScreen> createState() => _JornadaDetailScreenState();
}

class _JornadaDetailScreenState extends State<JornadaDetailScreen> {
  late String _groupId;
  late String _jornadaId;
  JornadaModel? _initialJornada;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && !_loaded) {
      _groupId = args['groupId'] as String;
      _jornadaId = args['jornadaId'] as String;
      _initialJornada = args['jornada'] as JornadaModel?;
      _loaded = true;
      context
          .read<JornadasProvider>()
          .loadJornadaDetail(_groupId, _jornadaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<JornadasProvider>();
    final jornada = provider.selectedJornada ?? _initialJornada;

    return Scaffold(
      appBar: AppBar(
        title: Text(jornada != null
            ? 'Jornada ${jornada.turnoLabel}'
            : 'Detalle de Jornada'),
      ),
      body: LoadingOverlay(
        isLoading: provider.isLoadingDetail,
        message: 'Cargando detalles...',
        child: jornada == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () =>
                    provider.loadJornadaDetail(_groupId, _jornadaId),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ━━━ HEADER: ESTADO DEL GRUPO ━━━
                      _buildStatusHeader(theme, jornada),
                      const SizedBox(height: 16),

                      // ━━━ JORNADA ACTIVA ━━━
                      _buildJornadaCard(theme, jornada),
                      const SizedBox(height: 16),

                      // ━━━ JUGADAS REGISTRADAS ━━━
                      _buildJugadasSection(theme, jornada),

                      // ━━━ RESULTADOS (PICK3/PICK4) ━━━
                      if (jornada.pick3.isNotEmpty || jornada.pick4.isNotEmpty)
                        _buildResultadosSection(theme, jornada),

                      // ━━━ PREMIOS ━━━
                      if (jornada.premios.isNotEmpty)
                        _buildPremiosSection(theme, jornada),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // HEADER: Copia exacta del .status
  // ══════════════════════════════════════════════════
  Widget _buildStatusHeader(ThemeData theme, JornadaModel jornada) {
    final backgroundColor = jornada.isActive
        ? Colors.green.withOpacity(0.08)
        : theme.colorScheme.surfaceVariant.withOpacity(0.5);

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                '📊 ESTADO DEL GRUPO',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Divider(height: 20),
            // Admin
            _statusRow(theme, '👤 Admin:', '—', Icons.admin_panel_settings),
            const SizedBox(height: 4),
            // Lotería
            _statusRow(theme, '🎰 Lotería:', jornada.lottery.isNotEmpty ? jornada.lottery : 'Florida', Icons.casino),
            const SizedBox(height: 4),
            // Automático
            _statusRow(theme, '🤖 Automático:', '✅ Activado', Icons.smart_toy),
            const SizedBox(height: 4),
            // Banca
            _statusRow(theme, '🏦 Banca:', '—', Icons.account_balance),
            const SizedBox(height: 4),
            // Listeros
            _statusRow(theme, '📋 Listeros:', '${jornada.listerosCount} registrados', Icons.people),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // JORNADA CARD: ID, Lotería, Turno, Horarios
  // ══════════════════════════════════════════════════
  Widget _buildJornadaCard(ThemeData theme, JornadaModel jornada) {
    final emoji = jornada.turno == 'mañana' ? '☀️' : '🌇';
    final color = jornada.isActive ? Colors.green : Colors.blueGrey;

    return Card(
      color: color.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jornada ${jornada.isActive ? "🟢 ACTIVA" : "🔴 ${jornada.estado.toUpperCase()}"}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            // ID
            _jornadaInfoRow(theme, '🆔', 'ID:', jornada.id.isNotEmpty ? jornada.id : '—'),
            const SizedBox(height: 4),
            // Lotería + Turno
            _jornadaInfoRow(theme, '🎰', 'Lotería:', '${jornada.lottery.isNotEmpty ? jornada.lottery : "Florida"} | $emoji ${jornada.turno}'),
            const SizedBox(height: 4),
            // Apertura
            _jornadaInfoRow(
              theme,
              '⏰',
              'Inicio real:',
              jornada.aperturaHora != null
                  ? jornada.aperturaHora!
                  : jornada.aperturaFecha != null
                      ? jornada.aperturaFecha!
                      : '—',
            ),
            const SizedBox(height: 4),
            // Cierre prog
            _jornadaInfoRow(theme, '⏰', 'Cierre prog.:', '—'),
            const SizedBox(height: 4),
            // Resultados
            _jornadaInfoRow(theme, '🎯', 'Resultados:', '—'),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // JUGADAS REGISTRADAS
  // ══════════════════════════════════════════════════
  Widget _buildJugadasSection(ThemeData theme, JornadaModel jornada) {
    final detalle = jornada.listerosDetalle;
    final hasData = detalle.isNotEmpty;

    // Calcular total
    double totalAcumulado = 0;
    for (final d in detalle.values) {
      totalAcumulado += d.total;
    }
    if (totalAcumulado == 0 && jornada.totalRecaudado > 0) {
      totalAcumulado = jornada.totalRecaudado;
    }

    // Listeros que enviaron
    final listerosQueEnviaron = detalle.keys.toSet();
    if (listerosQueEnviaron.isEmpty && jornada.jugadasPorListero.isNotEmpty) {
      listerosQueEnviaron.addAll(jornada.jugadasPorListero.keys);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '👥 Jugadas registradas',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Divider(),
        // Mensajes
        _jugadaInfoRow(theme, '📩', 'Mensajes:', '${jornada.mensajesCount}'),
        const SizedBox(height: 2),
        // Listeros que enviaron
        _jugadaInfoRow(theme, '👤', 'Listeros que enviaron:', '${listerosQueEnviaron.length}'),
        const SizedBox(height: 8),

        if (!hasData && jornada.mensajesCount == 0)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No hay jugadas registradas',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else ...[
          // Per-listero breakdown cards
          ...detalle.entries.map((entry) {
            final nombre = entry.key;
            final d = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.green.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + total
                    Row(
                      children: [
                        const Text('🟢 ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            '$nombre: ${d.total.toStringAsFixed(0)} CUP',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    // Category breakdown
                    if (d.categorias.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 22),
                        child: Text(
                          d.categorias.entries
                              .map((c) => '${c.key}: ${c.value.toStringAsFixed(0)}')
                              .join(' | '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          // Total acumulado
          const Divider(),
          _jugadaInfoRow(
            theme,
            '💰',
            'Total acumulado:',
            '${totalAcumulado.toStringAsFixed(0)} CUP',
            bold: true,
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════
  // RESULTADOS: PICK3 / PICK4
  // ══════════════════════════════════════════════════
  Widget _buildResultadosSection(ThemeData theme, JornadaModel jornada) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '🎯 Resultados',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Divider(),
        Card(
          color: Colors.amber.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (jornada.pick3.isNotEmpty)
                  _resultadoBox(theme, 'PICK 3', jornada.pick3, Colors.orange),
                if (jornada.pick4.isNotEmpty)
                  _resultadoBox(theme, 'PICK 4', jornada.pick4, Colors.deepPurple),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _resultadoBox(ThemeData theme, String label, String numbers, Color color) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            numbers,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 4,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════
  // PREMIOS
  // ══════════════════════════════════════════════════
  Widget _buildPremiosSection(ThemeData theme, JornadaModel jornada) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '🏆 Premios',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Divider(),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: jornada.premios.map((premio) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      premio.numero,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(premio.premio),
                  trailing: Text(
                    '\$${premio.monto.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════
  Widget _statusRow(ThemeData theme, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.w600)),
                const TextSpan(text: ' '),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _jornadaInfoRow(ThemeData theme, String emoji, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _jugadaInfoRow(ThemeData theme, String emoji, String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.bold : null,
              ),
              children: [
                TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
