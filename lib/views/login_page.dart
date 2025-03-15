import 'package:fe_tucknpike/services/auth_service.dart';
import 'package:fe_tucknpike/views/home_page.dart';
import 'package:fe_tucknpike/views/registration_page.dart';
import 'package:flutter/material.dart';

/// Login page for user authentication.
class LoginPage extends StatefulWidget {
  /// Creates a LoginPage widget.
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  /// Attempts to log the user in using the provided credentials.
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authService.login(
          _usernameOrEmailController.text,
          _passwordController.text,
        );
        if (!mounted) return;
        await Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const HomePage(),
          ),
        );
      } on Exception catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
        debugPrint('Login failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameOrEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email or Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email or username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const RegistrationPage(),
                    ),
                  );
                },
                child: const Text("Don't have an account? Register here."),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
