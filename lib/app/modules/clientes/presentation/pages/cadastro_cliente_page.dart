import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../../app/core/mixins/messages.mixin.dart';

import '../../../../shared/widgets/custom_buttons.dart';
import '../../../../shared/widgets/custom_cards.dart';
import '../../../../shared/widgets/custom_text_field.dart';

import '../../cliente.model.dart';
import '../../cliente.provider.dart';
import '../../cliente.repository.dart';
import '../../cliente.service.dart';
import '../../cliente.validation.dart';

class CadastroClientePage extends StatefulWidget {
  final Cliente? cliente;

  const CadastroClientePage({
    super.key,
    this.cliente,
  });

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage>
    with MessagesMixin {
  late TextEditingController nomeController;
  late TextEditingController documentoController;
  late TextEditingController emailController;
  late TextEditingController telefoneController;

  late ClienteService service;
  final _provider = ClienteProvider();

  final telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final documentoMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();

    final repository = ClienteRepository();
    final validation = ClienteValidation(repository);
    service = ClienteService(validation, repository);

    nomeController = TextEditingController();
    documentoController = TextEditingController();
    emailController = TextEditingController();
    telefoneController = TextEditingController();

    if (widget.cliente != null) {
      nomeController.text = widget.cliente!.nome;
      documentoController.text = widget.cliente!.documento ?? '';
      emailController.text = widget.cliente!.email;
      telefoneController.text = widget.cliente!.telefone;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    documentoController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    super.dispose();
  }

  Future<void> salvarCliente() async {
    try {
      final cliente = Cliente(
        id: widget.cliente?.id,
        // IMPORTANTE: preserva isSync do cliente original ao editar.
        // - Novo cliente: isSync = 0 (padrão do modelo) → BaseProvider fará POST
        // - Cliente existente que já foi ao Supabase: isSync = 1 → fará PATCH
        // - Cliente existente ainda não sincronizado: isSync = 0 → fará POST
        isSync: widget.cliente?.isSync ?? 0,
        nome: nomeController.text,
        documento: documentoController.text,
        email: emailController.text,
        telefone: telefoneController.text,
      );

      final Cliente savedCliente;
      if (widget.cliente == null) {
        savedCliente = await service.create(cliente);
      } else {
        savedCliente = await service.update(cliente);
      }

      if (!mounted) return;

      showSuccess(
        context,
        widget.cliente == null
            ? 'Cliente salvo localmente!'
            : 'Cliente atualizado localmente!',
      );

      Navigator.pop(context);

      _syncWithSupabase(savedCliente);
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  Future<void> _syncWithSupabase(Cliente cliente) async {
    try {
      final valid = await _provider.validateBeforeSync(cliente);
      if (!valid) return;

      final success = await _provider.syncToCloud(cliente);

      if (success) {
        await ClienteRepository().markAsSynced(cliente.id!);
      }
    } catch (e) {
      if (mounted) {
        showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cliente == null ? 'Cadastro de Cliente' : 'Editar Cliente',
        ),
        backgroundColor: colors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.primary.withOpacity(0.12),
                child: Icon(Icons.person, color: colors.primary),
              ),
              title: const Text('Nome / Razão Social'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomTextField(
                  label: 'Nome',
                  controller: nomeController,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.secondary.withOpacity(0.12),
                child: Icon(Icons.badge, color: colors.secondary),
              ),
              title: const Text('CPF / CNPJ'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomTextField(
                  label: 'Documento',
                  controller: documentoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [documentoMask],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.tertiary.withOpacity(0.12),
                child: Icon(Icons.email, color: colors.tertiary),
              ),
              title: const Text('E-mail'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CustomTextField(
                  label: 'E-mail',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.12),
                child: const Icon(Icons.phone, color: Colors.green),
              ),
              title: const Text('Telefone'),
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
            CustomPrimaryButton(
              text: widget.cliente == null
                  ? 'Salvar Cliente'
                  : 'Atualizar Cliente',
              icon: Icons.save,
              onPressed: salvarCliente,
            ),
            const SizedBox(height: 16),
            CustomSecondaryButton(
              text: 'Voltar',
              icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
