// File: lib/views/role_based_shell.dart
import 'dart:convert';
import 'package:fe_tucknpike/constants/brand_colors.dart';
import 'package:fe_tucknpike/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A shell widget that provides a bottom navigation bar and an app bar
class RoleBasedShell extends StatefulWidget {
  /// Creates a [RoleBasedShell] widget.
  const RoleBasedShell({required this.child, super.key});

  /// The child widget to be displayed in the shell.
  final Widget child;

  @override
  State<RoleBasedShell> createState() => _RoleBasedShellState();
}

class _RoleBasedShellState extends State<RoleBasedShell> {
  String? _role;
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final token = await _authService.getToken();
    if (token != null) {
      setState(() {
        _role = _decodeRole(token);
      });
    }
  }

  String? _decodeRole(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
      return payloadMap['role'] as String?;
    } on Exception {
      return null;
    }
  }

  List<BottomNavigationBarItem> _navItems() {
    if (_role == null) {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.hourglass_empty),
          label: 'Loading',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.hourglass_empty),
          label: 'Loading',
        ),
      ];
    }

    if (_role!.toLowerCase() == 'coach') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Gymnasts',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (_role!.toLowerCase() == 'gymnast') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Trainings',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (_role?.toLowerCase() == 'coach') {
      if (index == 0) {
        context.go('/gymnasts');
      } else if (index == 1) {
        context.go('/profile');
      }
    } else if (_role?.toLowerCase() == 'gymnast') {
      if (index == 0) {
        context.go('/trainings');
      } else if (index == 1) {
        context.go('/profile');
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [BrandColors.primaryColor, BrandColors.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Tucknpike',
          style: TextStyle(
            color: BrandColors.backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: BrandColors.backgroundColor),
            onPressed: _logout,
          ),
        ],
        centerTitle: true,
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _navItems(),
        onTap: _onTabSelected,
      ),
    );
  }
}
