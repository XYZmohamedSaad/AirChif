import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  static const routePath = '/edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _storage = const FlutterSecureStorage();

  static const String _kName = 'profile_name';
  static const String _kEmail = 'profile_email';

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  static const Color _fieldFill = Color(0xFFF4DA7A);
  static const Color _goldButton = Color(0xFFC58B07);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await _storage.read(key: _kName);
    final email = await _storage.read(key: _kEmail);

    _nameCtrl.text = (name == null || name.trim().isEmpty) ? 'Hassan Demirbay' : name.trim();
    _emailCtrl.text = (email == null || email.trim().isEmpty) ? 'hassan.hassan@gmail.com' : email.trim();

    if (!mounted) return;
    setState(() => _loading = false);
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1.2),
      ),
      suffixIcon: const Icon(Icons.edit, size: 18, color: Colors.black),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    await _storage.write(key: _kName, value: _nameCtrl.text.trim());
    await _storage.write(key: _kEmail, value: _emailCtrl.text.trim());

    if (!mounted) return;
    setState(() => _saving = false);

    // zurück zur Profile-Seite
    context.pop();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _loading
                ? const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar + Upload Image
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: Color(0xFFF4DA7A),
                          child: Icon(Icons.person, size: 34, color: Colors.black),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Upload Image – coming soon')),
                              );
                            },
                            child: Row(
                              children: const [
                                Text(
                                  'Upload Image',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.edit, size: 18, color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _input('Name'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Name required';
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _input('Email'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email required';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: 160,
                      height: 42,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: _goldButton,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                          side: const BorderSide(color: Colors.black, width: 1.1),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text(
                          'Save',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
