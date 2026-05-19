import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import '../../../../core/mixins/loader.mixin.dart';
import '../../../../core/mixins/messages.mixin.dart';

import '../../../../shared/widgets/custom_buttons.dart';
import '../../../../shared/widgets/custom_cards.dart';
import '../../../../shared/widgets/custom_text_field.dart';

import '../../../clientes/cliente.model.dart';
import '../../../clientes/cliente.repository.dart';

import '../../../servicos/servico.model.dart';
import '../../../servicos/servico.repository.dart';

import '../../../tecnicos/tecnico.model.dart';
import '../../../tecnicos/tecnico.repository.dart';

import '../../ordem_servico.model.dart';
import '../../ordem_servico.repository.dart';
import '../../ordem_servico.service.dart';
import '../../ordem_servico.validation.dart';

import '../../os_item.model.dart';
import '../../os_item.repository.dart';
import '../../os_item.schedule.dart';
import '../../ordem_servico.schedule.dart';

import '../../../clientes/cliente.schedule.dart';
import '../../../tecnicos/tecnico.schedule.dart';
import '../../../servicos/servico.schedule.dart';

class CadastroOrdemServicoPage extends StatefulWidget {
  final OrdemServico? ordemServico;

  const CadastroOrdemServicoPage({
    super.key,
    this.ordemServico,
  });

  @override
  State<CadastroOrdemServicoPage> createState() =>
      _CadastroOrdemServicoPageState();
}

