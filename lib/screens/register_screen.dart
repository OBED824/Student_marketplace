import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../helpers.dart';
import '../widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _university = universities.keys.first;
  String _campus = universities.values.first.first;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<AppState>().register(
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
          password: _password.text,
          university: _university,
          campus: _campus,
        );
    if (!mounted) return;
    if (error != null) {
      showMessage(context, error);
    } else {
      Navigator.popUntil(context, (route) => route.isFirst); // back to root, which is now the app
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name'), validator: validateName),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'University email', hintText: 'name@students.mak.ac.ug'),
                  validator: validateUniversityEmail,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone (WhatsApp)', hintText: '0771234567'),
                  validator: validatePhone,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _university,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'University'),
                  items: [for (final u in universities.keys) DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))],
                  onChanged: (v) => setState(() {
                    _university = v!;
                    _campus = universities[v]!.first; // reset campus when university changes
                  }),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  key: ValueKey(_university), // rebuild when the university changes
                  initialValue: _campus,
                  decoration: const InputDecoration(labelText: 'Campus'),
                  items: [for (final c in universities[_university]!) DropdownMenuItem(value: c, child: Text(c))],
                  onChanged: (v) => setState(() => _campus = v!),
                ),
                const SizedBox(height: 14),
                TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: validatePassword),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm password'),
                  validator: (v) => v != _password.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 22),
                FilledButton(onPressed: _register, child: const Text('Create account')),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
