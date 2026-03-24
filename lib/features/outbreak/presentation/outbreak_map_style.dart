import 'package:flutter/material.dart';
import 'package:ricesafe_app/features/outbreak/data/models/outbreak_api_model.dart';

Color outbreakMarkerColor(OutbreakSummary o) {
  if (!o.isActive) return Colors.grey;
  if (o.isVerified) return Colors.green;
  return Colors.orange;
}
