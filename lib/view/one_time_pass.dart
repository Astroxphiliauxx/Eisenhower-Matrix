import 'package:flutter/material.dart';
import 'package:noteapp/view/password_input.dart';

import '../services/database_helper.dart';


class PasswordInputScreen1 extends StatefulWidget {
  const PasswordInputScreen1({Key? key}) : super(key: key);

  @override
  _PasswordInputScreen1State createState() => _PasswordInputScreen1State();
}

class _PasswordInputScreen1State extends State<PasswordInputScreen1> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Password'),
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
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Confirm your password',
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
        ElevatedButton(
          onPressed: () async {
            final password = _passwordController.text;
            final confirmPassword = _confirmPasswordController.text;

            if (password.isNotEmpty && confirmPassword.isNotEmpty && password == confirmPassword) {
              // Show the success message first
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password stored successfully')),
              );

              // Store the password in the database
              try {
                await DatabaseHelper.instance.storePassword(password);
                // Adding a small delay to ensure the SnackBar is visible before the navigation
                await Future.delayed(const Duration(seconds: 2));

                // Navigate to the PasswordScreenInput after password is stored
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PasswordInputScreen()),
                  );
                }
              } catch (e) {
                print("Error storing password: $e");
              }
            } else {
              // Show an error message if passwords don't match
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Passwords do not match')),
              );
            }
          },
          child: const Text('Set Password'),
        )



        ],
        ),
      ),
    );
  }
}