import 'package:flutter/material.dart';
import 'package:serviceflow/app/app_routes.dart';
import 'package:serviceflow/app/shared/widgets/custom_buttons.dart';
import '../../../../shared/widgets/custom_text_field.dart';
// Importe o novo widget do logo
import '../../../../shared/widgets/app_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController;
  late TextEditingController senhaController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    senhaController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usando Scaffold e Padding para estruturar a tela
    return Scaffold(
      backgroundColor: Colors.white, // O fundo branco destaca o logo
      body: Center(
        child: SingleChildScrollView(
          // Evita quebra de layout com teclado
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- INSERÇÃO DO LOGO ---
              // Usando o widget reutilizável que criamos
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: AppLogo(width: double.infinity, height: 180),
              ),

              const SizedBox(height: 48), // Espaçamento entre logo e campos

              // Campos de texto e botão (reaproveitando exemplo anterior)
              CustomTextField(
                label: "E-mail",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                  label: "Senha",
                  isPassword: true,
                  controller: senhaController),
              const SizedBox(height: 32),
              CustomPrimaryButton(
                text: "Entrar",
                icon: Icons.login,
                onPressed: () {
                  //verifica se o campo está vazio

                  if (emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Preencha os campos corretamente')),
                    );
                    return;
                  }

                  //verificação email @
                  if (!emailController.text.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('E-mail inválido')),
                    );
                    return;
                  }

                  //verificação senha 6 digitos
                  if (senhaController.text.length <= 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('A senha deve ter mais de 6 caracteres')),
                    );
                    return;
                  }

                  Navigator.pushNamed(context, AppRoutes.home);
                },
              ),
              const SizedBox(
                height: 12,
              ),

              CustomSecondaryButton(
                text: "Criar nova conta",
                icon: Icons.person_add_alt_1,
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.cadastro,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
