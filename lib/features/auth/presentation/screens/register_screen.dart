import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'สร้างบัญชี',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Logo Section
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/rice_icon.png',
                    height: 100,
                    errorBuilder:
                        (ctx, err, _) => const Icon(
                          Icons.agriculture,
                          size: 80,
                          color: Colors.brown,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'RiceSafe',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2433),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Fields
            _buildLabel('ชื่อผู้ใช้'),
            _buildTextField(
              controller: _usernameController,
              hintText: 'กรอกชื่อผู้ใช้',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            _buildLabel('อีเมล'),
            _buildTextField(
              controller: _emailController,
              hintText: 'กรอกที่อยู่อีเมล',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),

            _buildLabel('รหัสผ่าน'),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'กรอกรหัสผ่าน',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.black87,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: riceSafeGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'สร้างบัญชี',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'มีบัญชีอยู่แล้ว? ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    GoRouter.of(context).go('/login');
                  },
                  child: const Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(
                      color: riceSafeGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[700], fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.black87),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
