import 'package:fe_tucknpike/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Home page displayed after a successful login.
class HomePage extends StatefulWidget {
  /// Creates a HomePage widget.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  /// Logs out the current user by clearing the JWT token and navigating back
  /// to the login page.
  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome!'),
      ),
    );
  }
}
