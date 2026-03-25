/// Preset labels for rice growth stage on the diagnosis screen (dropdown only; no free typing).
class RiceGrowthStageOptions {
  RiceGrowthStageOptions._();

  static const String unspecifiedLabel = 'ไม่ระบุ';

  static const List<String> presets = <String>[
    'ระยะกล้า',
    'ระยะแตกกอ',
    'ระยะตั้งท้อง',
    'ระยะออกรวง',
    'ระยะสุกแก่ / ระยะเก็บเกี่ยว',
  ];
}
