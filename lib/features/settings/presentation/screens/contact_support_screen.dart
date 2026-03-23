import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ricesafe_app/features/settings/presentation/support_contact_constants.dart';
import 'package:ricesafe_app/main.dart';

/// ช่วยเหลือ / ติดต่อทีมโครงการ RiceSafe
class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: kRiceSafeSupportEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('คัดลอกอีเมลแล้ว')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ติดต่อเรา'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  riceSafeGreen.withValues(alpha: 0.12),
                  riceSafeGreen.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: riceSafeGreen.withValues(alpha: 0.25)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: riceSafeGreen.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.mail_outline, color: riceSafeGreen, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'อีเมล',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              kRiceSafeSupportEmail,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _copyEmail(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: riceSafeGreen,
                        side: BorderSide(color: riceSafeGreen.withValues(alpha: 0.6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.copy, size: 20),
                      label: const Text('คัดลอกอีเมล'),
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
