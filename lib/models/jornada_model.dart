class JornadaModel {
  final String id;
  final String lottery; // Lottery type
  final String turno; // 'mañana' or 'tarde'
  final String estado; // 'pendiente', 'abierta', 'cerrada', 'procesada'
  final List<PickEntry> picks; // Ticket picks submitted
  final List<PremioEntry> premios; // Prize results
  final DateTime? fechaApertura;
  final DateTime? fechaCierre;
  final String? aperturaHora;
  final String? aperturaFecha;
  final String? cierreHora;
  final String? cierreFecha;
  final double totalRecaudado;
  final double recaudadoTotal;
  final String resumen;
  final String pick3;
  final String pick4;
  final int premiosProcesados;
  final int listerosCount;
  final int mensajesCount;
  final double totalPremios;
  final Map<String, double> jugadasPorListero;

  JornadaModel({
    required this.id,
    required this.lottery,
    required this.turno,
    required this.estado,
    this.picks = const [],
    this.premios = const [],
    this.fechaApertura,
    this.fechaCierre,
    this.aperturaHora,
    this.aperturaFecha,
    this.cierreHora,
    this.cierreFecha,
    this.totalRecaudado = 0.0,
    this.recaudadoTotal = 0.0,
    this.resumen = '',
    this.pick3 = '',
    this.pick4 = '',
    this.premiosProcesados = 0,
    this.listerosCount = 0,
    this.mensajesCount = 0,
    this.totalPremios = 0.0,
    this.jugadasPorListero = const {},
  });

  factory JornadaModel.fromJson(Map<String, dynamic> json) {
    return JornadaModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      lottery: json['loteria'] as String? ?? json['lottery'] as String? ?? '',
      turno: json['turno'] as String? ?? 'mañana',
      estado: json['estado'] as String? ?? 'pendiente',
      picks: json['picks'] != null
          ? (json['picks'] as List)
              .map((p) => PickEntry.fromJson(p as Map<String, dynamic>))
              .toList()
          : [],
      premios: json['premios'] != null
          ? (json['premios'] as List)
              .map((p) => PremioEntry.fromJson(p as Map<String, dynamic>))
              .toList()
          : [],
      fechaApertura: _parseDate(json['inicioReal']) ?? _parseDate(json['inicio']) ?? _parseDate(json['fechaApertura']),
      fechaCierre: _parseDate(json['finReal']) ?? _parseDate(json['fin']) ?? _parseDate(json['fechaCierre']),
      aperturaHora: json['aperturaHora'] as String?,
      aperturaFecha: json['aperturaFecha'] as String?,
      cierreHora: json['cierreHora'] as String?,
      cierreFecha: json['cierreFecha'] as String?,
      totalRecaudado: (json['totalRecaudado'] as num?)?.toDouble() ??
          (json['recaudadoTotal'] as num?)?.toDouble() ?? 0.0,
      recaudadoTotal: (json['recaudadoTotal'] as num?)?.toDouble() ?? 0.0,
      resumen: json['resumen'] as String? ?? '',
      pick3: json['pick3'] as String? ?? '',
      pick4: json['pick4'] as String? ?? '',
      premiosProcesados: _parseIntOrBool(json['premiosProcesados']),
      listerosCount: json['listerosCount'] as int? ?? 0,
      mensajesCount: json['mensajesCount'] as int? ?? 0,
      totalPremios: (json['totalPremios'] as num?)?.toDouble() ?? 0.0,
      jugadasPorListero: json['jugadasPorListero'] is Map
          ? (json['jugadasPorListero'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble()))
          : {},
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static int _parseIntOrBool(dynamic value) {
    if (value == null) return 0;
    if (value is bool) return value ? 1 : 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'loteria': lottery,
      'turno': turno,
      'estado': estado,
      'picks': picks.map((p) => p.toJson()).toList(),
      'premios': premios.map((p) => p.toJson()).toList(),
      'totalRecaudado': totalRecaudado,
      'resumen': resumen,
      'pick3': pick3,
      'pick4': pick4,
      'premiosProcesados': premiosProcesados,
      'listerosCount': listerosCount,
      'totalPremios': totalPremios,
    };
  }

  String get turnoLabel {
    switch (turno.toLowerCase()) {
      case 'mañana': return '🌅 Mañana';
      case 'tarde': return '🌇 Tarde';
      default: return turno;
    }
  }

  String get estadoLabel {
    switch (estado.toLowerCase()) {
      case 'activa': return '🟢 Activa';
      case 'abierta': return '🟢 Activa';
      case 'cerrada': return '🔴 Cerrada';
      case 'procesada': return '✅ Procesada';
      case 'pendiente': return '⏳ Pendiente';
      default: return estado;
    }
  }

  bool get isActive => estado.toLowerCase() == 'activa' || estado.toLowerCase() == 'abierta' || estado == 'pendiente';
  bool get isClosed => estado.toLowerCase() == 'cerrada' || estado.toLowerCase() == 'procesada';
}

class PickEntry {
  final String numero; // Lottery number
  final double monto; // Amount
  final String ubicacion; // Position
  final String listero; // Listero phone

  PickEntry({
    required this.numero,
    required this.monto,
    this.ubicacion = '',
    this.listero = '',
  });

  factory PickEntry.fromJson(Map<String, dynamic> json) {
    return PickEntry(
      numero: json['numero']?.toString() ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      ubicacion: json['ubicacion'] as String? ?? '',
      listero: json['listero'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'monto': monto,
      'ubicacion': ubicacion,
      'listero': listero,
    };
  }
}

class PremioEntry {
  final String numero;
  final String premio;
  final double monto;

  PremioEntry({
    required this.numero,
    required this.premio,
    required this.monto,
  });

  factory PremioEntry.fromJson(Map<String, dynamic> json) {
    return PremioEntry(
      numero: json['numero']?.toString() ?? '',
      premio: json['premio']?.toString() ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'premio': premio,
      'monto': monto,
    };
  }
}
