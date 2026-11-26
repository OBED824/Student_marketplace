import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../helpers.dart';
import '../widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
 const LoginScreen({super.key});

 @override
 State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 final _formKey = GlobalKey<FormState>();
 final _email = TextEditingController();
 final _password = TextEditingController();

 Future<void> _login() async {
 if (!_formKey.currentState!.validate()) return;
 final error = await context.read<AppState>().login(_email.text, _password.text);
 if (error != null && mounted) showMessage(context, error);
 // On success AppState changes and main.dart swaps in the MainScreen.
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 body: SafeArea(
 child: Center(
 child: SingleChildScrollView(
 padding: const EdgeInsets.all(24),
 child: ConstrainedBox( constraints: const BoxConstraints(maxWidth: 420),
 child: Form(
 key: _formKey,
 child: Column(children: [
 const Icon(Icons.storefront_rounded, size: 72, color: green),
 const Text(appName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
 const SizedBox(height: 4),
 const Text('Buy and sell on your campus', style: TextStyle(color: Colors.grey)),
 const SizedBox(height: 28),
 TextFormField(
 controller: _email,
keyboardType: TextInputType.emailAddress,
 decoration: const InputDecoration(labelText: 'University email', prefixIcon: Icon(Icons.school_outlined)),
 validator: validateEmail,
 ),
 const SizedBox(height: 14),
 TextFormField(
 controller: _password,
 obscureText: true,
 decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
 validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
 ),
const SizedBox(height: 22),
 FilledButton(onPressed: _login, child: const Text('Sign in')),
 TextButton(
 onPressed: () {
 _email.text = 'aisha@students.mak.ac.ug';
 _password.text = 'password123';
 },
 child: const Text('Fill demo account'),
 ),
 TextButton(
 onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
 child: const Text('New here? Create an account'),
 ),
 ]),
 ),
 ),
 ),
 ),
 ),
 );
 }
}