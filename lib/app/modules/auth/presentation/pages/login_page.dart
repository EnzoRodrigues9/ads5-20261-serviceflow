import 'package:flutter/material.dart';

import 'package:serviceflow/app/app_routes.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/app_logo.dart';

import '../../auth.service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.login(
      email: _emailController.text,
      senha: _senhaController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _mostrarSnack(result.message, isError: false);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      _mostrarSnack(result.message, isError: true);
    }
  }

  void _mostrarSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: isError ? 5 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Stack(
        children: [
          _BackgroundDecoration(size: size),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LogoSection(),
                      const SizedBox(height: 36),
                      _FormCard(
                        emailController: _emailController,
                        senhaController: _senhaController,
                        senhaVisivel: _senhaVisivel,
                        onToggleSenha: () =>
                            setState(() => _senhaVisivel = !_senhaVisivel),
                        isLoading: _isLoading,
                        onLogin: _fazerLogin,
                        onCadastro: () =>
                            Navigator.pushNamed(context, AppRoutes.cadastro),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  final Size size;
  const _BackgroundDecoration({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.08,
          left: -size.width * 0.15,
          child: Container(
            width: size.width * 0.7,
            height: size.width * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1565C0).withOpacity(0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -size.height * 0.05,
          right: -size.width * 0.2,
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF42A5F5).withOpacity(0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const AppLogo(width: 72, height: 72),
        ),
        const SizedBox(height: 16),
        const Text(
          'ServiceFlow',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D47A1),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sistema de Gestão de O.S.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.blueGrey[400],
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final bool senhaVisivel;
  final VoidCallback onToggleSenha;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onCadastro;

  const _FormCard({
    required this.emailController,
    required this.senhaController,
    required this.senhaVisivel,
    required this.onToggleSenha,
    required this.isLoading,
    required this.onLogin,
    required this.onCadastro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Entrar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Acesse sua conta para continuar',
            style: TextStyle(fontSize: 13, color: Colors.blueGrey[400]),
          ),
          const SizedBox(height: 24),
          _buildLabel('E-mail'),
          const SizedBox(height: 6),
          CustomTextField(
            label: 'seu@email.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
              if (!v.contains('@')) return 'E-mail inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Senha'),
          const SizedBox(height: 6),
          TextFormField(
            controller: senhaController,
            obscureText: !senhaVisivel,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe a senha';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Sua senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: onToggleSenha,
                icon: Icon(
                  senhaVisivel
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.blueGrey,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueGrey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF1565C0), width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF1565C0).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.blueGrey.shade100)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: Colors.blueGrey[400],
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.blueGrey.shade100)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onCadastro,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1565C0),
                side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Criar nova conta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF37474F),
      ),
    );
  }
}
