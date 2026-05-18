import 'package:flutter/material.dart';

import '../../../../core/mixins/messages.mixin.dart';

import '../../../../shared/widgets/custom_buttons.dart';
import '../../../../shared/widgets/custom_cards.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

import '../../usuario.model.dart';
import '../../usuario.repository.dart';
import '../../usuario.validation.dart';
import '../../usuario.service.dart';
import '../../usuario.schedule.dart';

class CadastroUsuarioPage extends StatefulWidget {
  final Usuario? usuario;

  const CadastroUsuarioPage({
    super.key,
    this.usuario,
  });

  @override
  State<CadastroUsuarioPage> createState() =>
      _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState
    extends State<CadastroUsuarioPage>
    with MessagesMixin {
  final repository = UsuarioRepository();

  late final validation =
      UsuarioValidation(repository);

  late final service =
      UsuarioService(validation, repository);

  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController grupoController;

  String perfil = 'tecnico';

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController();
    emailController = TextEditingController();
    grupoController = TextEditingController();

    if (widget.usuario != null) {
      nomeController.text =
          widget.usuario!.nomeCompleto;

      emailController.text =
          widget.usuario!.email;

      grupoController.text =
          widget.usuario!.grupoId;

      perfil = widget.usuario!.perfil;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    grupoController.dispose();
    super.dispose();
  }

Future<void> salvarUsuario() async {
  try {
    final usuario = Usuario(
      id: widget.usuario?.id,
      supabaseId: widget.usuario?.supabaseId ?? const Uuid().v4(),
      nomeCompleto: nomeController.text,
      email: emailController.text,
      grupoId: grupoController.text,
      perfil: perfil,
    );

    if (widget.usuario == null) {
      await service.create(usuario);
    } else {
      await service.update(usuario);
    }

    await UsuarioSchedule().syncPending();

    showSuccess(
      context,
      widget.usuario == null
          ? 'Usuário cadastrado com sucesso'
          : 'Usuário atualizado com sucesso',
    );

    Navigator.of(context).pop();
  } catch (e) {
    showError(context, e.toString());
  }
}

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.usuario == null
              ? 'Cadastro de Usuário'
              : 'Editar Usuário',
        ),
        backgroundColor: colors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomListCard(
                leading: CircleAvatar(
                  backgroundColor:
                      colors.primary.withOpacity(0.12),
                  child: Icon(
                    Icons.person,
                    color: colors.primary,
                  ),
                ),
                title: const Text('Nome Completo'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: CustomTextField(
                    label: 'Nome Completo',
                    controller: nomeController,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              CustomListCard(
                leading: CircleAvatar(
                  backgroundColor:
                      colors.secondary.withOpacity(0.12),
                  child: Icon(
                    Icons.email,
                    color: colors.secondary,
                  ),
                ),
                title: const Text('Email'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: CustomTextField(
                    label: 'Email',
                    controller: emailController,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              CustomListCard(
                leading: CircleAvatar(
                  backgroundColor:
                      colors.tertiary.withOpacity(0.12),
                  child: Icon(
                    Icons.groups,
                    color: colors.tertiary,
                  ),
                ),
                title: const Text('Grupo'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: CustomTextField(
                    label: 'Grupo ID',
                    controller: grupoController,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              CustomListCard(
                leading: CircleAvatar(
                  backgroundColor:
                      colors.primary.withOpacity(0.12),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: colors.primary,
                  ),
                ),
                title: const Text('Perfil'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: DropdownButtonFormField<String>(
                    value: perfil,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrador'),
                      ),
                      DropdownMenuItem(
                        value: 'tecnico',
                        child: Text('Técnico'),
                      ),
                      DropdownMenuItem(
                        value: 'supervisor',
                        child: Text('Supervisor'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        perfil = value!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              CustomPrimaryButton(
                text: widget.usuario == null
                    ? 'Salvar Usuário'
                    : 'Atualizar Usuário',
                icon: Icons.save,
                onPressed: salvarUsuario,
              ),

              const SizedBox(height: 16),

              CustomSecondaryButton(
                text: 'Voltar',
                icon: Icons.arrow_back,
                onPressed: () =>
                    Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}