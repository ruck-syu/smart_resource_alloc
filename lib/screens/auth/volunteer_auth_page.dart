import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_resource_alloc/providers/app_state.dart';
import 'package:smart_resource_alloc/theme/app_theme.dart';

class VolunteerAuthPage extends StatefulWidget {
  const VolunteerAuthPage({super.key});

  @override
  State<VolunteerAuthPage> createState() => _VolunteerAuthPageState();
}

class _VolunteerAuthPageState extends State<VolunteerAuthPage> {
  bool _isLogin = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _selectedZone = 'Koramangala Zone';

  void _submit() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields.')));
      return;
    }

    if (!_isLogin) {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required for sign up.')));
        return;
      }
      // Register New Volunteer into global state database
      context.read<AppState>().addVolunteer(
        _nameController.text, 
        _selectedZone, 
        ['General'] // Default mock skill
      );
      
      // Send new user to onboarding
      context.go('/onboarding');
    } else {
      // Just logging in, sending straight to feed
      context.read<AppState>().updateVolunteerProfile('John LoggedIn', 'Indiranagar Hub');
      context.go('/volunteer/feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Volunteer Login' : 'Register as Volunteer'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(LucideIcons.userCheck, size: 60, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 32),
              
              if (!_isLogin) ...[
                const Text('Full Name'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Primary Zone'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedZone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: ['Koramangala Zone', 'Indiranagar Hub', 'Whitefield Sector', 'Jayanagar Central']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedZone = v!),
                ),
                const SizedBox(height: 16),
              ],
              
              const Text('Email Address'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              
              const Text('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
                  child: Text(_isLogin ? 'Log In' : 'Sign Up', style: const TextStyle(fontSize: 16)),
                ),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'Need an account? Sign Up' : 'Already registered? Log In'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
