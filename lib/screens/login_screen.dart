import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'task_list_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? sessionMessage;

  const LoginScreen({
    super.key,
    this.sessionMessage,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _errorMessage = widget.sessionMessage;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool success = await _authService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const TaskListScreen(),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Login failed. Check your username and password.';
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to sign in right now. Please try again.';
      });
    }
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSessionMessage =
        widget.sessionMessage != null &&
        _errorMessage == widget.sessionMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSessionMessage
                      ? Colors.orange.shade50
                      : Colors.red.shade50,
                  border: Border.all(
                    color: isSessionMessage
                        ? Colors.orange.shade300
                        : Colors.red.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: isSessionMessage
                        ? Colors.orange.shade900
                        : Colors.red.shade900,
                  ),
                ),
              ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _goToRegister,
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}