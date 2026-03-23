import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ricesafe_app/main.dart';

/// เกี่ยวกับแอป RiceSafe — เวอร์ชัน คำอธิบาย ลิงก์ข้อมูลทางกฎหมายแบบย่อ
class AboutRiceSafeScreen extends StatefulWidget {
  const AboutRiceSafeScreen({super.key});

  @override
  State<AboutRiceSafeScreen> createState() => _AboutRiceSafeScreenState();
}

class _AboutRiceSafeScreenState extends State<AboutRiceSafeScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _packageInfo = info);
    });
  }

  void _showLegalStub(BuildContext context, String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final versionLabel = _packageInfo != null
        ? '${_packageInfo!.version} (${_packageInfo!.buildNumber})'
        : '…';

    return Scaffold(
      appBar: AppBar(
        title: const Text('เกี่ยวกับ RiceSafe'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: riceSafeGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/rice_icon.png',
                width: 72,
                height: 72,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.grass,
                  size: 72,
                  color: riceSafeGreen,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'RiceSafe',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'เพื่อนชาวนาในการดูแลข้าวและโรคระบาด',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.35,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'เวอร์ชัน $versionLabel',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'แอปนี้ทำอะไร',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'RiceSafe ช่วยให้ชาวนาและผู้สนใจตรวจสอบอาการโรคในข้าวจากภาพ ค้นหาความรู้จากคลัง '
            'ติดตามการแจ้งเตือนและแผนที่การระบาด และใช้ชุมชนแลกเปลี่ยนประสบการณ์ — '
            'พัฒนาในกรอบโปรเจกต์ทางการศึกษา',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: riceSafeGreen.withValues(alpha: 0.12),
                    child: Icon(Icons.privacy_tip_outlined, color: riceSafeGreen),
                  ),
                  title: const Text('นโยบายความเป็นส่วนตัว'),
                  subtitle: Text(
                    'การเก็บและใช้ข้อมูลส่วนบุคคล',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLegalStub(
                    context,
                    'นโยบายความเป็นส่วนตัว',
                    'เอกสารฉบับเต็มจะเผยแพร่เมื่อโครงการกำหนดรายละเอียดขั้นสุดท้าย '
                    'หากมีข้อสงสัยด้านข้อมูลส่วนบุคคล สามารถติดต่อทีมผ่านเมนู "ติดต่อเรา" ได้',
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: riceSafeGreen.withValues(alpha: 0.12),
                    child: Icon(Icons.gavel_outlined, color: riceSafeGreen),
                  ),
                  title: const Text('ข้อกำหนดการใช้งาน'),
                  subtitle: Text(
                    'ขอบเขตความรับผิดและการใช้บริการ',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLegalStub(
                    context,
                    'ข้อกำหนดการใช้งาน',
                    'ผลการวินิจฉัยและข้อมูลในแอปใช้ประกอบการตัดสินใจเท่านั้น ไม่ทดแทนคำแนะนำจากผู้เชี่ยวชาญในสนาม '
                    'ข้อกำหนดฉบับสมบูรณ์จะแจ้งให้ทราบเมื่อเผยแพร่อย่างเป็นทางการ',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              '© ${DateTime.now().year} โครงการ RiceSafe',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}
