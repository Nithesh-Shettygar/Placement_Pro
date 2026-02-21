import 'package:flutter/material.dart';
import 'package:placementpro/screens/admin/officer_view.dart';
import 'package:placementpro/screens/alumni/alumni_view.dart';
import 'package:placementpro/screens/student/student_view.dart';
import 'dart:convert';
import 'package:placementpro/services/api_service.dart';
import 'package:placementpro/auth/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final String role;
  final String roleType;

  const LoginPage({super.key, required this.role, required this.roleType});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showResetPasswordDialog(Color themeColor) {
    final resetEmail = TextEditingController();
    final resetName = TextEditingController();
    final resetNewPass = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Reset ${widget.role} Password",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: resetEmail,
              decoration: const InputDecoration(
                labelText: "Registered Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resetName,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resetNewPass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: themeColor),
            onPressed: () async {
              if (resetEmail.text.isEmpty ||
                  resetName.text.isEmpty ||
                  resetNewPass.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please fill all fields"),
                  ),
                );
                return;
              }

              try {
                final res = await ApiService.resetPassword(
                  resetEmail.text.trim(),
                  resetName.text.trim(),
                  resetNewPass.text.trim(),
                );

                if (mounted) Navigator.pop(context);

                final responseData = jsonDecode(res.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res.statusCode == 200
                          ? "Password Reset Successful! Please login."
                          : responseData['error'] ??
                              "Details do not match!",
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error connecting to server"),
                  ),
                );
              }
            },
            child: const Text(
              "Reset",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final userData = responseData['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(userData));
        await prefs.setString('userEmail', (userData['email'] ?? '').toString());
        await prefs.setString('userName', (userData['name'] ?? '').toString());
        await prefs.setString('roleType', widget.roleType);
        if (widget.roleType == 'student') {
          await prefs.setString('studentData', jsonEncode(userData));
          await prefs.setString('studentEmail', (userData['email'] ?? '').toString());
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Welcome, ${userData['name']}!")),
          );

          // Role-based Navigation
          Widget nextScreen;
          switch (widget.roleType) {
            case 'student':
              nextScreen = StudentDashboard(userData: userData);
              break;
            case 'officer':
              nextScreen = OfficerMainScreen(userData: userData);
              break;
            case 'alumni':
              nextScreen = AlumniDashboard(userData: userData);
              break;
            default:
              nextScreen = StudentDashboard(userData: userData);
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
            (route) => false,
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['error'] ?? "Invalid email or password"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error connecting to server: $e"),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Color _getThemeColor() {
    switch (widget.roleType) {
      case 'officer':
        return Colors.blue.shade600;
      case 'student':
        return Colors.teal.shade600;
      case 'alumni':
        return Colors.indigo.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: isDesktop ? 450 : double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    widget.roleType == 'officer'
                        ? Icons.admin_panel_settings
                        : widget.roleType == 'student'
                            ? Icons.school
                            : Icons.auto_awesome,
                    color: themeColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Login as ${widget.role}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials to continue',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),
                _buildInputField(
                  label: 'Email Address',
                  controller: emailController,
                  icon: Icons.alternate_email,
                  themeColor: themeColor,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Password',
                  controller: passwordController,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  themeColor: themeColor,
                ),

                // Forgot Password - Only for non-officer roles
                if (widget.roleType != 'officer')
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showResetPasswordDialog(themeColor),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Registration link - Not for officers
                if (widget.roleType != 'officer')
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationPage(
                              role: widget.role,
                              roleType: widget.roleType,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have an account? Create Account",
                        style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Text(
                      "Contact Administrator for access credentials",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color themeColor,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? !_isPasswordVisible : false,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: themeColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}