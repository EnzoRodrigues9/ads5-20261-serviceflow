import 'package:flutter/material.dart';
import 'package:serviceflow/app/shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../../app/core/mixins/messages.mixin.dart';

import '../../cliente.dart';
import '../../cliente_repository.dart';

class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({super.key});

  @override
  State<CadastroClientePage> createState() =>
      _CadastroClientePageState();
}

class _CadastroClientePageState
    extends State<CadastroClientePage>
    with MessagesMixin {

  late TextEditingController nomeController;
  late TextEditingController cpfController;
  late TextEditingController emailController;
  late TextEditingController telefoneController;

  final telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController();
    cpfController = TextEditingController();
    emailController = TextEditingController();
    telefoneController = TextEditingController();
  }

  @override
  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    super.dispose();
  }

  void salvarCliente() {

    if (nomeController.text.isEmpty ||
        cpfController.text.isEmpty ||
        emailController.text.isEmpty ||
        telefoneController.text.isEmpty) {

      showWarning(
        context,
        'Preencha todos os campos',
      );

      return;
    }

    if (!emailController.text.contains('@')) {

      showError(
        context,
        'E-mail inválido',
      );

      return;
    }

    ClienteRepository.clientes.add(
      Cliente(
        nome: nomeController.text,
        cpf: cpfController.text,
        email: emailController.text,
        telefone: telefoneController.text,
      ),
    );

    showSuccess(
      context,
      'Cliente cadastrado com sucesso',
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Cliente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [

            CustomTextField(
              label: 'Nome/Razão Social',
              controller: nomeController,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: 'CPF/CNPJ',
              controller: cpfController,
              keyboardType: TextInputType.number,
              inputFormatters: [cpfMask],
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: 'E-mail',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: 'Telefone',
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [telefoneMask],
            ),

            const SizedBox(height: 32),

            CustomButton(
              onPressed: salvarCliente,
              child: const Text('Salvar Cliente'),
            ),

            const SizedBox(height: 16),

            CustomButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}