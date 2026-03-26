import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ricesafe_app/main.dart';

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
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          32 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: SingleChildScrollView(
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
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'v $versionLabel',
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
            'RiceSafe ช่วยให้ชาวนาและผู้สนใจตรวจสอบอาการโรคในข้าวจากภาพและคำอธิบายอาการ ค้นหาความรู้จากคลัง '
            'ติดตามการแจ้งเตือนและแผนที่การระบาด และใช้ชุมชนแลกเปลี่ยนประสบการณ์',
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
                    child: Icon(Icons.gavel_outlined, color: riceSafeGreen),
                  ),
                  title: const Text('ข้อกำหนดการใช้งาน'),
                  subtitle: Text(
                    'ข้อจำกัดความรับผิดและการใช้งานในกรอบโปรเจกต์การศึกษา',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLegalStub(
                    context,
                    'ข้อกำหนดการใช้งาน',
                    'RiceSafe จัดทำขึ้นในกรอบโปรเจกต์ทางการศึกษา ผลการวินิจฉัยจากภาพและคำอธิบายอาการ '
                    'รวมถึงเนื้อหาในคลังความรู้ แผนที่ และชุมชน มีไว้เพื่อช่วยประกอบการตัดสินใจเท่านั้น '
                    'ไม่ใช่คำวินิจฉัยหรือคำแนะนำทางการเกษตรหรือการรักษาโรคพืชอย่างเป็นทางการ '
                    'ผู้ใช้ควรปรึกษาเจ้าหน้าที่หรือผู้เชี่ยวชาญในพื้นที่เมื่อต้องการความแม่นยำในการจัดการแปลง\n\n'
                    'ทีมพัฒนาไม่รับประกันความถูกต้องสมบูรณ์ของผลลัพธ์ ความต่อเนื่องของบริการ '
                    'หรือความเหมาะสมกับกรณีใดกรณีหนึ่ง ผู้ใช้ตกลงใช้แอปด้วยความเสี่ยงของตนเอง '
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              '© ${DateTime.now().year} RiceSafe',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}
