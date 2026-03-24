import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/notifications/data/models/notification_api_models.dart';
import 'package:ricesafe_app/features/notifications/data/notification_display_localizer.dart';

NotificationDto _dto({
  required String title,
  required String body,
  String type = 'OUTBREAK_NEARBY',
}) {
  return NotificationDto(
    id: '1',
    userId: 'u',
    title: title,
    body: body,
    type: type,
    referenceId: null,
    isRead: false,
    createdAt: DateTime(2026, 3, 23),
  );
}

void main() {
  group('NotificationDisplayLocalizer', () {
    test('localizes English outbreak template to Thai (title case variants)', () {
      final capitalized = _dto(
        title: 'Disease Alert: โรคไหม้',
        body:
            'A new case of โรคไหม้ has been diagnosed near your location. Please check your crops.',
      );
      expect(
        NotificationDisplayLocalizer.titleForDisplay(capitalized),
        'แจ้งเตือน: โรคไหม้',
      );
      expect(
        NotificationDisplayLocalizer.bodyForDisplay(capitalized),
        contains('พบการวินิจฉัย โรคไหม้'),
      );
      expect(
        NotificationDisplayLocalizer.bodyForDisplay(capitalized),
        contains('แนะนำให้ตรวจนาและเฝ้าระวังอาการ'),
      );

      final lowerTitle = _dto(
        title: 'disease alert: โรคใบไหม้',
        body:
            'A new case of โรคใบไหม้ has been diagnosed near your location. Please check your crops.',
      );
      expect(
        NotificationDisplayLocalizer.titleForDisplay(lowerTitle),
        'แจ้งเตือน: โรคใบไหม้',
      );
    });

    test('already Thai title passes through when regex does not match', () {
      final n = _dto(
        title: 'แจ้งเตือน: โรคไหม้',
        body:
            'มีรายงานการวินิจฉัย โรคไหม้ ในพื้นที่ใกล้เคียงกับตำแหน่งแปลงของท่าน',
      );
      expect(
        NotificationDisplayLocalizer.titleForDisplay(n),
        'แจ้งเตือน: โรคไหม้',
      );
      expect(
        NotificationDisplayLocalizer.bodyForDisplay(n),
        n.body,
      );
    });

    test('non-outbreak type unchanged', () {
      final n = _dto(
        title: 'System',
        body: 'Hello',
        type: 'OTHER',
      );
      expect(NotificationDisplayLocalizer.titleForDisplay(n), 'System');
      expect(NotificationDisplayLocalizer.bodyForDisplay(n), 'Hello');
    });
  });
}
