import 'package:fe_tucknpike/services/auth_service.dart';
import 'package:fe_tucknpike/views/login_page.dart';
import 'package:flutter/material.dart';

/// Registration page for creating a new user account.
class RegistrationPage extends StatefulWidget {
  /// Creates the registration page.
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers for registration fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _clubNameController = TextEditingController();
  String _role = 'gymnast'; // default role

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authService.register(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          dateOfBirth: _dobController.text,
          clubName: _clubNameController.text,
          role: _role,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in.'),
          ),
        );
        await Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const LoginPage(),
          ),
        );
      } on Exception catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your date of birth'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clubNameController,
                  decoration: const InputDecoration(
                    labelText: 'Club Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your club name'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(
                      value: 'gymnast',
                      child: Text('Gymnast'),
                    ),
                    DropdownMenuItem(
                      value: 'coach',
                      child: Text('Coach'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _role = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _clubNameController.dispose();
    super.dispose();
  }
}
