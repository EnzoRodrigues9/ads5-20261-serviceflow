import 'package:flutter/material.dart';
import 'package:serviceflow/app/shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
// Importe o novo widget do logo
import '../../../../shared/widgets/app_logo.dart';
import 'package:serviceflow/app/app_routes.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  late TextEditingController emailController;
  late TextEditingController senhaController;
  late TextEditingController usuarioController;
  late TextEditingController confirmacaoSenhaController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    senhaController = TextEditingController();
    usuarioController = TextEditingController();
    confirmacaoSenhaController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    usuarioController.dispose();
    confirmacaoSenhaController.dispose();
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
              CustomTextField(label: "E-mail", controller: emailController),
              const SizedBox(height: 16),
              CustomTextField(
                label: "Usuário",
                controller: usuarioController,
              ),
              const SizedBox(
                height: 16,
              ),
              CustomTextField(
                  label: "Senha",
                  isPassword: true,
                  controller: senhaController),
              const SizedBox(
                height: 16,
              ),
              CustomTextField(
                label: "Confirme a senha",
                isPassword: true,
                controller: confirmacaoSenhaController,
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: () {
                  //verificação se o campo está vazio
                  if (emailController.text.isEmpty ||
                      usuarioController.text.isEmpty ||
                      senhaController.text.isEmpty ||
                      confirmacaoSenhaController.text.isEmpty) {
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

                  //verificação se confirmar senha é = a senha
                  if (confirmacaoSenhaController.text != senhaController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('As senhas não coincidem')),
                    );
                    return;
                  }

                  Navigator.pushNamed(context, AppRoutes.login);
                },
                child: const Text("Cadastrar"),
              ),

              const SizedBox(
                height: 16,
              ),
              CustomButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Voltar"))
            ],
          ),
        ),
      ),
    );
  }
}
