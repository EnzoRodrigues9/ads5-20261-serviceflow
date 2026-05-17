import 'package:flutter/material.dart';

import '../../../../core/mixins/messages.mixin.dart';

import '../../../../shared/widgets/custom_buttons.dart';
import '../../../../shared/widgets/custom_cards.dart';
import '../../../../shared/widgets/custom_text_field.dart';

import '../../tecnico.model.dart';
import '../../tecnico.repository.dart';
import '../../tecnico.service.dart';
import '../../tecnico.validation.dart';

class CadastroTecnicoPage extends StatefulWidget {
  final Tecnico? tecnico;

  const CadastroTecnicoPage({
    super.key,
    this.tecnico,
  });

  @override
  State<CadastroTecnicoPage> createState() => _CadastroTecnicoPageState();
}

class _CadastroTecnicoPageState extends State<CadastroTecnicoPage>
    with MessagesMixin {
  final repository = TecnicoRepository();

  late final validation = TecnicoValidation(repository);

  late final service = TecnicoService(validation, repository);

  late TextEditingController nomeController;

  late TextEditingController especialidadeController;

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController();

    especialidadeController = TextEditingController();

    if (widget.tecnico != null) {
      nomeController.text = widget.tecnico!.nome;

      especialidadeController.text = widget.tecnico!.especialidade ?? '';
    }
  }

  @override
  void dispose() {
    nomeController.dispose();

    especialidadeController.dispose();

    super.dispose();
  }

  Future<void> salvarTecnico() async {
    try {
      final tecnico = Tecnico(
        id: widget.tecnico?.id,
        nome: nomeController.text,
        especialidade: especialidadeController.text,
      );

      if (widget.tecnico == null) {
        await service.create(tecnico);
      } else {
        await service.update(tecnico);
      }

      showSuccess(
        context,
        widget.tecnico == null
            ? 'Técnico cadastrado com sucesso'
            : 'Técnico atualizado com sucesso',
      );

      Navigator.of(context).pop();
    } catch (e) {
      showError(
        context,
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tecnico == null ? 'Cadastro de Técnico' : 'Editar Técnico',
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
                child: Icon(
                  Icons.engineering,
                  color: colors.primary,
                ),
              ),
              title: const Text(
                'Nome',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
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
                child: Icon(
                  Icons.build,
                  color: colors.secondary,
                ),
              ),
              title: const Text(
                'Especialidade',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: CustomTextField(
                  label: 'Especialidade',
                  controller: especialidadeController,
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomPrimaryButton(
              text: widget.tecnico == null
                  ? 'Salvar Técnico'
                  : 'Atualizar Técnico',
              icon: Icons.save,
              onPressed: salvarTecnico,
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
