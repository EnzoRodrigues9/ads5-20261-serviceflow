import 'package:flutter/material.dart';

import '../../../ordens_servico/presentation/pages/ordem_servico_repository.dart';
import '../../../../app_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lista = OrdemServicoRepository.listaOS;

    final abertas = lista.where((os) => os.status == 'Em aberto').toList();

    final execucao = lista.where((os) => os.status == 'Em execução').toList();

    final executadas = lista.where((os) => os.status == 'Executada').toList();
    
    final theme = Theme.of(context);
    final colors = theme.colorScheme;


    double somaValores(List listaOS) {
      return listaOS.fold(
        0.0,
        (total, os) => total + os.valor,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard ServiceFlow'),
        backgroundColor: colors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            AppRoutes.ordemServico,
          );

          (context as Element).markNeedsBuild();
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Resumo das Ordens de Serviço',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            context,
            titulo: 'Total de OS',
            quantidade: lista.length,
            valor: somaValores(lista),
            cor: colors.primary,
            lista: lista,
          ),
          _buildCard(
            context,
            titulo: 'OS em aberto',
            quantidade: abertas.length,
            valor: somaValores(abertas),
            cor: colors.tertiary,
            lista: abertas,
          ),
          _buildCard(
            context,
            titulo: 'OS em execução',
            quantidade: execucao.length,
            valor: somaValores(execucao),
            cor: colors.tertiaryContainer,
            lista: execucao,
          ),
          _buildCard(
            context,
            titulo: 'OS executadas',
            quantidade: executadas.length,
            valor: somaValores(executadas),
            cor: colors.secondary,
            lista: executadas,
          ),
          const SizedBox(height: 30),
          const Text(
            'Ações rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context,
            title: 'Cadastrar Cliente',
            icon: Icons.person_add,
            color: colors.primary,
            route: AppRoutes.cadastroCliente,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String titulo,
    required int quantidade,
    required double valor,
    required Color cor,
    required List lista,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor,
          child: const Icon(
            Icons.assignment,
            color: Colors.white,
          ),
        ),
        title: Text(titulo),
        subtitle: Text(
          '$quantidade ordens • R\$ ${valor.toStringAsFixed(2)}',
        ),
        trailing: const Icon(Icons.visibility),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return ListView.builder(
                itemCount: lista.length,
                itemBuilder: (_, index) {
                  final os = lista[index];

                  return ListTile(
                    title: Text(os.cliente),
                    subtitle: Text(os.descricao),
                    trailing: Text(
                      'R\$ ${os.valor.toStringAsFixed(2)}',
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(context, route);

          (context as Element).markNeedsBuild();
        },
      ),
    );
  }
}
