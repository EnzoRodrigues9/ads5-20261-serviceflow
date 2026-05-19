import 'package:flutter/material.dart';

import '../../../../../app/core/mixins/messages.mixin.dart';

import '../../../../shared/widgets/custom_buttons.dart';
import '../../../../shared/widgets/custom_cards.dart';
import '../../../../shared/widgets/custom_text_field.dart';

import '../../servico.model.dart';
import '../../servico.repository.dart';
import '../../servico.service.dart';
import '../../servico.validation.dart';
import '../../servico.schedule.dart';

class CadastroServicoPage extends StatefulWidget {
  final Servico? servico;

  const CadastroServicoPage({
    super.key,
    this.servico,
  });

  @override
  State<CadastroServicoPage> createState() => _CadastroServicoPageState();
}

class _CadastroServicoPageState extends State<CadastroServicoPage>
    with MessagesMixin {
  final repository = ServicoRepository();

  late final validation = ServicoValidation(repository);

  late final service = ServicoService(validation, repository);

  late TextEditingController descricaoController;

  late TextEditingController precoController;

  late TextEditingController tempoController;

  @override
  void initState() {
    super.initState();

    descricaoController = TextEditingController();

    precoController = TextEditingController();

    tempoController = TextEditingController();

    if (widget.servico != null) {
      descricaoController.text = widget.servico!.descricao;

      precoController.text = widget.servico!.preco.toString();

      tempoController.text = widget.servico!.tempoEstimado ?? '';
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    precoController.dispose();
    tempoController.dispose();

    super.dispose();
  }

  Future<void> salvarServico() async {
    try {
      final servico = Servico(
        id: widget.servico?.id,
        descricao: descricaoController.text,
        preco: double.parse(
          precoController.text,
        ),
        tempoEstimado: tempoController.text,
      );

      if (widget.servico == null) {
        await service.create(servico);
      } else {
        await service.update(servico);
      }

      await ServicoSchedule().syncPending();

      showSuccess(
        context,
        widget.servico == null
            ? 'Serviço cadastrado com sucesso'
            : 'Serviço atualizado com sucesso',
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
          widget.servico == null ? 'Cadastro de Serviço' : 'Editar Serviço',
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
                  Icons.miscellaneous_services,
                  color: colors.primary,
                ),
              ),
              title: const Text(
                'Descrição',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: CustomTextField(
                  label: 'Descrição do serviço',
                  controller: descricaoController,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.secondary.withOpacity(0.12),
                child: Icon(
                  Icons.attach_money,
                  color: colors.secondary,
                ),
              ),
              title: const Text(
                'Preço',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: CustomTextField(
                  label: 'Preço',
                  controller: precoController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.tertiary.withOpacity(0.12),
                child: Icon(
                  Icons.timer,
                  color: colors.tertiary,
                ),
              ),
              title: const Text(
                'Tempo Estimado',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: CustomTextField(
                  label: 'Ex: 2 horas',
                  controller: tempoController,
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomPrimaryButton(
              text: widget.servico == null
                  ? 'Salvar Serviço'
                  : 'Atualizar Serviço',
              icon: Icons.save,
              onPressed: salvarServico,
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
