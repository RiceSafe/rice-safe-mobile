import 'package:dio/dio.dart';

/// Parses API/Dio error text for repositories; use [userFacingMessage] in the UI.
String dioErrorDetail(DioException e) {
  final data = e.response?.data;
  if (data is Map) {
    final m = Map<String, dynamic>.from(data as Map);
    for (final key in ['error', 'details', 'message', 'detail']) {
      final v = m[key];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    final errs = m['errors'];
    if (errs is String && errs.isNotEmpty) return errs;
    if (errs is List && errs.isNotEmpty) {
      final parts = errs.map((x) => x.toString()).where((s) => s.isNotEmpty);
      final joined = parts.join(', ');
      if (joined.isNotEmpty) return joined;
    }
  }
  if (data is String && data.isNotEmpty) return data;
  return e.message ?? 'Request failed';
}
