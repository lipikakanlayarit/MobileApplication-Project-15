import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/models/database_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DatabaseHelper _userDb =
      DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _obscurePassword = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load user settings from database
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? userData = await _userDb.getUserData();
      if (userData != null) {
        setState(() {
          _usernameController.text = userData['username'] ?? '';
          _dateController.text = userData['dateOfBirth'] ?? '';
          _phoneController.text = userData['phoneNumber'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _passwordController.text = userData['password'] ?? '';

          // Load profile image if available
          String? imagePath = userData['profileImagePath'];
          if (imagePath != null && imagePath.isNotEmpty) {
            _image = XFile(imagePath);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _validateForm() {
    if (_formKey.currentState!.validate()) {
      _saveSettings();
    }
  }

  // Save user settings to database
  Future<void> _saveSettings() async {
    Map<String, dynamic> userData = {
      'username': _usernameController.text,
      'dateOfBirth': _dateController.text,
      'phoneNumber': _phoneController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    // Only add profileImagePath if an image was selected
    if (_image != null) {
      userData['profileImagePath'] = _image!.path;
    }

    try {
      await _userDb.updateUserData(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color( 0xFFB7CA79,), 
          content: Text(
            'Profile updated successfully',
            style: TextStyle(
              color: Colors.black, 
              fontWeight: FontWeight.w500,
            ),
          ),
          elevation: 0,
          duration: const Duration(seconds: 2),
          behavior:
              SnackBarBehavior.floating, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print("Error saving settings: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving settings: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _dateController.text.isNotEmpty
              ? DateFormat('dd/MM/yyyy').parse(_dateController.text)
              : DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF556E59),
              onPrimary: Colors.white,
              surface: Color(0xFFB7CA79),
              onSurface: Colors.white,
              secondary: Color(0xFFFF6B6B),
              onBackground: Color(0xFFB7CA79),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF556E59)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an image source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _image = image; // Update the selected image
        });

        // Save the image path to the database
        await _userDb.updateUserProfileImage(image.path);
      }
    }
  }

  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFEB7339)),
          const SizedBox(width: 15),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
              ),
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A4E42),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(30),
        ),
        margin: const EdgeInsets.all(15),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB7CA79)),
                  )
                  : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF5A4E42),
                                  size: 30,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              'Update Your Profile',
                              style: TextStyle(
                                color: Color(0xFF5A4E42),
                                fontFamily: 'Kanit',
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: const Color(0xFFB7CA79),
                                    backgroundImage:
                                        _image != null
                                            ? FileImage(File(_image!.path))
                                            : null, // Display the selected image if exists
                                    child:
                                        _image == null
                                            ? const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Color(0xFFBCBCBC),
                                        ),
                                        onPressed:
                                            _pickImage, 
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            Container(
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildTextField(
                                    icon: Icons.person,
                                    hintText: 'Username',
                                    controller: _usernameController,
                                    validator:
                                        (value) =>
                                            value!.isEmpty
                                                ? 'Please enter your name'
                                                : null,
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECECEC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFFEB7339),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _dateController,
                                            decoration: const InputDecoration(
                                              hintText: 'Date of Birth',
                                              border: InputBorder.none,
                                            ),
                                            readOnly: true,
                                            onTap: () => _selectDate(context),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.calendar_month_outlined,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () => _selectDate(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
                                    icon: Icons.phone,
                                    hintText: 'Phone Number',
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
                                    icon: Icons.email,
                                    hintText: 'Email',
                                    controller: _emailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Please enter your email';
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECECEC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.lock,
                                          color: Color(0xFFEB7339),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            decoration: const InputDecoration(
                                              hintText: 'Password',
                                              border: InputBorder.none,
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty)
                                                return 'Please enter a password';
                                              if (value.length < 6)
                                                return 'Password must be at least 6 characters';
                                              return null;
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _validateForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFB7CA79,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          color: Color(0xFF000000),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Color(0xFF000000),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
