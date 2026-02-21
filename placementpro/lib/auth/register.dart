import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:placementpro/services/api_service.dart';

class RegistrationPage extends StatefulWidget {
  final String role;
  final String roleType;

  const RegistrationPage({
    super.key,
    required this.role,
    required this.roleType,
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final idController = TextEditingController();
  final batchController = TextEditingController();
  final orgController = TextEditingController();
  final designationController = TextEditingController();

  // State
  String? selectedGender;
  DateTime? selectedDOB;
  String? selectedSem;
  String selectedPosition = 'Working';
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final List<String> specializations = [
    'CS',
    'IT',
    'Electronics',
    'MBA',
    'MCA',
  ];
  final List<String> semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  String? selectedSpec;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    idController.dispose();
    batchController.dispose();
    orgController.dispose();
    designationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDOB = picked);
  }

  Future<void> _handleRegister() async {
    // Validate basic fields
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill basic details")),
      );
      return;
    }

    // Validate password match
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // Validate password strength
    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    // Validate email format
    if (!_isValidEmail(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.roleType == 'student') {
        // Validate student specific fields
        if (idController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter Campus ID")),
          );
          setState(() => isLoading = false);
          return;
        }

        Map<String, String> data = {
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "phone": phoneController.text.trim(),
          "password": passwordController.text.trim(),
          "roleType": widget.roleType,
          "campusId": idController.text.trim(),
          "specialization": selectedSpec ?? "",
          "gender": selectedGender ?? "",
          "currentSem": selectedSem ?? "",
        };

        // Add DOB if selected
        if (selectedDOB != null) {
          data["dob"] = "${selectedDOB!.toIso8601String().split('T')[0]}";
        }

        final response = await ApiService.registerStudentWithPhoto(
          data,
          _imageFile,
        );

        if (response.statusCode == 201) {
          _showSuccessDialog(context, _getThemeColor());
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['error'] ?? "Registration Failed");
        }
      } else if (widget.roleType == 'alumni') {
        // Validate alumni specific fields
        if (idController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter Campus ID")),
          );
          setState(() => isLoading = false);
          return;
        }

        if (batchController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter Batch")),
          );
          setState(() => isLoading = false);
          return;
        }

        if (orgController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter Organization/Startup Name")),
          );
          setState(() => isLoading = false);
          return;
        }

        if (selectedPosition == 'Working' && designationController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter Designation")),
          );
          setState(() => isLoading = false);
          return;
        }

        // For alumni, we need to send as JSON, not multipart
        Map<String, dynamic> data = {
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "phone": phoneController.text.trim(),
          "password": passwordController.text.trim(),
          "roleType": widget.roleType,
          "campusId": idController.text.trim(),
          "batch": batchController.text.trim(),
          "employmentStatus": selectedPosition,
          "organizationName": orgController.text.trim(),
          "designation": selectedPosition == 'Working'
              ? designationController.text.trim()
              : "Founder",
        };

        final response = await ApiService.register(data);
        
        if (response.statusCode == 201) {
          _showSuccessDialog(context, _getThemeColor());
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['error'] ?? "Registration Failed");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Color _getThemeColor() {
    if (widget.roleType == 'officer') return Colors.blue.shade600;
    if (widget.roleType == 'student') return Colors.teal.shade600;
    return Colors.indigo.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor();
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register as ${widget.role}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              // Photo Selection UI
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: themeColor.withOpacity(0.1),
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : null,
                        child: _imageFile == null
                            ? Icon(Icons.person, size: 55, color: themeColor)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: themeColor,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionLabel('Basic Details'),
              _buildInputField(
                label: 'Full Name',
                controller: nameController,
                icon: Icons.person_outline,
                themeColor: themeColor,
              ),
              const SizedBox(height: 15),
              _buildInputField(
                label: 'Phone Number',
                controller: phoneController,
                icon: Icons.phone_android,
                themeColor: themeColor,
                type: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              _buildInputField(
                label: 'Email Address',
                controller: emailController,
                icon: Icons.alternate_email,
                themeColor: themeColor,
                type: TextInputType.emailAddress,
              ),

              const SizedBox(height: 32),

              _buildSectionLabel('Institutional & Professional'),
              if (widget.roleType == 'student') ...[
                _buildInputField(
                  label: 'Campus ID',
                  controller: idController,
                  icon: Icons.badge_outlined,
                  themeColor: themeColor,
                ),
                const SizedBox(height: 15),
                _buildDropdownField(
                  label: 'Specialisation',
                  items: specializations,
                  themeColor: themeColor,
                  value: selectedSpec,
                  onChanged: (v) => setState(() => selectedSpec = v),
                ),
                const SizedBox(height: 15),
                _buildDropdownField(
                  label: 'Current Semester',
                  items: semesters,
                  themeColor: themeColor,
                  value: selectedSem,
                  onChanged: (v) => setState(() => selectedSem = v),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Date of Birth',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildDatePicker(themeColor),
                const SizedBox(height: 15),
                const Text(
                  'Gender',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                _buildGenderRadio(themeColor),
              ] else if (widget.roleType == 'alumni') ...[
                _buildInputField(
                  label: 'Old Campus ID',
                  controller: idController,
                  icon: Icons.history,
                  themeColor: themeColor,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Batch (e.g., 2020-2024)',
                  controller: batchController,
                  icon: Icons.calendar_today_outlined,
                  themeColor: themeColor,
                ),
                const SizedBox(height: 24),
                _buildPositionToggle(themeColor),
                const SizedBox(height: 24),
                _buildInputField(
                  label: selectedPosition == 'Working'
                      ? 'Company Name'
                      : 'Startup Name',
                  controller: orgController,
                  icon: Icons.business,
                  themeColor: themeColor,
                ),
                if (selectedPosition == 'Working') ...[
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'Designation',
                    controller: designationController,
                    icon: Icons.assignment_ind_outlined,
                    themeColor: themeColor,
                  ),
                ],
              ],

              const SizedBox(height: 32),
              _buildSectionLabel('Security'),
              _buildInputField(
                label: 'Password',
                controller: passwordController,
                icon: Icons.lock_outline,
                isPassword: true,
                themeColor: themeColor,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Confirm Password',
                controller: confirmPasswordController,
                icon: Icons.lock_reset_outlined,
                isPassword: true,
                themeColor: themeColor,
              ),
              const SizedBox(height: 40),
              _buildSubmitButton(themeColor),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildDatePicker(Color themeColor) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 15),
            Text(
              selectedDOB == null
                  ? 'Select Date'
                  : "${selectedDOB!.day}/${selectedDOB!.month}/${selectedDOB!.year}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderRadio(Color themeColor) {
    return Row(
      children: [
        Radio<String>(
          value: 'Male',
          groupValue: selectedGender,
          activeColor: themeColor,
          onChanged: (value) => setState(() => selectedGender = value),
        ),
        const Text('Male'),
        Radio<String>(
          value: 'Female',
          groupValue: selectedGender,
          activeColor: themeColor,
          onChanged: (value) => setState(() => selectedGender = value),
        ),
        const Text('Female'),
      ],
    );
  }

  Widget _buildSubmitButton(Color themeColor) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleRegister,
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
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
    TextInputType type = TextInputType.text,
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
          obscureText: isPassword
              ? (label.contains('Password') && label != 'Confirm Password'
                  ? !_isPasswordVisible
                  : label == 'Confirm Password'
                      ? !_isConfirmPasswordVisible
                      : false)
              : false,
          keyboardType: type,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (label.contains('Password') && label != 'Confirm Password'
                          ? _isPasswordVisible
                          : label == 'Confirm Password'
                              ? _isConfirmPasswordVisible
                              : false)
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: () {
                      setState(() {
                        if (label.contains('Password') && label != 'Confirm Password') {
                          _isPasswordVisible = !_isPasswordVisible;
                        } else if (label == 'Confirm Password') {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        }
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

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required Color themeColor,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.school_outlined,
              color: Colors.grey.shade400,
              size: 20,
            ),
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
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPositionToggle(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedPosition = 'Working'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedPosition == 'Working'
                      ? themeColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Working',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedPosition == 'Working'
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedPosition = 'Self Employed'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedPosition == 'Self Employed'
                      ? themeColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Self Employed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedPosition == 'Self Employed'
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, Color themeColor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Account Created Successfully!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'You can now login with your credentials',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}