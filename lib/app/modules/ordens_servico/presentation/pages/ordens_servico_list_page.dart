import 'package:flutter/material.dart';

import '../../../../shared/widgets/custom_cards.dart';

import 'ordens_servico.dart';
import 'ordens_servico_page.dart';
import 'ordens_servico_repository.dart';

class OrdensServicoListPage extends StatefulWidget {
  const OrdensServicoListPage({super.key});

  @override
  State<OrdensServicoListPage> createState() =>
      _OrdensServicoListPageState();
}

class _OrdensServicoListPageState
    extends State<OrdensServicoListPage> {
  String busca = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final listaFiltrada =
        OrdemServicoRepository.listaOS.where((os) {
      return os.cliente
              .toLowerCase()
              .contains(busca.toLowerCase()) ||
          os.descricao
              .toLowerCase()
              .contains(busca.toLowerCase());
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
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OrdensServicoPage(),
            ),
          );

          setState(() {});
        },
      ),

      body: Column(
        children: [

          /// CAMPO BUSCA
          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar OS...',
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

          /// LISTA
          Expanded(
            child: listaFiltrada.isEmpty
                ? const CustomEmptyStateCard(
                    icon: Icons.assignment,
                    title:
                        'Nenhuma ordem de serviço encontrada',
                  )

                : ListView.builder(
                    itemCount: listaFiltrada.length,

                    itemBuilder: (_, index) {
                      final os = listaFiltrada[index];

                      Color statusColor;

                      switch (os.status) {
                        case 'Executada':
                          statusColor = Colors.green;
                          break;

                        case 'Em execução':
                          statusColor = Colors.orange;
                          break;

                        default:
                          statusColor = Colors.red;
                      }

                      return CustomListCard(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        leading: CircleAvatar(
                          backgroundColor:
                              statusColor.withOpacity(
                            0.12,
                          ),

                          child: Icon(
                            Icons.assignment,
                            color: statusColor,
                          ),
                        ),

                        title: Text(
                          os.cliente,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            const SizedBox(height: 4),

                            Text(os.descricao),

                            const SizedBox(height: 8),

                            Row(
                              children: [

                                CustomStatusCard(
                                  label: os.status,
                                  isActive:
                                      os.status ==
                                          'Executada',
                                ),

                                const SizedBox(width: 8),

                                Text(
                                  'R\$ ${os.valor.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                    color:
                                        colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        trailing: PopupMenuButton(
                          itemBuilder: (_) => [

                            const PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),

                            const PopupMenuItem(
                              value: 'excluir',
                              child: Text('Excluir'),
                            ),
                          ],

                          onSelected: (value) async {

                            /// EDITAR
                            if (value == 'editar') {

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrdensServicoPage(
                                    ordemServico: os,
                                  ),
                                ),
                              );

                              setState(() {});
                            }

                            /// EXCLUIR
                            if (value == 'excluir') {

                              OrdemServicoRepository
                                  .listaOS
                                  .remove(os);

                              setState(() {});
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