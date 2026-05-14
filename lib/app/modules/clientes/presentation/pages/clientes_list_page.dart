import 'package:flutter/material.dart';

import '../../../../shared/widgets/custom_cards.dart';

import '../../cliente.dart';
import '../../cliente_repository.dart';

import 'cadastro_cliente_page.dart';

class ClienteListPage extends StatefulWidget {
  const ClienteListPage({super.key});

  @override
  State<ClienteListPage> createState() => _ClienteListPageState();
}

class _ClienteListPageState extends State<ClienteListPage> {
  String busca = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final listaFiltrada = ClienteRepository.clientes.where((cliente) {
      return cliente.nome.toLowerCase().contains(busca.toLowerCase()) ||
          cliente.email.toLowerCase().contains(busca.toLowerCase()) ||
          cliente.cpf.toLowerCase().contains(busca.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clientes',
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
              builder: (_) => const CadastroClientePage(),
            ),
          );

          setState(() {});
        },
      ),
      body: Column(
        children: [
          /// BUSCA
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar cliente...',
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
                    icon: Icons.people,
                    title: 'Nenhum cliente encontrado',
                  )
                : ListView.builder(
                    itemCount: listaFiltrada.length,
                    itemBuilder: (_, index) {
                      final cliente = listaFiltrada[index];

                      return CustomListCard(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: colors.primary.withOpacity(0.12),
                          child: Icon(
                            Icons.person,
                            color: colors.primary,
                          ),
                        ),
                        title: Text(
                          cliente.nome,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(cliente.email),
                            const SizedBox(height: 4),
                            Text(
                              cliente.telefone,
                            ),
                            const SizedBox(height: 8),
                            CustomStatusCard(
                              label: 'Ativo',
                              isActive: true,
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
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CadastroClientePage(
                                    cliente: cliente,
                                  ),
                                ),
                              );

                              setState(() {});
                            }

                            
                            if (value == 'excluir') {
                              ClienteRepository.clientes.remove(cliente);

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
