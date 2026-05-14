import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../../app/core/mixins/messages.mixin.dart';

import '../../../../shared/widgets/custom_buttons.dart';
import '../../../../shared/widgets/custom_cards.dart';
import '../../../../shared/widgets/custom_text_field.dart';

import '../../cliente.dart';
import '../../cliente_repository.dart';

class CadastroClientePage extends StatefulWidget {
  final Cliente? cliente;

  const CadastroClientePage({
    super.key,
    this.cliente,
  });

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
    filter: {
      "#": RegExp(r'[0-9]'),
    },
  );

  final cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {
      "#": RegExp(r'[0-9]'),
    },
  );

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController();
    cpfController = TextEditingController();
    emailController = TextEditingController();
    telefoneController = TextEditingController();

    /// MODO EDIÇÃO
    if (widget.cliente != null) {
      nomeController.text = widget.cliente!.nome;
      cpfController.text = widget.cliente!.cpf;
      emailController.text = widget.cliente!.email;
      telefoneController.text = widget.cliente!.telefone;
    }
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

    final novoCliente = Cliente(
      id: widget.cliente?.id ??
          DateTime.now().millisecondsSinceEpoch,
      nome: nomeController.text,
      cpf: cpfController.text,
      email: emailController.text,
      telefone: telefoneController.text,
    );

    /// NOVO CLIENTE
    if (widget.cliente == null) {
      ClienteRepository.clientes.add(novoCliente);
    } else {
      /// EDITAR CLIENTE
      final index = ClienteRepository.clientes.indexWhere(
        (cliente) =>
            cliente.id == widget.cliente!.id,
      );

      ClienteRepository.clientes[index] =
          novoCliente;
    }

    showSuccess(
      context,
      widget.cliente == null
          ? 'Cliente cadastrado com sucesso'
          : 'Cliente atualizado com sucesso',
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cliente == null
              ? 'Cadastro de Cliente'
              : 'Editar Cliente',
        ),
        backgroundColor: colors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// NOME
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor:
                    colors.primary.withOpacity(0.12),
                child: Icon(
                  Icons.person,
                  color: colors.primary,
                ),
              ),
              title: const Text(
                'Nome / Razão Social',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomTextField(
                  label: 'Nome',
                  controller: nomeController,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// CPF
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor:
                    colors.secondary.withOpacity(0.12),
                child: Icon(
                  Icons.badge,
                  color: colors.secondary,
                ),
              ),
              title: const Text(
                'CPF / CNPJ',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomTextField(
                  label: 'CPF',
                  controller: cpfController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [cpfMask],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// EMAIL
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor:
                    colors.tertiary.withOpacity(0.12),
                child: Icon(
                  Icons.email,
                  color: colors.tertiary,
                ),
              ),
              title: const Text(
                'E-mail',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomTextField(
                  label: 'E-mail',
                  controller: emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// TELEFONE
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor:
                    Colors.green.withOpacity(0.12),
                child: const Icon(
                  Icons.phone,
                  color: Colors.green,
                ),
              ),
              title: const Text(
                'Telefone',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomTextField(
                  label: 'Telefone',
                  controller: telefoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [telefoneMask],
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// SALVAR
            CustomPrimaryButton(
              text: widget.cliente == null
                  ? 'Salvar Cliente'
                  : 'Atualizar Cliente',
              icon: Icons.save,
              onPressed: salvarCliente,
            ),

            const SizedBox(height: 16),

            /// VOLTAR
            CustomSecondaryButton(
              text: 'Voltar',
              icon: Icons.arrow_back,
              onPressed: () =>
                  Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}