import 'package:flutter/material.dart';

import '../ordens_servico/ordem_servico.model.dart';
import '../ordens_servico/ordem_servico.repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final repository = OrdemServicoRepository();

  List<OrdemServico> lista = [];

  @override
  void initState() {
    super.initState();

    carregarDados();
  }

  Future<void> carregarDados() async {
    lista = await repository.findAllActive();

    setState(() {});
  }

  double calcularTotalOS(
    OrdemServico os,
  ) {
    final valorServicos = os.itens.fold(
      0.0,
      (total, item) => total + (item.precoSnapshot ?? 0),
    );

    return valorServicos + os.valorPecas;
  }

  double somaValores(
    List<OrdemServico> listaOS,
  ) {
    return listaOS.fold(
      0.0,
      (total, os) => total + calcularTotalOS(os),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final abertas = lista
        .where(
          (os) => os.status == 'Em aberto',
        )
        .toList();

    final emExecucao = lista
        .where(
          (os) => os.status == 'Em execução',
        )
        .toList();

    final executadas = lista
        .where(
          (os) => os.status == 'Executada',
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard ServiceFlow',
        ),
        backgroundColor: colors.primary,
      ),
      body: RefreshIndicator(
        onRefresh: carregarDados,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Resumo das Ordens de Serviço',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildCard(
              titulo: 'Total de OS',
              quantidade: lista.length,
              valor: somaValores(lista),
              cor: Colors.blue,
              icon: Icons.assignment,
            ),
            _buildCard(
              titulo: 'OS Em Aberto',
              quantidade: abertas.length,
              valor: somaValores(
                abertas,
              ),
              cor: Colors.red,
              icon: Icons.pending,
            ),
            _buildCard(
              titulo: 'OS Em Execução',
              quantidade: emExecucao.length,
              valor: somaValores(
                emExecucao,
              ),
              cor: Colors.orange,
              icon: Icons.build_circle,
            ),
            _buildCard(
              titulo: 'OS Executadas',
              quantidade: executadas.length,
              valor: somaValores(
                executadas,
              ),
              cor: Colors.green,
              icon: Icons.check_circle,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumo Financeiro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Faturamento Total',
                        ),
                        Text(
                          'R\$ ${somaValores(lista).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'OS Finalizadas',
                        ),
                        Text(
                          '${executadas.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String titulo,
    required int quantidade,
    required double valor,
    required Color cor,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          titulo,
        ),
        subtitle: Text(
          '$quantidade ordens',
        ),
        trailing: Text(
          'R\$ ${valor.toStringAsFixed(2)}',
          style: TextStyle(
            color: cor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
