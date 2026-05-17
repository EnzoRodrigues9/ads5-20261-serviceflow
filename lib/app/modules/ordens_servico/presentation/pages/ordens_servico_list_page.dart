import 'package:flutter/material.dart';

import '../../../../shared/widgets/custom_cards.dart';

import '../../ordem_servico.model.dart';
import '../../ordem_servico.repository.dart';
import '../../ordem_servico.service.dart';
import '../../ordem_servico.validation.dart';
import '../../../../core/mixins/messages.mixin.dart';

import 'cadastro_ordem_servico_page.dart';

class OrdemServicoListPage extends StatefulWidget {
  const OrdemServicoListPage({super.key});

  @override
  State<OrdemServicoListPage> createState() => _OrdemServicoListPageState();
}

class _OrdemServicoListPageState extends State<OrdemServicoListPage>
    with MessagesMixin {
  final repository = OrdemServicoRepository();

  late final validation = OrdemServicoValidation(repository);

  late final service = OrdemServicoService(
    validation,
    repository,
  );

  List<OrdemServico> ordens = [];

  String busca = '';

  @override
  void initState() {
    super.initState();

    carregarOrdens();
  }

  Future<void> carregarOrdens() async {
    ordens = await service.findAllActive();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final listaFiltrada = ordens.where((os) {
      return (os.observacao ?? '').toLowerCase().contains(
            busca.toLowerCase(),
          );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ordens de Serviço',
        ),
        backgroundColor: colors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        child: const Icon(Icons.add),
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CadastroOrdemServicoPage(),
            ),
          );

          if (resultado == true) {
            carregarOrdens();
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar ordem de serviço...',
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
                    icon: Icons.assignment,
                    title: 'Nenhuma ordem encontrada',
                  )
                : ListView.builder(
                    itemCount: listaFiltrada.length,
                    itemBuilder: (_, index) {
                      final ordem = listaFiltrada[index];

                      return CustomListCard(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: colors.primary.withOpacity(0.12),
                          child: Icon(
                            Icons.assignment,
                            color: colors.primary,
                          ),
                        ),
                        title: Text(
                          'OS #${ordem.id ?? 0}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              ordem.observacao?.isNotEmpty == true
                                  ? ordem.observacao!
                                  : 'Sem observações',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 16,
                                  color: ordem.status == 'Executada'
                                      ? Colors.green
                                      : ordem.status == 'Em execução'
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  ordem.status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: ordem.status == 'Executada'
                                        ? Colors.green
                                        : ordem.status == 'Em execução'
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (_) {
                                final valorServicos = ordem.itens.fold(
                                  0.0,
                                  (total, item) =>
                                      total + (item.precoSnapshot ?? 0),
                                );

                                final valorTotal =
                                    valorServicos + ordem.valorPecas;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Serviços: ${ordem.itens.length}',
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Valor Serviços: R\$ ${valorServicos.toStringAsFixed(2)}',
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Valor Peças: R\$ ${ordem.valorPecas.toStringAsFixed(2)}',
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Valor Total: R\$ ${valorTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'editar',
                              child: Text(
                                'Editar',
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'excluir',
                              child: Text(
                                'Excluir',
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'editar') {
                              final resultado = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CadastroOrdemServicoPage(
                                    ordemServico: ordem,
                                  ),
                                ),
                              );

                              if (resultado == true) {
                                carregarOrdens();
                              }
                            }

                            if (value == 'excluir') {
                              final confirmar = await showDeleteConfirmation(
                                context,
                                'a OS #${ordem.id}',
                              );

                              if (confirmar == true) {
                                await service.softDelete(
                                  ordem.id!,
                                );

                                carregarOrdens();

                                showSuccess(
                                  context,
                                  'OS excluída com sucesso',
                                );
                              }
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
