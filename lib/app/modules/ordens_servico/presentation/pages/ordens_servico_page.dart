import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import '../../../../../app/core/mixins/messages.mixin.dart';
import '../../../../../app/core/mixins/loader.mixin.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

import '../../../clientes/cliente_repository.dart';

import 'ordem_servico.dart';
import 'ordem_servico_repository.dart';

class OrdemServicoPage extends StatefulWidget {
  const OrdemServicoPage({super.key});

  @override
  State<OrdemServicoPage> createState() =>
      _OrdemServicoPageState();
}

class _OrdemServicoPageState
    extends State<OrdemServicoPage>
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

    if (_signatureController.isEmpty) {

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

    assinaturaBytes =
        await _signatureController.toPngBytes();

    await Future.delayed(
      const Duration(seconds: 2),
    );

    OrdemServicoRepository.listaOS.add(
      OrdemServico(
        cliente: clienteSelecionado!,
        descricao: descricaoController.text,
        valor: double.parse(valorController.text),
        status: 'Em aberto',
      ),
    );

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),

          child: foto == null
              ? const Center(
                  child: Text(
                    'Nenhuma foto capturada',
                  ),
                )
              : ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),

                  child: Image.file(
                    File(foto.path),
                    fit: BoxFit.cover,
                  ),
                ),
        ),

        const SizedBox(height: 10),

        CustomButton(
          onPressed: onTap,
          child: const Text('Capturar Foto'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Nova Ordem de Serviço',
        ),
        backgroundColor: colors.primary,
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [

            DropdownButtonFormField<String>(

              value: clienteSelecionado,

              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
              ),

              items: ClienteRepository.clientes.map((cliente) {

                return DropdownMenuItem(
                  value: cliente.nome,
                  child: Text(cliente.nome),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  clienteSelecionado = value;
                });

              },
            ),

            const SizedBox(height: 20),

            CustomTextField(
              label: 'Descrição do Serviço',
              controller: descricaoController,
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            CustomTextField(
              label: 'Valor',
              controller: valorController,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            _buildFotoCard(
              titulo: 'Foto Antes',
              foto: _fotoAntes,
              onTap: _tirarFotoAntes,
            ),

            const SizedBox(height: 24),

            _buildFotoCard(
              titulo: 'Foto Depois',
              foto: _fotoDepois,
              onTap: _tirarFotoDepois,
            ),

            const SizedBox(height: 24),

            const Text(
              'Assinatura do Cliente',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
              ),

              child: Signature(
                controller: _signatureController,
                height: 200,
                backgroundColor: Colors.grey[100]!,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,

              children: [

                CustomButton(
                  onPressed: () {
                    _signatureController.clear();
                  },
                  child: const Text('Limpar Assinatura'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            CustomButton(
              onPressed: _salvarOS,
              child: const Text(
                'Salvar Ordem de Serviço',
              ),
            ),
          ],
        ),
      ),
    );
  }
}