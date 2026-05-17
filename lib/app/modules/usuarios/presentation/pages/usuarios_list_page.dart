import 'package:flutter/material.dart';

import '../../../../shared/widgets/custom_cards.dart';

import '../../usuario.model.dart';
import '../../usuario.repository.dart';

import 'cadastro_usuario_page.dart';

class UsuariosListPage extends StatefulWidget {
  const UsuariosListPage({super.key});

  @override
  State<UsuariosListPage> createState() =>
      _UsuariosListPageState();
}

class _UsuariosListPageState
    extends State<UsuariosListPage> {
  final repository = UsuarioRepository();

  List<Usuario> usuarios = [];

  String busca = '';

  @override
  void initState() {
    super.initState();

    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    usuarios = await repository.findAll();

    setState(() {});
  }

  Future<void> deletarUsuario(
    int id,
  ) async {
    await repository.delete(id);

    carregarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    final listaFiltrada =
        usuarios.where((usuario) {
      return usuario.nomeCompleto
              .toLowerCase()
              .contains(
                busca.toLowerCase(),
              ) ||
          usuario.email
              .toLowerCase()
              .contains(
                busca.toLowerCase(),
              ) ||
          usuario.perfil
              .toLowerCase()
              .contains(
                busca.toLowerCase(),
              );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Usuários',
        ),
        backgroundColor: colors.primary,
      ),
      floatingActionButton:
          FloatingActionButton(
        backgroundColor: colors.primary,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CadastroUsuarioPage(),
            ),
          );

          carregarUsuarios();
        },
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              decoration:
                  const InputDecoration(
                hintText:
                    'Buscar usuário...',
                prefixIcon:
                    Icon(Icons.search),
                border:
                    OutlineInputBorder(),
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
                    title:
                        'Nenhum usuário encontrado',
                  )
                : ListView.builder(
                    itemCount:
                        listaFiltrada.length,
                    itemBuilder:
                        (_, index) {
                      final usuario =
                          listaFiltrada[
                              index];

                      return CustomListCard(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading:
                            CircleAvatar(
                          backgroundColor:
                              colors.primary
                                  .withOpacity(
                                      0.12),
                          child: Icon(
                            Icons.person,
                            color:
                                colors.primary,
                          ),
                        ),
                        title: Text(
                          usuario
                              .nomeCompleto,
                        ),
                        subtitle: Text(
                          '${usuario.email}\nPerfil: ${usuario.perfil}',
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
                                      CadastroUsuarioPage(
                                    usuario:
                                        usuario,
                                  ),
                                ),
                              );

                              carregarUsuarios();
                            }

                            if (value ==
                                'excluir') {
                              await deletarUsuario(
                                usuario.id!,
                              );
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