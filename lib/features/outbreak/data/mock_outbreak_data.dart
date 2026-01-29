import 'package:flutter/material.dart';

enum Severity { low, moderate, high }

class OutbreakLocation {
  final String id;
  final String diseaseName;
  final String province;
  final String district;
  final DateTime date;
  final Severity severity;
  final double latitude;
  final double longitude;
  final bool isVerified;
  final String? imagePath;

  OutbreakLocation({
    required this.id,
    required this.diseaseName,
    required this.province,
    required this.district,
    required this.date,
    required this.severity,
    required this.latitude,
    required this.longitude,
    this.isVerified = false,
    this.imagePath,
  });
}

// Mock Data List
final List<OutbreakLocation> mockOutbreaks = [
  OutbreakLocation(
    id: '1',
    diseaseName: 'โรคไหม้',
    province: 'เชียงใหม่',
    district: 'แม่ริม',
    date: DateTime.now().subtract(const Duration(days: 2)),
    severity: Severity.high,
    latitude: 18.9,
    longitude: 98.9,
    isVerified: true,
    imagePath: 'assets/mock/rice_blast.jpg',
  ),
  OutbreakLocation(
    id: '2',
    diseaseName: 'โรคขอบใบแห้ง',
    province: 'สุพรรณบุรี',
    district: 'เมือง',
    date: DateTime.now().subtract(const Duration(days: 5)),
    severity: Severity.moderate,
    latitude: 14.5,
    longitude: 100.1,
    isVerified: true,
    imagePath: 'assets/mock/leaf_blight.jpg',
  ),
  OutbreakLocation(
    id: '3',
    diseaseName: 'โรคใบขีดโปร่งแสง',
    province: 'ปทุมธานี',
    district: 'คลองหลวง',
    date: DateTime.now().subtract(const Duration(days: 1)),
    severity: Severity.high,
    latitude: 14.0,
    longitude: 100.6,
    isVerified: false,
    imagePath: 'assets/mock/leaf_streak.jpg',
  ),
  OutbreakLocation(
    id: '4',
    diseaseName: 'โรคใบจุดสีน้ำตาล',
    province: 'ขอนแก่น',
    district: 'ชุมแพ',
    date: DateTime.now().subtract(const Duration(days: 10)),
    severity: Severity.low,
    latitude: 16.4,
    longitude: 102.1,
    isVerified: false,
    imagePath: 'assets/mock/brown_spot.jpg',
  ),
];

Color getSeverityColor(Severity severity) {
  switch (severity) {
    case Severity.high:
      return Colors.red;
    case Severity.moderate:
      return Colors.orange;
    case Severity.low:
      return Colors.amber;
  }
}

String getSeverityText(Severity severity) {
  switch (severity) {
    case Severity.high:
      return 'รุนแรง';
    case Severity.moderate:
      return 'ปานกลาง';
    case Severity.low:
      return 'เฝ้าระวัง';
  }
}
