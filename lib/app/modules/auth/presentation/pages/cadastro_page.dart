import 'package:flutter/material.dart';

import 'package:serviceflow/app/app_routes.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/custom_text_field.dart';

import '../../auth.service.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _emailController = TextEditingController();
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _senhaVisivel = false;
  bool _confirmacaoVisivel = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nomeController.dispose();
    _senhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  Future<void> _fazerCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.cadastrar(
      email: _emailController.text,
      nomeCompleto: _nomeController.text,
      senha: _senhaController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _mostrarSnack(result.message, isError: false);

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      if (result.needsEmailVerification) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
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
        duration: Duration(seconds: isError ? 5 : 3),
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
                    children: [
                      _LogoSection(),
                      const SizedBox(height: 28),
                      _FormCard(
                        emailController: _emailController,
                        nomeController: _nomeController,
                        senhaController: _senhaController,
                        confirmacaoController: _confirmacaoController,
                        senhaVisivel: _senhaVisivel,
                        confirmacaoVisivel: _confirmacaoVisivel,
                        onToggleSenha: () =>
                            setState(() => _senhaVisivel = !_senhaVisivel),
                        onToggleConfirmacao: () => setState(
                            () => _confirmacaoVisivel = !_confirmacaoVisivel),
                        isLoading: _isLoading,
                        onCadastrar: _fazerCadastro,
                        onVoltar: () => Navigator.pop(context),
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
          top: -size.height * 0.06,
          right: -size.width * 0.1,
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1565C0).withOpacity(0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -size.height * 0.04,
          left: -size.width * 0.2,
          child: Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF42A5F5).withOpacity(0.12),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const AppLogo(width: 42, height: 42),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ServiceFlow',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D47A1),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Criar nova conta',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController nomeController;
  final TextEditingController senhaController;
  final TextEditingController confirmacaoController;
  final bool senhaVisivel;
  final bool confirmacaoVisivel;
  final VoidCallback onToggleSenha;
  final VoidCallback onToggleConfirmacao;
  final bool isLoading;
  final VoidCallback onCadastrar;
  final VoidCallback onVoltar;

  const _FormCard({
    required this.emailController,
    required this.nomeController,
    required this.senhaController,
    required this.confirmacaoController,
    required this.senhaVisivel,
    required this.confirmacaoVisivel,
    required this.onToggleSenha,
    required this.onToggleConfirmacao,
    required this.isLoading,
    required this.onCadastrar,
    required this.onVoltar,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  color: Color(0xFF1565C0),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Criar Conta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  Text(
                    'Preencha os dados abaixo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _dividerSection('Dados de Acesso'),
          const SizedBox(height: 16),
          _label('E-mail'),
          const SizedBox(height: 6),
          CustomTextField(
            label: 'seu@email.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                return 'E-mail inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _label('Usuário'),
          const SizedBox(height: 6),
          CustomTextField(
            label: 'Seu nome completo',
            controller: nomeController,
            prefixIcon: Icons.badge_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe seu nome';
              if (v.trim().length < 3) return 'Nome muito curto';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _dividerSection('Senha'),
          const SizedBox(height: 16),
          _label('Senha'),
          const SizedBox(height: 6),
          _senhaField(
            controller: senhaController,
            label: 'Mínimo 6 caracteres',
            visivel: senhaVisivel,
            onToggle: onToggleSenha,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe a senha';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _label('Confirme a Senha'),
          const SizedBox(height: 6),
          _senhaField(
            controller: confirmacaoController,
            label: 'Repita a senha',
            visivel: confirmacaoVisivel,
            onToggle: onToggleConfirmacao,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirme a senha';
              if (v != senhaController.text) return 'As senhas não coincidem';
              return null;
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onCadastrar,
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
                        Icon(Icons.how_to_reg_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Criar Conta',
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
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton(
              onPressed: onVoltar,
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Voltar para o Login',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF37474F),
      ),
    );
  }

  Widget _dividerSection(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1565C0),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF1565C0).withOpacity(0.12),
          ),
        ),
      ],
    );
  }

  Widget _senhaField({
    required TextEditingController controller,
    required String label,
    required bool visivel,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visivel,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            visivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}
