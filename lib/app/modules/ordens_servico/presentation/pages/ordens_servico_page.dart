import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import '../../../../core/mixins/messages.mixin.dart';
import '../../../../core/mixins/loader.mixin.dart';

import '../../../../shared/widgets/custom_buttons.dart';
import '../../../../shared/widgets/custom_cards.dart';
import '../../../../shared/widgets/custom_text_field.dart';

import '../../../clientes/cliente_repository.dart';

import 'ordens_servico.dart';
import 'ordens_servico_repository.dart';

class OrdensServicoPage extends StatefulWidget {
  final OrdemServico? ordemServico;

  const OrdensServicoPage({
    super.key,
    this.ordemServico,
  });

  @override
  State<OrdensServicoPage> createState() => _OrdensServicoPageState();
}

class _OrdensServicoPageState extends State<OrdensServicoPage>
    with LoaderMixin, MessagesMixin {
  final _formKey = GlobalKey<FormState>();

  final descricaoController = TextEditingController();

  final valorController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  XFile? _fotoAntes;
  XFile? _fotoDepois;

  String? clienteSelecionado;

  late SignatureController _signatureController;

  Uint8List? assinaturaBytes;

  @override
  void initState() {
    super.initState();

    _signatureController = SignatureController(
      penStrokeWidth: 4,
      penColor: Colors.blue,
      exportBackgroundColor: Colors.white,
    );

    /// MODO EDIÇÃO
    if (widget.ordemServico != null) {
      clienteSelecionado = widget.ordemServico!.cliente;

      descricaoController.text = widget.ordemServico!.descricao;

      valorController.text = widget.ordemServico!.valor.toString();
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
    _signatureController.dispose();

    super.dispose();
  }

  Future<void> _tirarFotoAntes() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _fotoAntes = photo;
      });
    }
  }

  Future<void> _tirarFotoDepois() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _fotoDepois = photo;
      });
    }
  }

  Future<void> _salvarOS() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (clienteSelecionado == null) {
      showWarning(
        context,
        'Selecione um cliente',
      );
      return;
    }

    if (_signatureController.isEmpty && widget.ordemServico == null) {
      showWarning(
        context,
        'Realize a assinatura antes de salvar',
      );

      return;
    }

    showLoading(
      context,
      message: 'Salvando ordem de serviço...',
    );

    assinaturaBytes = await _signatureController.toPngBytes();

    await Future.delayed(
      const Duration(seconds: 1),
    );

    final novaOS = OrdemServico(
      id: widget.ordemServico?.id ?? DateTime.now().millisecondsSinceEpoch,
      cliente: clienteSelecionado!,
      descricao: descricaoController.text,
      valor: double.parse(
        valorController.text,
      ),
      status: widget.ordemServico?.status ?? 'Em aberto',
    );

    /// NOVA OS
    if (widget.ordemServico == null) {
      OrdemServicoRepository.listaOS.add(novaOS);
    } else {
      /// EDITAR OS
      final index = OrdemServicoRepository.listaOS.indexWhere(
        (os) => os.id == widget.ordemServico!.id,
      );

      OrdemServicoRepository.listaOS[index] = novaOS;
    }

    hideLoading(context);

    showSuccess(
      context,
      'OS salva com sucesso!',
    );

    Navigator.pop(context);
  }

  Widget _buildFotoCard({
    required String titulo,
    required XFile? foto,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomInfoCard(
              icon: Icons.photo_camera,
              title: titulo,
              value:
                  foto == null ? 'Nenhuma foto capturada' : 'Foto adicionada',
              iconColor: colors.primary,
              showDivider: false,
            ),
            const SizedBox(height: 16),
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: colors.outline,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text(
                            'Nenhuma foto',
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(foto.path),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            CustomPrimaryButton(
              text: 'Capturar Foto',
              icon: Icons.camera_alt,
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ordemServico == null
              ? 'Nova Ordem de Serviço'
              : 'Editar Ordem de Serviço',
        ),
        backgroundColor: colors.primary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// CLIENTE
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.primary.withOpacity(0.12),
                child: Icon(
                  Icons.person,
                  color: colors.primary,
                ),
              ),
              title: const Text(
                'Cliente',
              ),
              subtitle: DropdownButtonFormField<String>(
                value: clienteSelecionado,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Selecione um cliente',
                ),
                items: ClienteRepository.clientes.map((cliente) {
                  return DropdownMenuItem(
                    value: cliente.nome,
                    child: Text(
                      cliente.nome,
                    ),
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

            /// DESCRIÇÃO
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.tertiary.withOpacity(0.12),
                child: Icon(
                  Icons.description,
                  color: colors.tertiary,
                ),
              ),
              title: const Text(
                'Descrição do Serviço',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: CustomTextField(
                  label: 'Descrição',
                  controller: descricaoController,
                  maxLines: 4,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// VALOR
            CustomListCard(
              leading: CircleAvatar(
                backgroundColor: colors.secondary.withOpacity(0.12),
                child: Icon(
                  Icons.attach_money,
                  color: colors.secondary,
                ),
              ),
              title: const Text(
                'Valor do Serviço',
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: CustomTextField(
                  label: 'Valor',
                  controller: valorController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// FOTO ANTES
            _buildFotoCard(
              titulo: 'Foto Antes',
              foto: _fotoAntes,
              onTap: _tirarFotoAntes,
            ),

            const SizedBox(height: 24),

            /// FOTO DEPOIS
            _buildFotoCard(
              titulo: 'Foto Depois',
              foto: _fotoDepois,
              onTap: _tirarFotoDepois,
            ),

            const SizedBox(height: 24),

            /// ASSINATURA
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  16,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomInfoCard(
                      icon: Icons.draw,
                      title: 'Assinatura',
                      value: 'Assinatura do cliente',
                      iconColor: colors.primary,
                      showDivider: false,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.outline,
                        ),
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Signature(
                        controller: _signatureController,
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
                          _signatureController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// SALVAR
            CustomPrimaryButton(
              text: widget.ordemServico == null
                  ? 'Salvar Ordem de Serviço'
                  : 'Atualizar Ordem de Serviço',
              icon: Icons.save,
              onPressed: _salvarOS,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
