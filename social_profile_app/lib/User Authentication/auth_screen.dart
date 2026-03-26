import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_profile_app/Profile/profile_provider.dart';
import 'package:social_profile_app/User%20Authentication/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE94560), Color(0xFF0f3460)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE94560).withOpacity(0.4),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'SocialSnap',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Connect. Share. Grow.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: const Color(0xFFE94560),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.4),
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 350,
                child: TabBarView(
                  controller: _tab,
                  children: const [_LoginForm(), _SignUpForm()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// LOGIN
class _LoginForm extends StatefulWidget {
  const _LoginForm();
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final e = TextEditingController(), p = TextEditingController();
  bool hide = true, load = false;
  String err = '';

  @override
  void dispose() {
    e.dispose();
    p.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() => load = true);
    final res = await context.read<AuthProvider>().login(
      email: e.text.trim(),
      password: p.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      load = false;
      err = res ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tf(e, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _tf(
          p,
          'Password',
          Icons.lock_outline,
          obscure: hide,
          suffix: IconButton(
            icon: Icon(
              hide ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withOpacity(0.4),
            ),
            onPressed: () => setState(() => hide = !hide),
          ),
        ),
        if (err.isNotEmpty) ...[const SizedBox(height: 12), _Err(err)],
        const SizedBox(height: 24),
        _Btn('Login', load, login),
      ],
    );
  }
}

// SIGNUP
class _SignUpForm extends StatefulWidget {
  const _SignUpForm();
  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final n = TextEditingController(),
      e = TextEditingController(),
      p = TextEditingController();
  bool hide = true, load = false;
  String err = '';

  @override
  void dispose() {
    n.dispose();
    e.dispose();
    p.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    setState(() => load = true);
    final res = await context.read<AuthProvider>().signUp(
      name: n.text.trim(),
      email: e.text.trim(),
      password: p.text.trim(),
      profileProvider: context.read<ProfileProvider>(),
    );
    if (!mounted) return;
    setState(() {
      load = false;
      err = res ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tf(n, 'Full name', Icons.person_outline),
        const SizedBox(height: 12),
        _tf(e, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _tf(
          p,
          'Password',
          Icons.lock_outline,
          obscure: hide,
          suffix: IconButton(
            icon: Icon(
              hide ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withOpacity(0.4),
            ),
            onPressed: () => setState(() => hide = !hide),
          ),
        ),
        if (err.isNotEmpty) ...[const SizedBox(height: 12), _Err(err)],
        const SizedBox(height: 24),
        _Btn('Create Account', load, signup),
      ],
    );
  }
}

// HELPERS
Widget _tf(
  TextEditingController c,
  String h,
  IconData i, {
  bool obscure = false,
  TextInputType? type,
  Widget? suffix,
}) => TextField(
  controller: c,
  obscureText: obscure,
  keyboardType: type,
  style: const TextStyle(color: Colors.white),
  decoration: InputDecoration(
    hintText: h,
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
    prefixIcon: Icon(i, color: const Color(0xFFE94560)),
    suffixIcon: suffix,
    filled: true,
    fillColor: const Color(0xFF1a1a2e),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE94560), width: 1.5),
    ),
  ),
);

class _Err extends StatelessWidget {
  final String m;
  const _Err(this.m);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFE94560).withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE94560).withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFE94560), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            m,
            style: const TextStyle(color: Color(0xFFE94560), fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

class _Btn extends StatelessWidget {
  final String t;
  final bool l;
  final VoidCallback f;
  const _Btn(this.t, this.l, this.f);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: l ? null : f,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE94560),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: l
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              t,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
}
