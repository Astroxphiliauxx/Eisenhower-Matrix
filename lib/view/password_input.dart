import 'package:flutter/material.dart';
import '../utlis/database_helper.dart';


class PasswordInputScreen extends StatefulWidget {
  const PasswordInputScreen({Key? key}) : super(key: key);

  @override
  _PasswordInputScreenState createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final password = _passwordController.text;
                // Call the authenticatePassword method
                final isAuthenticated = await DatabaseHelper.instance.authenticatePassword(password);
                if (isAuthenticated) {
                  // Password correct, show a success message or navigate elsewhere
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password is correct!')),
                  );
                } else {
                  // Password incorrect, show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect password')),
                  );
                }
              },
              child: const Text('Check Password'),
            ),
          ],
        ),
      ),
    );
  }
}