class _CadastroOrdemServicoPageState extends State<CadastroOrdemServicoPage>
    with LoaderMixin, MessagesMixin {
  final formKey = GlobalKey<FormState>();

  final repository = OrdemServicoRepository();

  late final validation = OrdemServicoValidation(repository);

  late final service = OrdemServicoService(
    validation,
    repository,
  );

  final clienteRepository = ClienteRepository();

  final tecnicoRepository = TecnicoRepository();

  final servicoRepository = ServicoRepository();

  final observacaoController = TextEditingController();

  final pecasController = TextEditingController();

  final valorPecasController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  late SignatureController signatureController;

  List<Cliente> clientes = [];

  List<Tecnico> tecnicos = [];

  List<Servico> servicos = [];

  List<Servico> servicosSelecionados = [];

  Cliente? clienteSelecionado;

  Tecnico? tecnicoSelecionado;

  String statusSelecionado = 'Em aberto';

  XFile? fotoAntes;

  XFile? fotoDepois;

  Uint8List? assinaturaBytes;

  @override
  void initState() {
    super.initState();

    signatureController = SignatureController(
      penStrokeWidth: 4,
      penColor: Colors.blue,
      exportBackgroundColor: Colors.white,
    );

    carregarDados();

    if (widget.ordemServico != null) {
      final os = widget.ordemServico!;

      observacaoController.text = os.observacao ?? '';

      pecasController.text = os.pecasAplicadas ?? '';

      valorPecasController.text = os.valorPecas.toString();

      statusSelecionado = os.status;

      if (os.fotoAntes != null) {
        fotoAntes = XFile(
          os.fotoAntes!,
        );
      }

      if (os.fotoDepois != null) {
        fotoDepois = XFile(
          os.fotoDepois!,
        );
      }
    }
  }

  Future<void> carregarDados() async {
    clientes = await clienteRepository.findAll();

    tecnicos = await tecnicoRepository.findAll();

    servicos = await servicoRepository.findAll();

    if (widget.ordemServico != null) {
      final os = widget.ordemServico!;

      clienteSelecionado = clientes.firstWhere(
        (c) => c.id == os.clienteId,
      );

      tecnicoSelecionado = tecnicos.firstWhere(
        (t) => t.id == os.tecnicoId,
      );

      final itens = await OsItemRepository().findByOsId(
        os.id!,
      );

      servicosSelecionados = servicos.where(
        (servico) {
          return itens.any(
            (item) => item.servicoId == servico.id,
          );
        },
      ).toList();
    }

    setState(() {});
  }

  Future<void> tirarFotoAntes() async {
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        fotoAntes = photo;
      });
    }
  }

  Future<void> tirarFotoDepois() async {
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        fotoDepois = photo;
      });
    }
  }

  double get valorServicos {
    return servicosSelecionados.fold(
      0.0,
      (total, servico) => total + servico.preco,
    );
  }

  double get valorTotal {
    final valorPecas = double.tryParse(
          valorPecasController.text,
        ) ??
        0;

    return valorServicos + valorPecas;
  }

  Future<void> salvarOS() async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }

      if (clienteSelecionado == null) {
        showWarning(
          context,
          'Selecione um cliente',
        );

        return;
      }

      if (tecnicoSelecionado == null) {
        showWarning(
          context,
          'Selecione um técnico',
        );

        return;
      }

      if (servicosSelecionados.isEmpty) {
        showWarning(
          context,
          'Selecione ao menos um serviço',
        );

        return;
      }

      final valorPecas = double.tryParse(
            valorPecasController.text,
          ) ??
          0;

      if (valorPecas < 0) {
        showWarning(
          context,
          'Valor das peças inválido',
        );

        return;
      }

      showLoading(
        context,
        message: 'Salvando OS...',
      );

      assinaturaBytes = await signatureController.toPngBytes();

      final ordem = OrdemServico(
        id: widget.ordemServico?.id,
        clienteId: clienteSelecionado!.id!,
        tecnicoId: tecnicoSelecionado!.id!,
        observacao: observacaoController.text,
        pecasAplicadas: pecasController.text,
        valorPecas: valorPecas,
        fotoAntes: fotoAntes?.path,
        fotoDepois: fotoDepois?.path,
        assinatura: assinaturaBytes != null
            ? base64Encode(
                assinaturaBytes!,
              )
            : null,
        status: statusSelecionado,
        itens: [],
      );

      final OrdemServico ordemSalva;

      if (widget.ordemServico == null) {
        ordemSalva = await service.create(
          ordem,
        );
      } else {
        ordemSalva = await service.update(
          ordem,
        );
      }

      print(
        '✅ OS salva local ID: ${ordemSalva.id}',
      );

      final ordemSchedule = OrdemServicoSchedule();

      final osSync = await ordemSchedule.syncById(
        ordemSalva.id!,
      );

      print(
        '☁️ Resultado sync OS: $osSync',
      );

      if (!osSync) {
        hideLoading(context);

        showError(
          context,
          'Erro ao sincronizar OS',
        );

        return;
      }

      final osItemRepository = OsItemRepository();

      for (final servico in servicosSelecionados) {
        final item = OsItem(
          osId: ordemSalva.id!,
          servicoId: servico.id!,
          descricaoSnapshot: servico.descricao,
          precoSnapshot: servico.preco,
        );

        await osItemRepository.insert(
          item,
        );

        print(
          '📦 Item criado localmente',
        );
      }

      final osItemSchedule = OsItemSchedule();

      final itensSync = await osItemSchedule.syncByOsId(
        ordemSalva.id!,
      );

      print(
        '☁️ Resultado sync itens: $itensSync',
      );

      hideLoading(context);

      showSuccess(
        context,
        'OS salva com sucesso',
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      hideLoading(context);

      showError(
        context,
        'Erro ao salvar OS',
        details: e.toString(),
      );
    }
  }

  Widget buildFotoCard({
    required String titulo,
    required XFile? foto,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return CustomListCard(
      leading: CircleAvatar(
        backgroundColor: colors.primary.withOpacity(0.12),
        child: Icon(
          Icons.camera_alt,
          color: colors.primary,
        ),
      ),
      title: Text(titulo),
      subtitle: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(
                color: colors.outline,
              ),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: foto == null
                ? const Center(
                    child: Text(
                      'Nenhuma foto',
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    child: Image.file(
                      File(
                        foto.path,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(
            height: 16,
          ),
          CustomPrimaryButton(
            text: 'Capturar Foto',
            icon: Icons.camera_alt,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    observacaoController.dispose();

    pecasController.dispose();

    valorPecasController.dispose();

    signatureController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ordemServico == null ? 'Nova OS' : 'Editar OS',
        ),
        backgroundColor: colors.primary,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.primary.withOpacity(0.12),
                child: Icon(
                  Icons.person,
                  color: colors.primary,
                ),
              ),
              title: const Text('Cliente'),
              subtitle: DropdownButtonFormField<Cliente>(
                value: clienteSelecionado,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                items: clientes.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    clienteSelecionado = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.secondary.withOpacity(0.12),
                child: Icon(
                  Icons.engineering,
                  color: colors.secondary,
                ),
              ),
              title: const Text('Técnico'),
              subtitle: DropdownButtonFormField<Tecnico>(
                value: tecnicoSelecionado,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                items: tecnicos.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    tecnicoSelecionado = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.tertiary.withOpacity(0.12),
                child: Icon(
                  Icons.miscellaneous_services,
                  color: colors.tertiary,
                ),
              ),
              title: const Text('Serviços'),
              subtitle: Column(
                children: [
                  const SizedBox(height: 12),
                  ...servicos.map(
                    (servico) {
                      final selecionado = servicosSelecionados.any(
                        (s) => s.id == servico.id,
                      );

                      return CheckboxListTile(
                        value: selecionado,
                        title: Text(
                          servico.descricao,
                        ),
                        subtitle: Text(
                          'R\$ ${servico.preco.toStringAsFixed(2)}',
                        ),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              if (!servicosSelecionados.any(
                                (s) => s.id == servico.id,
                              )) {
                                servicosSelecionados.add(servico);
                              }
                            } else {
                              servicosSelecionados.removeWhere(
                                (s) => s.id == servico.id,
                              );
                            }
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(
                  0.12,
                ),
                child: const Icon(
                  Icons.flag,
                  color: Colors.orange,
                ),
              ),
              title: const Text('Status'),
              subtitle: DropdownButtonFormField<String>(
                value: statusSelecionado,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Em aberto',
                    child: Text('Em aberto'),
                  ),
                  DropdownMenuItem(
                    value: 'Em execução',
                    child: Text('Em execução'),
                  ),
                  DropdownMenuItem(
                    value: 'Executada',
                    child: Text('Executada'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    statusSelecionado = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Observações',
              controller: observacaoController,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Peças Aplicadas',
              controller: pecasController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Valor das Peças',
              controller: valorPecasController,
              keyboardType: TextInputType.number,
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 24),
            buildFotoCard(
              titulo: 'Foto Antes',
              foto: fotoAntes,
              onTap: tirarFotoAntes,
            ),
            const SizedBox(height: 24),
            buildFotoCard(
              titulo: 'Foto Depois',
              foto: fotoDepois,
              onTap: tirarFotoDepois,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Assinatura',
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.outline,
                        ),
                      ),
                      child: Signature(
                        controller: signatureController,
                        height: 200,
                        backgroundColor: Colors.grey[100]!,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomSecondaryButton(
                        text: 'Limpar Assinatura',
                        icon: Icons.clear,
                        onPressed: () {
                          signatureController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Valor Serviços',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R\$ ${valorServicos.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Valor Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'R\$ ${valorTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomPrimaryButton(
              text: widget.ordemServico == null ? 'Salvar OS' : 'Atualizar OS',
              icon: Icons.save,
              onPressed: salvarOS,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
