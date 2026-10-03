import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chess_platform/core/network/app_services.dart';
import '../../data/auth_repository.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final login = TextEditingController();
  final password = TextEditingController();

  bool busy = false;
  bool obscurePassword = true;

  static const background = Color(0xFF0D0A07);
  static const panel = Color(0xFF21150C);
  static const panelLight = Color(0xFF302014);
  static const gold = Color(0xFFD6A84F);
  static const cream = Color(0xFFF5E7C9);
  static const muted = Color(0xFFB9A78A);

  @override
  void dispose() {
    login.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (login.text.trim().isEmpty || password.text.isEmpty) {
      _showMessage('Please enter username/email and password.');
      return;
    }

    setState(() => busy = true);

    try {
      final data = await AuthRepository(apiClient).login(
        login.text.trim(),
        password.text,
      );

      apiClient.token = data['token'] as String;

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        _showMessage(
          e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: panelLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: gold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: cream, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 720;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Premium logo
                      Container(
                        width: compact ? 150 : 180,
                        height: compact ? 150 : 180,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(38),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 28,
                              spreadRadius: 3,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: SvgPicture.asset(
                            'assets/chess_platform_logo.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'CHESS PLATFORM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cream,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'KOPERSAY TECHNOLOGY',
                        style: TextStyle(
                          color: gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),

                      SizedBox(height: compact ? 20 : 28),

                      Container(
                        padding: EdgeInsets.all(compact ? 18 : 22),
                        decoration: BoxDecoration(
                          color: panel,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: gold.withValues(alpha: .35),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 24,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                color: cream,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Sign in to continue your chess journey.',
                              style: TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 20),

                            TextField(
                              controller: login,
                              enabled: !busy,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(color: cream),
                              decoration: InputDecoration(
                                labelText: 'Username or email',
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: gold,
                                ),
                                labelStyle: const TextStyle(color: muted),
                                filled: true,
                                fillColor: panelLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: gold,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            TextField(
                              controller: password,
                              enabled: !busy,
                              obscureText: obscurePassword,
                              onSubmitted: (_) {
                                if (!busy) submit();
                              },
                              style: const TextStyle(color: cream),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: gold,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: busy
                                      ? null
                                      : () {
                                          setState(() {
                                            obscurePassword = !obscurePassword;
                                          });
                                        },
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: muted,
                                  ),
                                ),
                                labelStyle: const TextStyle(color: muted),
                                filled: true,
                                fillColor: panelLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: gold,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton(
                                onPressed: busy ? null : submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: gold,
                                  foregroundColor: background,
                                  disabledBackgroundColor: gold.withValues(
                                    alpha: .45,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: busy
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: background,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login_rounded),
                                          SizedBox(width: 8),
                                          Text(
                                            'LOGIN',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: busy
                                    ? null
                                    : () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: cream,
                                  side: BorderSide(
                                    color: gold.withValues(alpha: .55),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'CREATE ACCOUNT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.security_rounded,
                            color: gold,
                            size: 15,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Secure server-authoritative chess',
                            style: TextStyle(
                              color: muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
