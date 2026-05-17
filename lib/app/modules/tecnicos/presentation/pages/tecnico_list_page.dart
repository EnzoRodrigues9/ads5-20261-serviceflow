import 'package:flutter/material.dart';

import '../../../../shared/widgets/custom_cards.dart';

import '../../tecnico.model.dart';
import '../../tecnico.repository.dart';
import '../../tecnico.service.dart';
import '../../tecnico.validation.dart';

import 'cadastro_tecnico_page.dart';

class TecnicoListPage extends StatefulWidget {
  const TecnicoListPage({super.key});

  @override
  State<TecnicoListPage> createState() => _TecnicoListPageState();
}

class _TecnicoListPageState extends State<TecnicoListPage> {
  final repository = TecnicoRepository();

  late final validation = TecnicoValidation(repository);

  late final service = TecnicoService(validation, repository);

  List<Tecnico> tecnicos = [];

  String busca = '';

  @override
  void initState() {
    super.initState();

    carregarTecnicos();
  }

  Future<void> carregarTecnicos() async {
    tecnicos = await service.findAllActive();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final listaFiltrada = tecnicos.where((tecnico) {
      return tecnico.nome.toLowerCase().contains(busca.toLowerCase()) ||
          (tecnico.especialidade ?? '')
              .toLowerCase()
              .contains(busca.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Técnicos',
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
              builder: (_) => const CadastroTecnicoPage(),
            ),
          );

          carregarTecnicos();
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar técnico...',
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
                    icon: Icons.engineering,
                    title: 'Nenhum técnico encontrado',
                  )
                : ListView.builder(
                    itemCount: listaFiltrada.length,
                    itemBuilder: (_, index) {
                      final tecnico = listaFiltrada[index];

                      return CustomListCard(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: colors.primary.withOpacity(0.12),
                          child: Icon(
                            Icons.engineering,
                            color: colors.primary,
                          ),
                        ),
                        title: Text(
                          tecnico.nome,
                        ),
                        subtitle: Text(
                          tecnico.especialidade ?? 'Sem especialidade',
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
                                  builder: (_) => CadastroTecnicoPage(
                                    tecnico: tecnico,
                                  ),
                                ),
                              );

                              carregarTecnicos();
                            }

                            if (value == 'excluir') {
                              await service.softDelete(
                                tecnico.id!,
                              );

                              carregarTecnicos();
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
