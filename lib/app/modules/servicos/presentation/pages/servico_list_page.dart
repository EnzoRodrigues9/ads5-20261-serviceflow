import 'package:flutter/material.dart';

import '../../../../shared/widgets/custom_cards.dart';

import '../../servico.model.dart';
import '../../servico.repository.dart';
import '../../servico.service.dart';
import '../../servico.validation.dart';

import 'cadastro_servico_page.dart';

class ServicoListPage extends StatefulWidget {
  const ServicoListPage({super.key});

  @override
  State<ServicoListPage> createState() =>
      _ServicoListPageState();
}

class _ServicoListPageState
    extends State<ServicoListPage> {
  final repository = ServicoRepository();

  late final validation =
      ServicoValidation(repository);

  late final service =
      ServicoService(validation, repository);

  List<Servico> servicos = [];

  String busca = '';

  @override
  void initState() {
    super.initState();

    carregarServicos();
  }

  Future<void> carregarServicos() async {
    servicos = await service.findAllActive();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final listaFiltrada = servicos.where((servico) {
      return servico.descricao
              .toLowerCase()
              .contains(busca.toLowerCase()) ||
          servico.preco
              .toString()
              .contains(busca);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Serviços',
        ),
        backgroundColor: colors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CadastroServicoPage(),
            ),
          );

          carregarServicos();
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar serviço...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  busca = value;
                });
              },
            ),
          ),
          Expanded(
            child: listaFiltrada.isEmpty
                ? const CustomEmptyStateCard(
                    icon:
                        Icons.miscellaneous_services,
                    title:
                        'Nenhum serviço encontrado',
                  )
                : ListView.builder(
                    itemCount:
                        listaFiltrada.length,
                    itemBuilder: (_, index) {
                      final servico =
                          listaFiltrada[index];

                      return CustomListCard(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: colors
                              .primary
                              .withOpacity(0.12),
                          child: Icon(
                            Icons
                                .miscellaneous_services,
                            color: colors.primary,
                          ),
                        ),
                        title: Text(
                          servico.descricao,
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              'R\$ ${servico.preco.toStringAsFixed(2)}',
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              servico
                                      .tempoEstimado ??
                                  'Sem tempo estimado',
                            ),
                          ],
                        ),
                        trailing:
                            PopupMenuButton(
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value:
                                  'editar',
                              child: Text(
                                'Editar',
                              ),
                            ),
                            const PopupMenuItem(
                              value:
                                  'excluir',
                              child: Text(
                                'Excluir',
                              ),
                            ),
                          ],
                          onSelected:
                              (value) async {
                            if (value ==
                                'editar') {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CadastroServicoPage(
                                    servico:
                                        servico,
                                  ),
                                ),
                              );

                              carregarServicos();
                            }

                            if (value ==
                                'excluir') {
                              await service
                                  .softDelete(
                                servico.id!,
                              );

                              carregarServicos();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}