import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    // Validate email
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Here you would integrate with your authentication service
      // For example, with Firebase:
      // await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
      
      // Simulating API call with a delay
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _resetEmailSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to send reset email. Please try again later.';
      });
    }
  }
  
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Reset your password',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontFamily: 'Kanit',
          fontWeight: FontWeight.w600,
          fontSize: 30,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    extendBodyBehindAppBar: true,
    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ocean.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.5),
            ],
          ),
        ),
        child: _resetEmailSent ? _buildSuccessView(context) : _buildResetForm(context),
      ),
    ),
  );
}

  Widget _buildResetForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 60),
        const Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFFFFFFF),
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            errorText: _errorMessage,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEB7339),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Send Reset Link',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                color: Color(0xFFEB7339),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFFEB7339),
          size: 80,
        ),
        const SizedBox(height: 20),
        const Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Check your inbox and follow the instructions to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C59D9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() {
              _resetEmailSent = false;
              _emailController.clear();
            });
          },
          child: const Text(
            'Try another email',
            style: TextStyle(
              color: Color(0xFFEB7339),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}